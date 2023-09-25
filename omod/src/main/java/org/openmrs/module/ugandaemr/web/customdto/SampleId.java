package org.openmrs.module.ugandaemr.web.customdto;

import java.io.Serializable;

public class SampleId implements Serializable {
    String sampleId;

    public String getSampleId() {
        return sampleId;
    }

    public void setSampleId(String sampleId) {
        this.sampleId = sampleId;
    }
}
