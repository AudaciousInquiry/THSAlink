package com.lantanagroup.link.thsa;

import com.lantanagroup.link.Constants;
import com.lantanagroup.link.FhirDataProvider;
import com.lantanagroup.link.GenericAggregator;
import com.lantanagroup.link.IReportAggregator;
import com.lantanagroup.link.config.thsa.THSAConfig;
import com.lantanagroup.link.model.ReportContext;
import com.lantanagroup.link.model.ReportCriteria;
import org.hl7.fhir.r4.model.*;
import org.hl7.fhir.r4.model.MeasureReport.MeasureReportGroupComponent;
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

  @Autowired
  private THSAConfig thsaConfig;

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
  public MeasureReport generate(ReportCriteria criteria, ReportContext reportContext, ReportContext.MeasureContext measureContext) throws ParseException {

    HashMap<String, Integer> usedInventoryMap = new HashMap<>();
    HashMap<String, Integer> totalInventoryMap = new HashMap<>();

    // store the occupied counts from aggregated individual MeasureReport's
    // ONLY beds & icu beds at this point are available, via CQL so restricting to that here.
    MeasureReport measureReport = super.generate(criteria, reportContext, measureContext);
    for (MeasureReport.MeasureReportGroupComponent group : measureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if ( populationCode.equals(NumTotBedsOcc) || populationCode.equals(NumICUBedsOcc)) {
          usedInventoryMap.put(populationCode, population.getCount());
        }
      }
    }

    // look up the inventory on the Fhir Server but save the original ID before to restore it
    String id = measureReport.getId();
    MeasureReport masterMeasureReport = provider.getMeasureReportById(thsaConfig.getDataMeasureReportId());
    masterMeasureReport.setId(id);

    // Look up the Vent inventory on the Data Store FHIR server
    MeasureReport ventMeasureReport = provider.getMeasureReportById(thsaConfig.getVentInventoryReportId());
    // Store the Total # of Vents and # of Vents occupied/used from vent inventory report
    for (MeasureReport.MeasureReportGroupComponent group : ventMeasureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if (populationCode.equals(NumVent)) {
          totalInventoryMap.put(NumVent, population.getCount());
        } else if (populationCode.equals(NumVentUse)) {
          usedInventoryMap.put(populationCode, population.getCount());
        }
      }
    }

    // ALM 06June2023
    // Parkland Inventory Report Import will set the inventory data to just have vents
    // group.  Here we check for and then add beds & icu-beds to the template before we
    // populate below
    // TODO - we need total # beds & icu beds to start from somehow.  I think we are still waiting
    // on some CSV report for this?  alm 21June2023
    // Could be we store this as a different "inventory report".  Have an inventory report for vents,
    // one for beds, one for icu-beds.  Pull those here to get the number of each as a start.
    List<MeasureReportGroupComponent> groups = masterMeasureReport.getGroup();
    List<String> groupCodes = new ArrayList<>();
    for (MeasureReportGroupComponent group : groups) {
      String groupCode = group.getCode().getCodingFirstRep().getCode();
      groupCodes.add(groupCode);
    }

    // Add empty beds section if needed
    if (!groupCodes.contains("beds")) {
      MeasureReportGroupComponent group = getGroupComponent("beds");
      group.addPopulation(getPopulationComponent("NumTotBeds"));
      group.addPopulation(getPopulationComponent("NumTotBedsOcc"));
      group.addPopulation(getPopulationComponent("NumTotBedsAvail"));
      masterMeasureReport.addGroup(group);
    }

    if (!groupCodes.contains("icu-beds")) {
      MeasureReportGroupComponent group = getGroupComponent("icu-beds");
      group.addPopulation(getPopulationComponent("NumICUBeds"));
      group.addPopulation(getPopulationComponent("NumICUBedsOcc"));
      group.addPopulation(getPopulationComponent("NumICUBedsAvail"));
      masterMeasureReport.addGroup(group);
    }

    //store the total inventory this is coming from inventorydata
    // Total vent inventory set above
    for (MeasureReport.MeasureReportGroupComponent group : masterMeasureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if (populationCode.equals(NumTotBeds)) {
          totalInventoryMap.put(NumTotBeds, population.getCount());
        } else if (populationCode.equals(NumICUBeds)) {
          totalInventoryMap.put(NumICUBeds, population.getCount());
        } /* THIS now populated via ventMeasureReport
        else if (populationCode.equals(NumVent)) {
          totalInventoryMap.put(NumVent, population.getCount());
        } */
      }
    }

    // compute/store the available counts
    for (MeasureReport.MeasureReportGroupComponent group1 : masterMeasureReport.getGroup()) {
      for (MeasureReport.MeasureReportGroupPopulationComponent population : group1.getPopulation()) {
        String populationCode = population.getCode().getCoding().size() > 0 ? population.getCode().getCoding().get(0).getCode() : "";
        if (populationCode.equals(NumTotBedsOcc)) {
          population.setCount(usedInventoryMap.get(populationCode) != null ? usedInventoryMap.get(populationCode) : 0);
        } else if (populationCode.equals(NumICUBedsOcc)) {
          population.setCount(usedInventoryMap.get(populationCode) != null ? usedInventoryMap.get(populationCode) : 0);
        } else if (populationCode.equals(NumVentUse)) {
          population.setCount(usedInventoryMap.get(populationCode) != null ? usedInventoryMap.get(populationCode) : 0);
        } else if (populationCode.equals(NumTotBedsAvail)) {
          int available = (totalInventoryMap.get(NumTotBeds) != null ? totalInventoryMap.get(NumTotBeds) : 0) - (usedInventoryMap.get(NumTotBedsOcc) != null ? usedInventoryMap.get(NumTotBedsOcc) : 0);
          population.setCount(available);
        } else if (populationCode.equals(NumICUBedsAvail)) {
          int available = (totalInventoryMap.get(NumICUBeds) != null ? totalInventoryMap.get(NumICUBeds) : 0) - (usedInventoryMap.get(NumICUBedsOcc) != null ? usedInventoryMap.get(NumICUBedsOcc) : 0);
          population.setCount(available);
        } else if (populationCode.equals(NumVentAvail)) {
          int available = (totalInventoryMap.get(NumVent) != null ? totalInventoryMap.get(NumVent) : 0) - (usedInventoryMap.get(NumVentUse) != null ? usedInventoryMap.get(NumVentUse) : 0);
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
  protected void createGroupsFromMeasure(MeasureReport masterMeasureReport, ReportContext.MeasureContext measureContext) {
    // if there are no groups generated then gets them from the measure
    if (masterMeasureReport.getGroup().size() == 0) {
      Bundle bundle = measureContext.getReportDefBundle();
      Optional<Bundle.BundleEntryComponent> measureEntry = bundle.getEntry().stream()
              .filter(e -> e.getResource().getResourceType() == ResourceType.Measure)
              .findFirst();

      if (measureEntry.isPresent()) {
        Measure measure = (Measure) measureEntry.get().getResource();
        measure.getGroup().forEach(group -> {
          MeasureReport.MeasureReportGroupComponent groupComponent = new MeasureReport.MeasureReportGroupComponent();
          groupComponent.setCode(group.getCode());
          group.getPopulation().forEach(population -> {
            MeasureReport.MeasureReportGroupPopulationComponent populationComponent = new MeasureReport.MeasureReportGroupPopulationComponent();
            if (!population.getCode().equals("numerator")) {
              if (group.getCode().getCoding() != null && group.getCode().getCoding().size() > 0) {
                populationComponent.setCode(getTranslatedPopulationCoding(group.getCode().getCoding().get(0).getCode()));
                populationComponent.setCount(0);
                groupComponent.addPopulation(populationComponent);
              }
            }

          });
          masterMeasureReport.addGroup(groupComponent);
        });
      }
    }
  }

  @Override
  protected void aggregatePatientReports(MeasureReport masterMeasureReport, List<MeasureReport> measureReports) {
    for (MeasureReport patientMeasureReportResource : measureReports) {
      for (MeasureReport.MeasureReportGroupComponent group : patientMeasureReportResource.getGroup()) {
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

  private MeasureReportGroupComponent getGroupComponent(String type) {
    MeasureReportGroupComponent group = new MeasureReport.MeasureReportGroupComponent();
    Coding coding = new Coding();
    coding.setSystem(Constants.MeasuredValues);
    coding.setCode(type);
    group.setCode(new CodeableConcept(coding));

    return group;
  }

  private MeasureReport.MeasureReportGroupPopulationComponent getPopulationComponent(String type) {
    MeasureReport.MeasureReportGroupPopulationComponent pop = new MeasureReport.MeasureReportGroupPopulationComponent();
    Coding coding = new Coding();
    coding.setSystem(Constants.MeasuredValues);
    coding.setCode(type);
    coding.setDisplay(type);
    pop.setCode(new CodeableConcept(coding));
    pop.setCount(0);

    return pop;
  }
}
