package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.module.patientqueueing.model.PatientQueue;

import java.util.List;

public class IncompleteQueueDTO {
    private String uuid;

    private List<PatientQueue> patientQueues;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public List<PatientQueue> getPatientQueues() {
        return patientQueues;
    }

    public void setPatientQueues(List<PatientQueue> patientQueues) {
        this.patientQueues = patientQueues;
    }
}
