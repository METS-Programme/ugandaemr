package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.Order;

import java.io.Serializable;
import java.util.List;

public class ApproveOrder implements Serializable {

    String uuid;
    private List<Order> orders;

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
}
