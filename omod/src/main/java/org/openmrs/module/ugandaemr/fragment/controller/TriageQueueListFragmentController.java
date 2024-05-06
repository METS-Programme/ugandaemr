package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Patient;
import org.openmrs.Visit;
import org.openmrs.api.VisitService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.TRIAGE_LOCATION_UUID;

public class TriageQueueListFragmentController {

    protected final Log log = LogFactory.getLog(TriageQueueListFragmentController.class);

    public TriageQueueListFragmentController() {
    }

    public void controller(FragmentConfiguration config, @SpringBean FragmentModel pageModel, UiSessionContext uiSessionContext) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String dateStr = sdf.format(new Date());
        pageModel.addAttribute("currentDate", dateStr);
        pageModel.addAttribute("locationSession", uiSessionContext.getSessionLocation().getUuid());
        pageModel.addAttribute("triageLocation", TRIAGE_LOCATION_UUID);
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
