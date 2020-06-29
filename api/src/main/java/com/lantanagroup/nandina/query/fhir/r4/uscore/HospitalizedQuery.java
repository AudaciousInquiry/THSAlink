package com.lantanagroup.nandina.query.fhir.r4.uscore;

import com.lantanagroup.nandina.query.fhir.r4.AbstractQuery;
import org.hl7.fhir.r4.model.Resource;

import java.util.HashMap;
import java.util.Map;

public class HospitalizedQuery extends AbstractQuery {
  @Override
  public Integer execute() {
    if (!this.criteria.containsKey("reportDate")) return null;

    Map<String, Resource> resMap = this.getData();

    this.addContextData("hospitalized", this);

    return this.getCount(resMap);
  }

  /**
   * Queries for Patient resources where
   * - the Patient is in referenced in Condition.patient and Condition.code is a code from the Covid19 value set
   * - the Patient is referenced in Encounter.patient and Encounter.class is one of IMP,ACUTE,NONAC,OBSENC
   * The result is then further filtered to just those where the Encounter.date is equal to the reportDate
   * (Encounter.date search parameter is not working properly, so this is done procedurally)
   */
  @Override
  protected Map<String, Resource> queryForData() {
    try {
      String reportDate = this.criteria.get("reportDate");
      String url = String.format(
              "Patient?_has:Condition:patient:code=%s&_has:Encounter:patient:class=IMP,ACUTE,NONAC,OBSENC",
              properties.getTerminologyCovidCodes());

      Map<String, Resource> patientMap = this.search(url);
      // Encounter.date search parameter not working with current release of HAPI, so
      // weeding out encounters outside the reportDate manually
      HashMap<String, Resource> finalPatientMap = filterPatientsByEncounterDate(reportDate, patientMap);

      logger.debug(String.format("Patients matching encounter date: %s", finalPatientMap.values().size()));

      return finalPatientMap;

    } catch (Exception e) {
      logger.error(e.getMessage(), e);
      throw new RuntimeException(e);
    }
  }
}
