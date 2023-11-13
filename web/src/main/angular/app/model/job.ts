import {JobNote} from "./job-note";

export interface Job {
    id: string;
    status: string;
    type: string;
    created: Date;
    lastUpdated: Date;
    notes: JobNote[];
}