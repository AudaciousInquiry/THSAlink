package com.lantanagroup.link.thsa;

import com.lantanagroup.link.Constants;
import com.lantanagroup.link.FhirDataProvider;
import com.lantanagroup.link.GenericAggregator;
import com.lantanagroup.link.IReportAggregator;
import com.lantanagroup.link.model.ReportContext;
import com.lantanagroup.link.model.ReportCriteria;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.MeasureReport;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


@Component
public class THSAAggregator extends GenericAggregator implements IReportAggregator {

  public final String NumTotBedsOcc = "numTotBedsOcc";
  public final String NumICUBedsOcc = "numICUBedsOcc";
  public final String NumVentUse = "numVentUse";
  public final String NumVent = "numVent";
  public final String NumTotBeds = "numTotBeds";
  public final String NumICUBeds = "numICUBeds";
  public final String NumTotBedsAvail = "numTotBedsAvail";
  public final String NumICUBedsAvail = "numICUBedsAvail";
  public final String NumVentAvail = "numVentAvail";

  @Autowired
  private FhirDataProvider provider;

  private CodeableConcept getTranslatedPopulationCoding(String groupCode) {
    // get the alias populationcode
    String populationCode = "";
    String populationDisplay = "";

    if (groupCode.equals("beds")) {
      populationCode = NumTotBedsOcc;
      // populationDisplay = "Hospital Beds Occupied";
    } else if (groupCode.equals("icu-beds")) {
      populationCode = NumICUBedsOcc;
      // populationDisplay = "ICU Bed Occupancy";
    } else if (groupCode.equals("vents")) {
      populationCode = NumVentUse;
      // populationDisplay = "Mechanical Ventilators in Use";
    }

    CodeableConcept codeableConcept = new CodeableConcept();
    Coding coding = new Coding();
    coding.setCode(populationCode);
    coding.setSystem(Constants.MeasuredValues);
    coding.setDisplay(populationDisplay);
    List<Coding> codingList = new ArrayList<>();
    codingList.add(coding);
    codeableConcept.setCoding(codingList);
    return codeableConcept;
  }

  @Override
  public MeasureReport generate(ReportCriteria criteria, ReportContext context, List<MeasureReport> patientMeasureReports) throws ParseException {

    HashMap usedInventoryMap = new HashMap();
    HashMap totalInventoryMap = new HashMap();
    // store the used counts
    MeasureReport measureReport = super.generate(criteria, context, patientMeasureReports);
    for (MeasureReport.MeasureReportGroupComponent group : measureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        usedInventoryMap.put(populationCode, population.getCount());
      }
    }
    // look up the inventory on the Fhir Server
    MeasureReport masterMeasureReport = provider.getMeasureReportById(context.getInventoryId());

    //store the total inventory
    for (MeasureReport.MeasureReportGroupComponent group : masterMeasureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if (populationCode.equals(NumTotBeds)) {
          totalInventoryMap.put(NumTotBeds, population.getCount());
          break;
        } else if (populationCode.equals(NumICUBeds)) {
          totalInventoryMap.put(NumICUBeds, population.getCount());
          break;
        } else if (populationCode.equals(NumVent)) {
          totalInventoryMap.put(NumVent, population.getCount());
        }
      }
    }
    // store the available counts
    for (MeasureReport.MeasureReportGroupComponent group1 : masterMeasureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group1.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if (populationCode.equals(NumTotBedsOcc)) {
          population.setCount((Integer) usedInventoryMap.get(populationCode));
        } else if (populationCode.equals(NumICUBedsOcc)) {
          population.setCount((Integer) usedInventoryMap.get(populationCode));
        } else if (populationCode.equals(NumVentUse)) {
          population.setCount((Integer) usedInventoryMap.get(populationCode));
        } else if (populationCode.equals(NumTotBedsAvail)) {
          int available = (Integer) totalInventoryMap.get(NumTotBeds) - (Integer) usedInventoryMap.get(NumTotBedsOcc);
          population.setCount(available);
        } else if (populationCode.equals(NumICUBedsAvail)) {
          int available = (Integer) totalInventoryMap.get(NumICUBeds) - (Integer) usedInventoryMap.get(NumICUBedsOcc);
          population.setCount(available);
        } else if (populationCode.equals(NumVentAvail)) {
          int available = (Integer) totalInventoryMap.get(NumVent) - (Integer) usedInventoryMap.get(NumVentUse);
          population.setCount(available);
        }
      }
    }
    return masterMeasureReport;
  }

  protected MeasureReport.MeasureReportGroupPopulationComponent getOrCreateGroupAndPopulation(MeasureReport
                                                                                                      masterReport, MeasureReport.MeasureReportGroupPopulationComponent
                                                                                                      reportPopulation, MeasureReport.MeasureReportGroupComponent reportGroup) {
    MeasureReport.MeasureReportGroupComponent masterReportGroupValue = null;
    MeasureReport.MeasureReportGroupPopulationComponent masteReportGroupPopulationValue;
    Optional<MeasureReport.MeasureReportGroupComponent> masterReportGroup;

    String populationCode = reportPopulation.getCode().getCoding().size() > 0 ? reportPopulation.getCode().getCoding().get(0).getCode() : "";
    if (!populationCode.equals("numerator")) {
      return null;
    }
    String groupCode = reportGroup.getCode().getCoding().size() > 0 ? reportGroup.getCode().getCoding().get(0).getCode() : "";
    CodeableConcept translatedPopulationCoding = getTranslatedPopulationCoding(groupCode);
    String translatedPopulationCode = translatedPopulationCoding.getCoding().get(0).getCode();

    /* find the group by code */
    masterReportGroup = masterReport.getGroup().stream().filter(group -> group.getCode().getCoding().size() > 0 && group.getCode().getCoding().get(0).getCode().equals(groupCode)).findFirst();
    // if empty find the group without the code
    if (masterReportGroup.isPresent()) {
      masterReportGroupValue = masterReportGroup.get();
    } else {
      if (groupCode.equals("")) {
        masterReportGroupValue = masterReport.getGroup().size() > 0 ? masterReport.getGroup().get(0) : null; // only one group with no code
      }
    }
    // if still empty create it
    if (masterReportGroupValue == null) {
      masterReportGroupValue = new MeasureReport.MeasureReportGroupComponent();
      masterReportGroupValue.setCode(reportGroup.getCode() != null ? reportGroup.getCode() : null);
      masterReport.addGroup(masterReportGroupValue);
    }
    // find population by code
    Optional<MeasureReport.MeasureReportGroupPopulationComponent> masterReportGroupPopulation = masterReportGroupValue.getPopulation().stream().filter(population -> population.getCode().getCoding().size() > 0 && population.getCode().getCoding().get(0).getCode().equals(translatedPopulationCode)).findFirst();
    // if empty create it
    if (masterReportGroupPopulation.isPresent()) {
      masteReportGroupPopulationValue = masterReportGroupPopulation.get();
    } else {
      masteReportGroupPopulationValue = new MeasureReport.MeasureReportGroupPopulationComponent();
      masteReportGroupPopulationValue.setCode(translatedPopulationCoding);
      masterReportGroupValue.addPopulation(masteReportGroupPopulationValue);
    }
    return masteReportGroupPopulationValue;
  }

  @Override
  protected void aggregatePatientReports(MeasureReport
                                                 masterMeasureReport, List<MeasureReport> patientMeasureReports) {
    for (MeasureReport patientMeasureReport : patientMeasureReports) {
      for (MeasureReport.MeasureReportGroupComponent group : patientMeasureReport.getGroup()) {
        for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
          // Check if group and population code exist in master, if not create
          MeasureReport.MeasureReportGroupPopulationComponent measureGroupPopulation = getOrCreateGroupAndPopulation(masterMeasureReport, population, group);
          // Add population.count to the master group/population count
          if (measureGroupPopulation != null) {
            measureGroupPopulation.setCount(measureGroupPopulation.getCount() + population.getCount());
          }
        }
      }
    }
  }
}