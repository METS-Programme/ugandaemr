package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.Order;

import java.io.Serializable;
import java.util.List;

public class ApproveOrder implements Serializable {

    String uuid;
    private List<Order> order;

    public List<Order> getOrder() {
        return order;
    }

    public void setOrder(List<Order> order) {
        this.order = order;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }
}
