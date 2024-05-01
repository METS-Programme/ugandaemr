package org.openmrs.module.ugandaemr.web.customdto;

import org.openmrs.BaseOpenmrsObject;
import org.openmrs.Encounter;

import java.util.List;

public class DuplicateEncounter extends BaseOpenmrsObject {
    private List<Encounter> encounter;

    public List<Encounter> getEncounter() {
        return encounter;
    }

    public void setEncounter(List<Encounter> encounter) {
        this.encounter = encounter;
    }

    @Override
    public Integer getId() {
        return null;
    }

    @Override
    public void setId(Integer integer) {

    }
}
