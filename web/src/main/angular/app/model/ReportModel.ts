import {Measure, MeasureReport} from "./fhir";

export class ReportModel {
    version: string;
    status: string;
    date: string;
    reportPeriodStart: Date;
    reportPeriodEnd: Date;
    reportMeasureList: {
        identifier: string
        bundleId: string;
        measure: Measure;
        measureReport: MeasureReport;
    }[];
}
