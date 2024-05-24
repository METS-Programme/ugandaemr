package org.openmrs.module.ugandaemr.api.lab.mapper;

import java.io.Serializable;
import java.util.List;

public class TestOrderModel implements Serializable {

    Integer unprocessedOrders;
    List<TestOrderMapper> testOrderMappers;

    public Integer getUnprocessedOrders() {
        return unprocessedOrders;
    }

    public void setUnprocessedOrders(Integer unprocessedOrders) {
        this.unprocessedOrders = unprocessedOrders;
    }

    public List<TestOrderMapper> getTestOrderMappers() {
        return testOrderMappers;
    }

    public void setTestOrderMappers(List<TestOrderMapper> testOrderMappers) {
        this.testOrderMappers = testOrderMappers;
    }
}
