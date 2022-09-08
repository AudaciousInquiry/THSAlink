package com.lantanagroup.link.cli;

import com.lantanagroup.link.FhirContextProvider;
import com.lantanagroup.link.FhirDataProvider;
import com.lantanagroup.link.config.api.ApiConfig;
import com.lantanagroup.link.config.api.ApiDataStoreConfig;
import com.lantanagroup.link.config.query.QueryConfig;
import com.lantanagroup.link.config.query.USCoreConfig;
import com.lantanagroup.link.model.PatientOfInterestModel;
import com.lantanagroup.link.query.IQuery;
import com.lantanagroup.link.query.QueryFactory;
import com.lantanagroup.link.query.auth.*;
import com.lantanagroup.link.query.uscore.Query;
import com.lantanagroup.link.query.uscore.scoop.PatientScoop;
import org.apache.http.client.HttpResponseException;
import org.apache.logging.log4j.util.Strings;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.Bundle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.util.ArrayList;
import java.util.List;

@ShellComponent
public class QueryCommand extends BaseShellCommand {
  private static final Logger logger = LoggerFactory.getLogger(QueryCommand.class);

  @Override
  protected List<Class> getBeanClasses() {
    return List.of(
            Query.class,
            QueryConfig.class,
            ApiConfig.class,
            ApiDataStoreConfig.class,
            USCoreConfig.class,
            PatientScoop.class,
            EpicAuth.class,
            EpicAuthConfig.class,
            CernerAuth.class,
            CernerAuthConfig.class,
            BasicAuth.class,
            BasicAuthConfig.class);
  }



  @ShellMethod(value = "Query for patient data from the configured FHIR server")
  public void query(String patient, String resourceTypes, String measureId, @ShellOption(defaultValue = "") String output) {
    try {
      this.registerBeans();

      this.registerFhirDataProvider();
      QueryConfig config = this.applicationContext.getBean(QueryConfig.class);
      USCoreConfig usCoreConfig = this.applicationContext.getBean(USCoreConfig.class);

      if (config.isRequireHttps() && !usCoreConfig.getFhirServerBase().contains("https")) {
        throw new IllegalStateException("Query URL requires https");
      }

      List<PatientOfInterestModel> patientsOfInterest = new ArrayList<>();
      IQuery query = QueryFactory.getQueryInstance(this.applicationContext, config.getQueryClass());

      for (String pid : patient.split(",")) {
        PatientOfInterestModel poi = new PatientOfInterestModel();
        if (pid.indexOf("/") > 0) {
          poi.setReference(pid);
        } else if (pid.indexOf("|") > 0) {
          poi.setIdentifier(pid);
        }
        patientsOfInterest.add(poi);
      }

      List<String> resourceTypesList = new ArrayList<>();
      for (String resourceType : resourceTypes.split(",")) {
        resourceTypesList.add(resourceType);
      }

      logger.info("Executing query");
      String masterReportid = "1847296839";
      query.execute(patientsOfInterest, masterReportid, resourceTypesList, measureId);
      FhirDataProvider fhirDataProvider = this.applicationContext.getBean(FhirDataProvider.class);

      for (int i = 0; i < patientsOfInterest.size(); i++) {
        logger.info("Patient is: " + patientsOfInterest.get(i).getId());
        try {
          IBaseResource patientBundle = fhirDataProvider.getBundleById(masterReportid + "-" + patientsOfInterest.get(i).getId().hashCode());
          String patientDataXml = FhirContextProvider.getFhirContext().newXmlParser().encodeResourceToString((Bundle) patientBundle);
          if (Strings.isNotEmpty(output)) {
            String file = (!output.endsWith("/") ? output + FileSystems.getDefault().getSeparator() : output) + "patient-" + (i + 1) + ".xml";
            try (FileOutputStream fos = new FileOutputStream(file)) {
              fos.write(patientDataXml.getBytes(StandardCharsets.UTF_8));
            }
            logger.info("Stored patient data XML to " + file);
          } else {
            System.out.println("Patient " + (i + 1) + " Bundle XML:");
            System.out.println(patientDataXml);
          }
        } catch (Exception ex) {
          logger.error("Exception is: " + ex.getMessage());
        }
      }

     logger.info("Done");
    } catch (Exception ex) {

      logger.error("Error executing query: " + ex.getMessage(), ex);
    }
  }
}
