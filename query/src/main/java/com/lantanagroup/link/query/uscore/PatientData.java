package com.lantanagroup.link.query.uscore;

import ca.uhn.fhir.rest.client.api.IGenericClient;
import com.lantanagroup.link.FhirHelper;
import com.lantanagroup.link.Helper;
import com.lantanagroup.link.ResourceIdChanger;
import com.lantanagroup.link.config.query.USCoreConfig;
import com.lantanagroup.link.config.query.USCoreQueryParametersResourceConfig;
import com.lantanagroup.link.config.query.USCoreQueryParametersResourceParameterConfig;
import com.lantanagroup.link.model.ReportCriteria;
import com.lantanagroup.link.query.uscore.scoop.PatientScoop;
import org.hl7.fhir.r4.model.*;
import org.hl7.fhir.r4.model.Bundle.BundleType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

public class PatientData {
  private static final Logger logger = LoggerFactory.getLogger(PatientData.class);

  private final ReportCriteria criteria;
  private final Patient patient;
  private final String patientId;
  private final IGenericClient fhirQueryServer;
  private final USCoreConfig usCoreConfig;
  // private final QueryConfig queryConfig;
  private List<String> resourceTypes;
  private List<Bundle> bundles = new ArrayList<>();

  public PatientData(IGenericClient fhirQueryServer, ReportCriteria criteria, Patient patient, USCoreConfig usCoreConfig, List<String> resourceTypes) {
    this.fhirQueryServer = fhirQueryServer;
    this.criteria = criteria;
    this.patient = patient;
    this.patientId = patient.getIdElement().getIdPart();
    this.usCoreConfig = usCoreConfig;
    this.resourceTypes = resourceTypes;
  }

  /**
   * Only return the ISO time precise to the second
   *
   * @param value
   * @return
   */
  public static String getDateTimeString(String value) {
    if (value != null && value.length() > 19) {
      return value.substring(0, 19);
    }
    return value;
  }

  public static String getQueryParamValue(String value, ReportCriteria criteria) {
    String ret = value
            //.replace("${periodLookbackStart}", )
            .replace("${periodStart}", getDateTimeString(criteria.getPeriodStart()))
            .replace("${periodEnd}", getDateTimeString(criteria.getPeriodEnd()));
    return URLEncoder.encode(ret, StandardCharsets.UTF_8);
  }

  public static String getQuery(USCoreConfig usCoreConfig, List<String> measureIds, ReportCriteria criteria, String resourceType, String patientId) {
    String finalResourceType = resourceType;
    ArrayList<String> params = new ArrayList<>(List.of("patient=Patient/" + URLEncoder.encode(patientId, StandardCharsets.UTF_8)));
    HashMap<String, List<USCoreQueryParametersResourceConfig>> queryParameters = usCoreConfig.getQueryParameters();

    //check if queryParameters exist in config, if not just load patient without observations
    for (String measureId : measureIds) {
      if (queryParameters != null && !queryParameters.isEmpty()) {
        if (usCoreConfig.getQueryParameters() != null && usCoreConfig.getQueryParameters().containsKey(measureId)) {

          List<USCoreQueryParametersResourceConfig> resourceQueryParams =
                  usCoreConfig.getQueryParameters()
                          .get(measureId)
                          .stream()
                          .filter(queryParams -> queryParams.getResourceType().equals(finalResourceType))
                          .collect(Collectors.toList());

          for (USCoreQueryParametersResourceConfig resourceQueryParam : resourceQueryParams) {
            for (USCoreQueryParametersResourceParameterConfig param : resourceQueryParam.getParameters()) {
              if (param.getSingleParam() != null && param.getSingleParam() == true) {
                List<String> values = param.getValues().stream().map(v -> getQueryParamValue(v, criteria)).collect(Collectors.toList());
                String paramValue = String.join(",", values);
                params.add(param.getName() + "=" + paramValue);
              } else {
                for (String paramValue : param.getValues()) {
                  params.add(param.getName() + "=" + getQueryParamValue(paramValue, criteria));
                }
              }
            }
          }
        }
      }
    }

    return resourceType += "?" + String.join("&", params);
  }

  public void loadData(List<String> measureIds) {
    if (resourceTypes.size() == 0) {
      logger.error("Not querying for any patient data.");
      return;
    }

    //Loop through resource types specified. If observation, use config to add individual category queries
    Set<String> queryString = new HashSet<>();
    for (String resource : this.resourceTypes) {
      queryString.add(getQuery(this.usCoreConfig, measureIds, criteria, resource, patientId));
    }

    if(!queryString.isEmpty()) {
      try {
        queryString.parallelStream().forEach(query -> {
          List<Bundle> bundles = PatientScoop.rawSearch(this.fhirQueryServer, query);
          if (bundles != null) {
            this.bundles.addAll(bundles);
          }
        });
      }
      catch(Exception ex) {
        logger.error("Error while parallel processing patient data queries: {}", Helper.encodeLogging(ex.getMessage()));
      }
    }
    else{
      logger.warn("No queries generated based on resource types and configuration");
    }

  }

  public Bundle getBundleTransaction() {
    Bundle bundle = new Bundle();
    bundle.setType(BundleType.TRANSACTION);
    bundle.setIdentifier(new Identifier().setValue(this.patientId));
    bundle.addEntry().setResource(this.patient).getRequest().setMethod(Bundle.HTTPVerb.PUT).setUrl("Patient/" + patient.getIdElement().getIdPart());

    for (Bundle next : this.bundles) {
      FhirHelper.addEntriesToBundle(next, bundle);
    }

    this.getAdditionalResources(bundle, ResourceIdChanger.findReferences(bundle));

    return bundle;
  }

  private void getAdditionalResources(Bundle bundle, List<Reference> resourceReferences){
    if (this.usCoreConfig.getOtherResourceTypes() != null) {
      HashMap<String, List<String>> resourcesToGet = new HashMap<>();

      for (Reference reference : resourceReferences) {
        if (!reference.hasReference()) {
          continue;
        }

        String[] refParts = reference.getReference().split("/");
        List<String> otherResourceTypes = this.usCoreConfig.getOtherResourceTypes();
        if (otherResourceTypes.contains(refParts[0])) {
          if (!resourcesToGet.containsKey(refParts[0])) {
            resourcesToGet.put(refParts[0], new ArrayList<>());
          }

          List<String> resourceIds = resourcesToGet.get(refParts[0]);

          if (!resourceIds.contains(refParts[1])) {
            resourceIds.add(refParts[1]);
          }
        }
      }

      resourcesToGet.keySet().stream().forEach(resourceType -> {
        Set<String> resourceIds = new HashSet<>(resourcesToGet.get(resourceType));
        logger.info("Loading {} other {} resources for patient {}", resourceIds.size(), resourceType, patientId);
        // TODO: Instead of reading resources individually, search for batches using `_id`?
        resourcesToGet.get(resourceType).parallelStream().forEach(resourceId -> {
          try {
            Resource resource = (Resource) this.fhirQueryServer.read()
                    .resource(resourceType)
                    .withId(resourceId)
                    .execute();
            bundle.addEntry().setResource(resource);
          }catch(Exception e){
            logger.debug("Can't find resource of type: " + resourceType + " and id: " + resourceId);
          }
        });
      });
    }
  }
}
