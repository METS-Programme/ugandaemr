package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.module.ugandaemr.api.lab.util.TestResultModel;

import java.io.Serializable;
import java.util.List;

public class OrderResult implements Serializable {

     String uuid;
     String order;
     List<TestResultModel> result;

    public String getOrder() {
        return order;
    }

    public void setOrder(String order) {
        this.order = order;
    }

    public List<TestResultModel> getResult() {
        return result;
    }

    public void setResult(List<TestResultModel> result) {
        this.result = result;
    }


    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }
}
