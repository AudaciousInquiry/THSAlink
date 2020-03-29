package com.lantanagroup.flintlock;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import ca.uhn.fhir.rest.client.api.IGenericClient;
import com.lantanagroup.flintlock.ecr.ElectronicCaseReport;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Condition;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.ValueSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.lantanagroup.flintlock.client.ValueSetQueryClient;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.parser.IParser;

@RestController
public class FlintlockController {
	
	private static final Logger logger = LoggerFactory.getLogger(FlintlockController.class);
	public String conformanceServerBase = "https://flintlock-fhir.lantanagroup.com/fhir";
	public String targetServerBase = "http://hapi.fhir.org/baseR4";
	FhirContext ctx = FhirContext.forR4();
	IParser xmlParser = ctx.newXmlParser();
	IParser jsonParser = ctx.newJsonParser();
	ValueSetQueryClient vsClient;
	IGenericClient targetClient;
	String symptomsValueSetUrl = "http://flintlock-fhir.lantanagroup.com/fhir/ValueSet/symptoms";

	public FlintlockController() {
		this.vsClient = new ValueSetQueryClient(conformanceServerBase, targetServerBase);
		this.targetClient = this.ctx.newRestfulGenericClient(targetServerBase);
	}
	
	@RequestMapping("fhir")
	public String transaction (@RequestBody String resourceStr) throws JsonProcessingException {
		IBaseResource resource; 
		boolean isJson = false;
		if (resourceStr.startsWith("{")) {
			resource = jsonParser.parseResource(resourceStr);
			isJson = true;
		} else {
			resource = xmlParser.parseResource(resourceStr);
		}
		String parsedResource = xmlParser.encodeResourceToString(resource);
		logger.info(parsedResource);
		return parsedResource;
	}
	
	@GetMapping(value = "report", produces = "application/xml")
	public String report() {
		ValueSet symptomsVs = vsClient.getValueSet(symptomsValueSetUrl);
		logger.info("Retrieved value set", symptomsVs.getUrl());
		List<Condition> resultList = vsClient.conditionCodeQuery(symptomsVs);
		Map<String,Patient> patientRefs = getUniquePatientReferences(resultList);
		StringWriter str = new StringWriter();
		PrintWriter out = new PrintWriter(str);
		out.println("<Patients>");
		for (String p : patientRefs.keySet()) {
			out.println(p);
		}
		out.println("</Patients>");
		out.close();
		return str.toString();
	}

	@GetMapping(value = "test/{patientId}", produces = "application/xml")
	public String test(@PathVariable("patientId") String patientId) {
		Patient subject = (Patient) this.targetClient
				.read()
				.resource(Patient.class)
				.withId(patientId)
				.execute();
		ElectronicCaseReport ecr = new ElectronicCaseReport(this.targetClient, subject, null, null);
		Bundle ecrDoc = ecr.compile();
		return this.ctx.newXmlParser().encodeResourceToString(ecrDoc);
	}
	
	private Map<String,Patient> getUniquePatientReferences(List<Condition> conditions){
		HashMap<String,Patient> patients = new HashMap<String,Patient>();
		for (Condition c : conditions) {
			String key = c.getSubject().getReference();
			Patient p = (Patient)c.getSubject().getResource();
			patients.put(key, p);
		}
		return patients;
	}
}
