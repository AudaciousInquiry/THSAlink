package com.lantanagroup.link;

import com.lantanagroup.link.model.ReportContext;
import com.lantanagroup.link.model.ReportCriteria;
import org.hl7.fhir.r4.model.*;

import java.text.ParseException;
import java.util.List;
import java.util.Optional;

public abstract class GenericAggregator implements IReportAggregator {

  protected abstract void aggregatePatientReports(MeasureReport masterMeasureReport, List<MeasureReport> patientMeasureReports);

  @Override
  public MeasureReport generate(ReportCriteria criteria, ReportContext context, List<MeasureReport> patientMeasureReports) throws ParseException {
    // Create the master measure report
    MeasureReport masterMeasureReport = new MeasureReport();
    masterMeasureReport.setId(context.getReportId());
    masterMeasureReport.setType(MeasureReport.MeasureReportType.SUBJECTLIST);
    masterMeasureReport.setStatus(MeasureReport.MeasureReportStatus.COMPLETE);
    masterMeasureReport.setPeriod(new Period());
    masterMeasureReport.getPeriod().setStart(Helper.parseFhirDate(criteria.getPeriodStart()));
    masterMeasureReport.getPeriod().setEnd(Helper.parseFhirDate(criteria.getPeriodEnd()));
    masterMeasureReport.setMeasure(context.getMeasure().getUrl());
    aggregatePatientReports(masterMeasureReport, patientMeasureReports);
    createGroupsFromMeasure(masterMeasureReport, context);
    return masterMeasureReport;
  }

  protected MeasureReport.MeasureReportGroupPopulationComponent getOrCreateGroupAndPopulation(MeasureReport masterReport, MeasureReport.MeasureReportGroupPopulationComponent reportPopulation, MeasureReport.MeasureReportGroupComponent reportGroup) {

    String populationCode = reportPopulation.getCode().getCoding().size() > 0 ? reportPopulation.getCode().getCoding().get(0).getCode() : "";
    String groupCode = reportGroup.getCode().getCoding().size() > 0 ? reportGroup.getCode().getCoding().get(0).getCode() : "";

    MeasureReport.MeasureReportGroupComponent masterReportGroupValue = null;
    MeasureReport.MeasureReportGroupPopulationComponent masteReportGroupPopulationValue;
    // find the group by code
    Optional<MeasureReport.MeasureReportGroupComponent> masterReportGroup;
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
    Optional<MeasureReport.MeasureReportGroupPopulationComponent> masterReportGroupPopulation = masterReportGroupValue.getPopulation().stream().filter(population -> population.getCode().getCoding().size() > 0 && population.getCode().getCoding().get(0).getCode().equals(populationCode)).findFirst();
    // if empty create it
    if (masterReportGroupPopulation.isPresent()) {
      masteReportGroupPopulationValue = masterReportGroupPopulation.get();
    } else {
      masteReportGroupPopulationValue = new MeasureReport.MeasureReportGroupPopulationComponent();
      masteReportGroupPopulationValue.setCode(reportPopulation.getCode());
      masterReportGroupValue.addPopulation(masteReportGroupPopulationValue);
    }
    return masteReportGroupPopulationValue;
  }

  protected void createGroupsFromMeasure(MeasureReport masterMeasureReport, ReportContext context) {
    // if there are no groups generated then gets them from the measure
    if (masterMeasureReport.getGroup().size() == 0) {
      Bundle bundle = context.getReportDefBundle();
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
            populationComponent.setCode(population.getCode());
            populationComponent.setCount(0);
            groupComponent.addPopulation(populationComponent);
          });
          masterMeasureReport.addGroup(groupComponent);
        });
      }
    }
  }
}