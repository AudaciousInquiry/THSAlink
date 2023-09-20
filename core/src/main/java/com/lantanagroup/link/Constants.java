package com.lantanagroup.link;

import org.hl7.fhir.r4.model.Coding;

public class Constants {
  public static final String MainSystem = "https://nhsnlink.org";
  public static final String MHLSystem = "https://mhl.lantanagroup.com";
  public static final String ReportDefinitionTag = "report-definition";
  public static final String LoincSystemUrl = "http://loinc.org";
  public static final String DocRefCode = "55186-1";
  public static final String DocRefDisplay = "Measure Document";
  public static final String ReportPositionExtUrl = "http://hl7.org/fhir/uv/saner/StructureDefinition/GeoLocation";
  public static final String LinkUserTag = "link-user";
  public static final String NotesUrl = "https://www.cdc.gov/nhsn/fhir/nhsnlink/StructureDefinition/nhsnlink-report-note";
  public static final String ExcludedPatientExtUrl = "https://www.cdc.gov/nhsn/fhir/nhsnlink/StructureDefinition/nhsnlink-excluded-patient";
  public static final String DocumentReferenceVersionUrl = "https://www.cdc.gov/nhsn/fhir/nhsnlink/StructureDefinition/nhsnlink-report-version";
  public static final String Roles = "roles";
  public static final String FhirResourcesPackageName = "org.hl7.fhir.r4.model.";
  public static final String UuidPrefix = "urn:uuid:";
  public static final String ApplicablePeriodExtensionUrl = "https://www.lantanagroup.com/fhir/StructureDefinition/link-patient-list-applicable-period";
  public static final String QiCoreOrganizationProfileUrl = "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-organization";
  public static final String QiCorePatientProfileUrl = "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient";
  public static final String UsCoreEncounterProfileUrl = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter";
  public static final String UsCoreMedicationRequestProfileUrl = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-medicationrequest";
  public static final String UsCoreMedicationProfileUrl = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-medication";
  public static final String UsCoreConditionProfileUrl = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition";
  public static final String UsCoreObservationProfileUrl = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab";
  public static final String ReportBundleProfileUrl = "http://lantanagroup.com/fhir/nhsn-measures/StructureDefinition/nhsn-measurereport-bundle";
  public static final String IndividualMeasureReportProfileUrl = "http://lantanagroup.com/fhir/nhsn-measures/StructureDefinition/individual-measure-report";
  public static final String CensusProfileUrl = "http://lantanagroup.com/fhir/nhsn-measures/StructureDefinition/poi-list";
  public static final String MHLReportBundleProfileUrl = "http://lantanagroup.com/fhir/nih-measures/StructureDefinition/nih-measurereport-bundle";
  public static final String MHLIndividualMeasureReportProfileUrl = "http://lantanagroup.com/fhir/nih-measures/StructureDefinition/individual-measure-report";
  public static final String MHLCensusProfileUrl = "http://lantanagroup.com/fhir/nih-measures/StructureDefinition/poi-list";
  public static final String NationalProviderIdentifierSystemUrl = "http://hl7.org.fhir/sid/us-npi";
  public static final String IdentifierSystem = "urn:ietf:rfc:3986";
  public static final String TerminologyEndpointCode = "hl7-fhir-rest";
  public static final String TerminologyEndpointSystem = "http://terminology.hl7.org/CodeSystem/endpoint-connection-type";
  public static final String ConceptMappingExtension = "https://www.lantanagroup.com/fhir/StructureDefinition/mapped-concept";
  public static final String ExtensionCriteriaReference = "http://hl7.org/fhir/us/davinci-deqm/StructureDefinition/extension-criteriaReference";
  public static final String MeasuredValues = "http://hl7.org/fhir/uv/saner/CodeSystem/MeasuredValues";
  public static final String OriginalEncounterStatus = "https://www.lantanagroup.com/fhir/StructureDefinition/nhsn-encounter-original-status";
  public static final String ExtensionSupplementalData = "http://hl7.org/fhir/us/davinci-deqm/StructureDefinition/extension-supplementalData";
  public static final String patientDataTag = "patient-data";
  public static final String MeasureReportBundleProfileUrl = "https://www.lantanagroup.com/fhir/StructureDefinition/measure-report-bundle";
  public static final String LINK_VERSION_URL = "https://www.cdc.gov/nhsn/fhir/nhsnlink/StructureDefinition/link-version";
  public static final String MEASURE_VERSION_URL = "https://www.cdc.gov/nhsn/fhir/nhsnlink/StructureDefinition/measure-version";
  public static final String LinkUser = "link-user";
  public static final Coding EXPUNGE_TASK = new Coding().setCode("expunge-data").setSystem("https://nhsnlink.org").setDisplay("Expunge Data Task");
  public static final Coding MANUAL_EXPUNGE = new Coding().setCode("manual-expunge").setSystem("https://nhsnlink.org").setDisplay("Manual Expunge Task");
  public static final Coding REFRESH_PATIENT_LIST = new Coding().setCode("refresh-patient-list").setSystem("https://nhsnlink.org").setDisplay("Refresh Patient List Task");
  public static final Coding FILE_UPLOAD = new Coding().setCode("file-upload").setSystem("https://nhsnlink.org").setDisplay("Upload Data File");
  public static final Coding EXTERNAL_FILE_DOWNLOAD = new Coding().setCode("external-file-download").setSystem("https://nhsnlink.org").setDisplay("File Downloaded From Source");
  public static final Coding EXTERNAL_SOURCE_GENERIC = new Coding().setCode("generic-source").setSystem("https://nhsnlink.org").setDisplay("Generic External Data Source");
  public static final Coding EXTERNAL_SOURCE_PARKLAND = new Coding().setCode("parkland-source").setSystem("https://nhsnlink.org").setDisplay("Parkland External Data Source");
  public static final Coding CSV_FILE_TYPE = new Coding().setCode("csv-file-type").setSystem("https://nhsnlink.org").setDisplay("CSV File Type");
  public static final Coding EXCEL_FILE_TYPE = new Coding().setCode("excel-file-type").setSystem("https://nhsnlink.org").setDisplay("Excel File Types");
}
