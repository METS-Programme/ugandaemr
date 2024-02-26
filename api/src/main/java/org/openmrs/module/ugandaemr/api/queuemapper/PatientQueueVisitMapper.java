package org.openmrs.module.ugandaemr.api.queuemapper;

import org.openmrs.module.patientqueueing.mapper.PatientQueueMapper;

import java.io.Serializable;
import java.util.List;

public class PatientQueueVisitMapper extends PatientQueueMapper implements Serializable {
    Integer visitId;
    List<Identifier> patientIdentifier;

    public Integer getVisitId() {
        return visitId;
    }

    public void setVisitId(Integer visitId) {
        this.visitId = visitId;
    }

    public List<Identifier> getPatientIdentifier() {
        return patientIdentifier;
    }

    public void setPatientIdentifier(List<Identifier> patientIdentifier) {
        this.patientIdentifier = patientIdentifier;
    }
}

