package com.lantanagroup.flintlock;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class Config implements IConfig {
    private static Config config;

    public static Config getInstance() {
        if (config == null) {
            config = new Config();
        }
        return config;
    }

    public static void setInstance(Config instance) {
        config = instance;
    }

    @Value("${fhirServer.base}")
    private String fhirServerBase;

    @Value("${fhirServer.username}")
    private String fhirServerUserName;

    @Value("${fhirServer.password}")
    private String fhirServerPassword;

    @Value("${fhirServer.bearerToken}")
    private String fhirServerBearerToken;

    @Value("${terminology.covidCodes}")
    private String terminologyCovidCodes;

    @Value("${terminology.deviceTypeCodes}")
    private String terminologyDeviceTypeCodes;

    @Value("${query.hospitalized}")
    private String queryHospitalized;

    @Value("${query.hospitalizedAndVentilated}")
    private String queryHospitalizedAndVentilated;

    @Value("${query.hospitalOnset}")
    private String queryHospitalOnset;

    @Value("${query.edOverflow}")
    private String queryEDOverflow;

    @Value("${query.edOverflowAndVentilated}")
    private String queryEDOverflowAndVentilated;

    @Value("${query.deaths}")
    private String queryDeaths;

    public String getQueryHospitalizedAndVentilated() {
        return queryHospitalizedAndVentilated;
    }

    @Override
    public String getQueryHospitalized() {
        return queryHospitalized;
    }

    @Override
    public String getTerminologyDeviceTypeCodes() {
        return terminologyDeviceTypeCodes;
    }

    @Override
    public String getTerminologyCovidCodes() {
        return terminologyCovidCodes;
    }

    @Override
    public String getFhirServerBearerToken() {
        return fhirServerBearerToken;
    }

    @Override
    public String getFhirServerPassword() {
        return fhirServerPassword;
    }

    @Override
    public String getFhirServerUserName() {
        return fhirServerUserName;
    }

    @Override
    public String getFhirServerBase() {
        return fhirServerBase;
    }

    public String getQueryHospitalOnset() {
        return queryHospitalOnset;
    }

    public String getQueryEDOverflow() {
        return queryEDOverflow;
    }

    public String getQueryEDOverflowAndVentilated() {
        return queryEDOverflowAndVentilated;
    }

    public String getQueryDeaths() {
        return queryDeaths;
    }
}