package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.Order;
import org.openmrs.module.patientqueueing.model.PatientQueue;

import java.io.Serializable;
import java.util.List;

public class ApproveOrder implements Serializable {

    String uuid;
    private List<Order> orders;

    private PatientQueue patientQueue;

    public List<Order> getOrders() {
        return orders;
    }

    public void setOrders(List<Order> orders) {
        this.orders = orders;
    }

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
