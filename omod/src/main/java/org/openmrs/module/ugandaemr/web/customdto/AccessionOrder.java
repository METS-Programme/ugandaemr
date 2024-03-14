package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.Order;

import java.io.Serializable;

public class AccessionOrder implements Serializable {
    private Order order;

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }
}
