package com.lantanagroup.nandina.controller;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import com.lantanagroup.nandina.JsonProperties;
import com.lantanagroup.nandina.hapi.HapiFhirAuthenticationInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;

import javax.servlet.http.HttpServletRequest;

public class BaseController {
    protected FhirContext ctx = FhirContext.forR4();
    @Autowired
    private JsonProperties jsonProperties;

    protected IGenericClient getFhirQueryClient(Authentication authentication, HttpServletRequest request) throws Exception {
        String fhirBase = jsonProperties.getFhirServerQueryBase();
        String token = null;

        if (request.getHeader("fhirBase") != null) {
            fhirBase = request.getHeader("fhirBase");

            // If fhirBase is passed in header, this request is coming from Smart-on-FHIR launch context and we should
            // pass the token of the user forward to the FHIR server, rather than use what's in the config.
            token = (String) authentication.getPrincipal();
        }

        if (jsonProperties.isRequireHttps() && !fhirBase.contains("https")) {
            throw new Exception(String.format("https is required for FhirClient and was given %s", fhirBase));
        }

        IGenericClient fhirClient = this.ctx.newRestfulGenericClient(fhirBase);
        fhirClient.registerInterceptor(new HapiFhirAuthenticationInterceptor(token, jsonProperties));
        return fhirClient;
    }

    protected IGenericClient getFhirStoreClient(Authentication authentication, HttpServletRequest request) throws Exception {
        String fhirBase = jsonProperties.getFhirServerStoreBase();

        if (jsonProperties.isRequireHttps() && !fhirBase.contains("https")) {
            throw new Exception(String.format("https is required for FhirClient and was given %s", fhirBase));
        }

        IGenericClient fhirClient = this.ctx.newRestfulGenericClient(fhirBase);
        return fhirClient;
    }
}
