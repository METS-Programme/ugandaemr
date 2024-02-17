package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.LocationTag;
import org.openmrs.Order;
import org.openmrs.module.patientqueueing.model.PatientQueue;

import java.io.Serializable;
import java.util.List;

public class PatientQueueStatistic implements Serializable {

    String uuid;
    LocationTag locationTag;
    Integer pending;
    Integer serving;
    Integer completed;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public LocationTag getLocationTag() {
        return locationTag;
    }

    public void setLocationTag(LocationTag locationTag) {
        this.locationTag = locationTag;
    }

    public Integer getPending() {
        return pending;
    }

    public void setPending(Integer pending) {
        this.pending = pending;
    }

    public Integer getServing() {
        return serving;
    }

    public void setServing(Integer serving) {
        this.serving = serving;
    }

    public Integer getCompleted() {
        return completed;
    }

    public void setCompleted(Integer completed) {
        this.completed = completed;
    }
}
