package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;


import java.text.ParseException;



public class PatientStabilityFragmentController {

    private static final Log log = LogFactory.getLog(PatientStabilityFragmentController.class);

    public void controller(FragmentModel model, @RequestParam(value = "patientId", required = false) Patient patient, @RequestParam(value = "visitId", required = false) Visit visit, @RequestParam(value = "encounterId", required = false) Encounter encounter, UiUtils ui) throws ParseException {

    }
}
