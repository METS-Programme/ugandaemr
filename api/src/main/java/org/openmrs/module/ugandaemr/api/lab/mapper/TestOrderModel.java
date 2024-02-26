package org.openmrs.module.ugandaemr.api.lab.mapper;

import java.io.Serializable;
import java.util.List;

public class TestOrderModel implements Serializable {
    List<TestOrderMapper> testOrderMappers;

    public List<TestOrderMapper> getTestOrderMappers() {
        return testOrderMappers;
    }

    public void setTestOrderMappers(List<TestOrderMapper> testOrderMappers) {
        this.testOrderMappers = testOrderMappers;
    }
}
