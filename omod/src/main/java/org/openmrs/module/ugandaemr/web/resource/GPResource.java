package org.openmrs.module.ugandaemr.web.resource;

import org.openmrs.api.AdministrationService;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.openmrs.api.context.Context;

import java.util.ArrayList;
import java.util.List;

@RestController
public class GPResource {

    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            + "/gp", method = RequestMethod.GET)

    public ResponseEntity<Object> evaluate(@RequestParam(required = true, value = "property") String propertyName) {
        AdministrationService administrationService = Context.getAdministrationService();

        String query = "SELECT property_value FROM global_property WHERE property = '" + propertyName + "';";

        List<List<Object>> result = administrationService.executeSQL(query, true);

        if (!result.isEmpty()) {
            Object facilityName = result.get(0).get(0);
            PropertyResult propertyResult = new PropertyResult(facilityName);
            List<PropertyResult> resultList = new ArrayList<>();
            resultList.add(propertyResult);

            ResultObject resultObject = new ResultObject(resultList);
            return ResponseEntity.ok().body(resultObject);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    static class PropertyResult {
        private Object facilityName;
        public PropertyResult(Object facilityName) {
            this.facilityName = facilityName;
        }
        public Object getFacilityName() {
            return facilityName;
        }
        public void setFacilityName(Object facilityName) {
            this.facilityName = facilityName;
        }
    }
    static class ResultObject {
        private List<PropertyResult> results;

        public ResultObject(List<PropertyResult> results) {
            this.results = results;
        }
        public List<PropertyResult> getResults() {
            return results;
        }
        public void setResults(List<PropertyResult> results) {
            this.results = results;
        }
    }
}
