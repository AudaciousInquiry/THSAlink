package com.lantanagroup.nandina.controller;

import ca.uhn.fhir.rest.client.api.IGenericClient;
import com.lantanagroup.nandina.*;
import com.lantanagroup.nandina.model.QueryReport;
import com.lantanagroup.nandina.query.IPrepareQuery;
import com.lantanagroup.nandina.query.QueryFactory;
import org.apache.commons.io.IOUtils;
import org.hl7.fhir.r4.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerException;
import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

@RestController
public class ReportController extends BaseController {
  private static final Logger logger = LoggerFactory.getLogger(ReportController.class);

  @Autowired
  private JsonProperties jsonProperties;

  /**
   * Uses reflection to determine what class should be used to execute the requested query/className, and
   * executes the specified query, returning the result.
   *
   * @param className
   * @param reportDate
   * @param overflowLocations
   * @return
   */
  private Object executeQuery(String className, Map<String, String> criteria, Map<String, Object> contextData, IGenericClient fhirClient, Authentication authentication) {
    if (className == null || className.isEmpty()) return null;

    try {
      FhirHelper.recordAuditEvent(
              fhirClient,
              authentication,
              className,
              "ReportController/executeQuery()",
              "Generate Report: " + criteria,
              "Generate Report",
              "Successful Report Generated");

      return QueryFactory.executeQuery(className, jsonProperties, fhirClient, criteria, contextData);
    } catch (ClassNotFoundException ex) {
      logger.error("Could not find class for query named " + className, ex);
    } catch (Exception ex) {
      logger.error("Could not execute query class for query " + className, ex);
    }

    return null;
  }

  private void executePrepareQuery(String className, Map<String, String> criteria, Map<String, Object> contextData, IGenericClient fhirClient, Authentication authentication) {
    if (className == null || className.isEmpty()) return;

    try {
      IPrepareQuery executor = QueryFactory.newPrepareQueryInstance(className, jsonProperties, fhirClient, criteria, contextData);
      executor.execute();
    } catch (ClassNotFoundException ex) {
      logger.error("Could not find class for prepare-query named " + className, ex);
    } catch (Exception ex) {
      logger.error("Could not execute query class for prepare-query " + className, ex);
    }
  }

  private Map<String, String> getCriteria(HttpServletRequest request, QueryReport report) {
    java.util.Enumeration<String> parameterNames = request.getParameterNames();
    Map<String, String> criteria = new HashMap<>();

    while (parameterNames.hasMoreElements()) {
      String paramName = parameterNames.nextElement();
      String[] paramValues = request.getParameterValues(paramName);
      criteria.put(paramName, String.join(",", paramValues));
    }

    if (report.getDate() != null && !report.getDate().isEmpty()) {
      criteria.put("reportDate", report.getDate());
    }

    return criteria;
  }

  @PostMapping("/api/query")
  public QueryReport getQuestionnaireResponse(Authentication authentication, HttpServletRequest request, @RequestBody() QueryReport report) throws Exception {
    IGenericClient fhirQueryClient = this.getFhirQueryClient(authentication, request);
    Map<String, String> criteria = this.getCriteria(request, report);

    logger.debug("Generating report, including criteria: " + criteria.toString());

    HashMap<String, Object> contextData = new HashMap<>();
    contextData.put("response", report);

    // Execute the prepare-query plugin if configured
    this.executePrepareQuery(jsonProperties.getPrepareQuery(), criteria, contextData, fhirQueryClient, authentication);

    // Loop through each question and try to find an answer
    for (String questionId : report.getQuestions()) {
      String className = jsonProperties.getQuery().get(questionId);

      if (className != null && !className.isEmpty()) {
        Object answer = this.executeQuery(className, criteria, contextData, fhirQueryClient, authentication);
        report.setAnswer(questionId, answer);
      }

      if (report.getAnswers().get(questionId) == null) {
        report.setAnswer(questionId, jsonProperties.getField().get(JsonProperties.DEFAULT).get(questionId));
      }
    }

    return report;
  }

  private String convertToCSV(QuestionnaireResponse questionnaireResponse) throws TransformerException, FileNotFoundException {
    String xml = this.ctx.newXmlParser().encodeResourceToString(questionnaireResponse);
    TransformHelper transformHelper = new TransformHelper();
    return transformHelper.convert(xml);
  }

  @PostMapping("/api/convert")
  public void convertSimpleReport(@RequestBody() QueryReport report, HttpServletResponse response, Authentication authentication, HttpServletRequest request) throws Exception {
    PIHCQuestionnaireResponseGenerator generator = new PIHCQuestionnaireResponseGenerator(report);
    QuestionnaireResponse questionnaireResponse = generator.generate();
    String responseBody = null;
    IGenericClient fhirQueryClient = this.getFhirQueryClient(authentication, request);

    if (jsonProperties.getExportFormat().equals("json")) {
      responseBody = this.ctx.newJsonParser().encodeResourceToString(questionnaireResponse);
      response.setContentType("application/json");
      response.setHeader("Content-Disposition", "attachment; filename=\"report.json\"");
    } else if (jsonProperties.getExportFormat().equals("xml")) {
      responseBody = this.ctx.newXmlParser().encodeResourceToString(questionnaireResponse);
      response.setContentType("application/xml");
      response.setHeader("Content-Disposition", "attachment; filename=\"report.xml\"");
    } else {
      responseBody = this.convertToCSV(questionnaireResponse);
      response.setContentType("text/plain");
      response.setHeader("Content-Disposition", "attachment; filename=\"report.csv\"");
    }

    FhirHelper.recordAuditEvent(fhirQueryClient, authentication, "report." + jsonProperties.getExportFormat(), "ReportController/convertSimpleReport()",
            "Export to File: " + jsonProperties.getExportFormat() + " format", "Export To File", "Successfully Exported File");

    InputStream is = new ByteArrayInputStream(responseBody.getBytes());
    IOUtils.copy(is, response.getOutputStream());
    response.flushBuffer();
  }
}
