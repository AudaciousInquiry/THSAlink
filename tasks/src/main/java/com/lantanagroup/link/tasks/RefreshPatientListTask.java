package com.lantanagroup.link.tasks;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.rest.client.api.ServerValidationModeEnum;
import ca.uhn.fhir.rest.client.impl.BaseClient;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.lantanagroup.link.Constants;
import com.lantanagroup.link.FhirContextProvider;
import com.lantanagroup.link.Helper;
import com.lantanagroup.link.auth.OAuth2Helper;
import com.lantanagroup.link.config.query.QueryConfig;
import com.lantanagroup.link.query.auth.HapiFhirAuthenticationInterceptor;
import com.lantanagroup.link.tasks.config.CensusReportingPeriods;
import com.lantanagroup.link.tasks.config.RefreshPatientListConfig;
import com.lantanagroup.link.tasks.helpers.HttpExecutor;
import com.lantanagroup.link.tasks.helpers.HttpExecutorResponse;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.hl7.fhir.r4.model.ListResource;
import org.hl7.fhir.r4.model.Period;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;

import java.net.URI;
import java.net.URISyntaxException;

public class RefreshPatientListTask {

    private static final Logger logger = LoggerFactory.getLogger(RefreshPatientListTask.class);
    private final FhirContext fhirContext = FhirContextProvider.getFhirContext();
    private RefreshPatientListConfig config;
    private QueryConfig queryConfig;

    public void RunRefreshPatientList(RefreshPatientListConfig config, QueryConfig queryConfig, ApplicationContext applicationContext) {
        // Read Query Config From Secrets

        // Read RefreshPatientListConfig from Secrets
    }

    private ListResource readList(String patientListId, ApplicationContext applicationContext) throws ClassNotFoundException {
        fhirContext.getRestfulClientFactory().setServerValidationMode(ServerValidationModeEnum.NEVER);
        IGenericClient client = fhirContext.newRestfulGenericClient(config.getFhirServerBase());
        if (client instanceof BaseClient) {
            ((BaseClient) client).setKeepResponses(true);
        }
        client.registerInterceptor(new HapiFhirAuthenticationInterceptor(queryConfig, applicationContext));
        ListResource r = client.fetchResourceFromUrl(ListResource.class, patientListId);
        if (r != null) {
            return r;
        } else {
            throw new IllegalArgumentException(String.format("Issue getting ListResource for Patient List ID %s", patientListId));
        }
    }

    private ListResource transformList(ListResource source, String censusIdentifier) throws URISyntaxException {
        logger.info("Transforming List");
        ListResource target = new ListResource();
        Period period = new Period();
        CensusReportingPeriods reportingPeriod = this.config.getCensusReportingPeriod();
        if (reportingPeriod == null) {
            reportingPeriod = CensusReportingPeriods.Day;
        }

        if (reportingPeriod.equals(CensusReportingPeriods.Month)) {
            period
                    .setStart(Helper.getStartOfMonth(source.getDate()))
                    .setEnd(Helper.getEndOfMonth(source.getDate(), 0));
        } else if (reportingPeriod.equals(CensusReportingPeriods.Day)) {
            period
                    .setStart(Helper.getStartOfDay(source.getDate()))
                    .setEnd(Helper.getEndOfDay(source.getDate(), 0));
        }

        target.addExtension(Constants.ApplicablePeriodExtensionUrl, period);
        target.addIdentifier()
                .setSystem(Constants.MainSystem)
                .setValue(censusIdentifier);
        target.setStatus(ListResource.ListStatus.CURRENT);
        target.setMode(ListResource.ListMode.WORKING);
        target.setTitle(String.format("Census List for %s", censusIdentifier));
        target.setCode(source.getCode());
        target.setDate(source.getDate());
        URI baseUrl = new URI(config.getFhirServerBase());
        for (ListResource.ListEntryComponent sourceEntry : source.getEntry()) {
            target.addEntry(transformListEntry(sourceEntry, baseUrl));
        }
        return target;
    }

    private ListResource.ListEntryComponent transformListEntry(ListResource.ListEntryComponent source, URI baseUrl)
            throws URISyntaxException {
        ListResource.ListEntryComponent target = source.copy();
        if (target.getItem().hasReference()) {
            URI referenceUrl = new URI(target.getItem().getReference());
            if (referenceUrl.isAbsolute()) {
                target.getItem().setReference(baseUrl.relativize(referenceUrl).toString());
            }
        }
        return target;
    }

    private void updateList(ListResource target) throws Exception {
        String url = String.format("%s/poi/fhir/PatientList", config.getApiUrl());
        logger.info("Submitting to {}", url);
        HttpPost request = new HttpPost(url);
        if (config.getAuth() != null && config.getAuth().getCredentialMode() != null) {
            String token = OAuth2Helper.getToken(config.getAuth());

            if (token == null) {
                throw new Exception("Authorization failed");
            }

            if (OAuth2Helper.validateHeaderJwtToken(token)) {
                request.addHeader(HttpHeaders.AUTHORIZATION, String.format("Bearer %s", token));
            } else {
                throw new JWTVerificationException("Invalid token format");
            }

        }
        request.addHeader(HttpHeaders.CONTENT_TYPE, ContentType.APPLICATION_JSON.toString());
        request.setEntity(new StringEntity(fhirContext.newJsonParser().encodeResourceToString(target)));

        HttpExecutorResponse response = HttpExecutor.HttpExecutor(request,logger); //Utility.HttpExecuter(request, logger);

        logger.info("HTTP Response Code {}", response.getResponseCode());
    }
}
