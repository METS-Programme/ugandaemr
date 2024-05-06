package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.api.LocationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.queuemapper.PatientQueueVisitMapper;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class ClinicianQueueListFragmentController {

    protected final Log log = LogFactory.getLog(getClass());

    public ClinicianQueueListFragmentController() {
        //Constructor
    }

    public void controller(@SpringBean FragmentModel pageModel, @SpringBean("locationService") LocationService locationService,UiSessionContext uiSessionContext) {

        String locationUUIDS = Context.getAdministrationService()
                .getGlobalProperty("ugandaemr.clinicianLocationUUIDS");

        List clinicianLocationUUIDList = Arrays.asList(locationUUIDS.split(","));

        pageModel.put("clinicianLocationUUIDList", clinicianLocationUUIDList);

        pageModel.put("locationList", (locationService.getRootLocations(false).get(0)).getChildLocations());
        pageModel.put("clinicianLocation", clinicianLocationUUIDList);
        pageModel.put("currentProvider", uiSessionContext.getCurrentProvider());
        pageModel.put("enablePatientQueueSelection", Context.getAdministrationService().getGlobalProperty("ugandaemr.enablePatientQueueSelection"));
    }

    public SimpleObject getEncounterId(@RequestParam(value = "patientQueueUuid", required = false) String patientQueueUuid) throws ParseException, IOException {
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        PatientQueue patientQueue = patientQueueingService.getPatientQueueByUuid(patientQueueUuid);
        ObjectMapper objectMapper = new ObjectMapper();
        String encounterId = "";
        if (patientQueue != null && patientQueue.getEncounter() != null) {
            encounterId = objectMapper.writeValueAsString(patientQueue.getEncounter().getEncounterId());
        } else {
            encounterId = objectMapper.writeValueAsString("");
        }
        return SimpleObject.create("encounterId", encounterId);
    }
}
