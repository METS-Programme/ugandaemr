package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.module.patientqueueing.model.PatientQueue;

public class IncompleteQueueDTO {
    private String uuid;

    private PatientQueue patientQueue;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public PatientQueue getPatientQueue() {
        return patientQueue;
    }

    public void setPatientQueue(PatientQueue patientQueue) {
        this.patientQueue = patientQueue;
    }
}
