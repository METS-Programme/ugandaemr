package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.ParseException;
import java.util.Date;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.PROCESSED_ORDER_WITH_RESULT_FOR_PATIENT_QUERY;

public class DisplayLabResultsFragmentController {

    protected final Log log = LogFactory.getLog(getClass());

    public DisplayLabResultsFragmentController() {
    }

    public void controller(@SpringBean FragmentModel pageModel, @RequestParam(value = "patientId", required = false) Patient patient) {
        pageModel.put("patientId", patient.getPatientId());
        pageModel.put("patientUuid", patient.getUuid());

    }

    /**
     * Get Lab Orders without Results
     *
     * @param patientId
     * @return
     * @throws IOException
     * @throws ParseException
     */
    public SimpleObject getOrderWithResult(@RequestParam(value = "patientId", required = false) Integer patientId) throws IOException, ParseException {

        Date date = new Date();
        return Context.getService(UgandaEMRService.class).getOrderResultsOnEncounter(PROCESSED_ORDER_WITH_RESULT_FOR_PATIENT_QUERY, patientId, true);
    }
}
