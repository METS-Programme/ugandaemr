package org.openmrs.module.ugandaemr.web.resource;

import org.openmrs.api.APIAuthenticationException;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.PROCESSED_ORDER_WITH_RESULT_OF_ENCOUNTER_QUERY;

@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + EncounterTestResultsResource.DATASET)
public class EncounterTestResultsResource {
    public static final String DATASET = "/encountertestresults";

    @ExceptionHandler(APIAuthenticationException.class)
    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    public Object getTestResultsByEncounter(@RequestParam(required = true, value = "encounterUuid") String encounterUuid) {
        try {

            Integer encounterId = Context.getEncounterService().getEncounterByUuid(encounterUuid).getEncounterId();

            SimpleObject results =  Context.getService(UgandaEMRService.class).getOrderResultsOnEncounter(PROCESSED_ORDER_WITH_RESULT_OF_ENCOUNTER_QUERY, encounterId, true);
            return new ResponseEntity<SimpleObject>(results,HttpStatus.OK);

        } catch (Exception ex) {
            return new ResponseEntity<String>("{Error: " + ex.getMessage() + "}", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
