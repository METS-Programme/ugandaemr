package org.openmrs.module.ugandaemr.pharmacy.mapper;

import org.openmrs.module.patientqueueing.mapper.PatientQueueMapper;

import java.io.Serializable;
import java.util.Set;

public class PharmacyMapper extends PatientQueueMapper implements Serializable {

    Integer visitId;

    private String patientQueueUuid;

    private String encounterUuid;

    Set<DrugOrderMapper> drugOrderMappers;

    public PharmacyMapper() {
    }

    public Set<DrugOrderMapper> getOrderMapper() {
        return drugOrderMappers;
    }

    public void setDrugOrderMapper(Set<DrugOrderMapper> orderMapper) {
        this.drugOrderMappers = orderMapper;
    }

    public Integer getVisitId() {
        return visitId;
    }

    public void setVisitId(Integer visitId) {
        this.visitId = visitId;
    }

    public String getPatientQueueUuid() {
        return patientQueueUuid;
    }

    public void setPatientQueueUuid(String patientQueueUuid) {
        this.patientQueueUuid = patientQueueUuid;
    }

    public String getEncounterUuid() {
        return encounterUuid;
    }

    public void setEncounterUuid(String encounterUuid) {
        this.encounterUuid = encounterUuid;
    }
}