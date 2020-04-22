package com.lantanagroup.flintlock.query;

import ca.uhn.fhir.rest.client.api.IGenericClient;
import com.lantanagroup.flintlock.Config;
import com.lantanagroup.flintlock.Helper;
import com.lantanagroup.flintlock.IConfig;
import org.hl7.fhir.r4.model.Bundle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EDOverflowAndVentilatedQuery implements IQueryCountExecutor {
    private static final Logger logger = LoggerFactory.getLogger(EDOverflowAndVentilatedQuery.class);

    @Override
    public Integer execute(IConfig config, IGenericClient fhirClient, String reportDate, String overflowLocations) {
        if (overflowLocations != null && !overflowLocations.isEmpty()) {
            if (Helper.isNullOrEmpty(config.getTerminologyCovidCodes())) {
                this.logger.error("Covid codes have not been specified in configuration. Cannot execute query.");
                return null;
            }

            if (Helper.isNullOrEmpty(config.getTerminologyDeviceTypeCodes())) {
                this.logger.error("Device-type codes have not been specified in configuration. Cannot execute query.");
                return null;
            }

            try {
                String url = String.format("Patient?_summary=true&_has:Condition:patient:code=%s&_has:Encounter:patient:location=%s&_has:Device:patient:type=%s",
                        Config.getInstance().getTerminologyCovidCodes(),
                        overflowLocations,
                        Config.getInstance().getTerminologyDeviceTypeCodes());
                Bundle edOverflowAndVentilated = fhirClient.search()
                        .byUrl(url)
                        .returnBundle(Bundle.class)
                        .execute();
                return edOverflowAndVentilated.getTotal();
            } catch (Exception ex) {
                this.logger.error("Could not retrieve ED/overflow count: " + ex.getMessage(), ex);
            }
        }

        return null;
    }
}
