package org.openmrs.module.ugandaemr.fragment.controller;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.ConceptService;
import org.openmrs.api.ObsService;
import org.openmrs.api.PersonService;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.ui.framework.annotation.FragmentParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;

/**
 * Created by ssmusoke on 26/01/2016.
 */
public class PatientSummaryFragmentController {


	private static final Log log = LogFactory.getLog(PatientSummaryFragmentController.class);

	public void controller(FragmentConfiguration config,
						   FragmentModel model, @FragmentParam("patientId") Patient patient) throws ParseException {
		model.put("healthCenterName", Context.getAdministrationService().getGlobalProperty(UgandaEMRConstants.GP_HEALTH_CENTER_NAME));

		model.addAttribute("patientUUID", Context.getAdministrationService().executeSQL("select uuid from person where person_id=" + patient.getId(), true).get(0).get(0));
	}
}
