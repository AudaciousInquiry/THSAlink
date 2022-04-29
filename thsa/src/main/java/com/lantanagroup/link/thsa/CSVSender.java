package com.lantanagroup.link.thsa;

import com.lantanagroup.link.FhirDataProvider;
import com.lantanagroup.link.FhirHelper;
import com.lantanagroup.link.GenericSender;
import com.lantanagroup.link.IReportSender;
import com.lantanagroup.link.auth.LinkCredentials;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.MeasureReport;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;

import javax.servlet.http.HttpServletRequest;

public class CSVSender extends GenericSender implements IReportSender {
  protected static final Logger logger = LoggerFactory.getLogger(CSVSender.class);

  @Override
  public void send(MeasureReport masterMeasureReport, HttpServletRequest request, Authentication auth, FhirDataProvider fhirDataProvider, Boolean sendWholeBundle) throws Exception {

    // TODO: Use Keith's CSV conversion code to convert Bundle to CSV

    String csv = "";

    this.sendContent(masterMeasureReport, fhirDataProvider, "text/csv", sendWholeBundle);

    FhirHelper.recordAuditEvent(request, fhirDataProvider, ((LinkCredentials) auth.getPrincipal()).getJwt(), FhirHelper.AuditEventTypes.Send, "Successfully sent report");
  }


  public String bundle(Bundle bundle, FhirDataProvider fhirDataProvider) {
    return "";
  }
}
