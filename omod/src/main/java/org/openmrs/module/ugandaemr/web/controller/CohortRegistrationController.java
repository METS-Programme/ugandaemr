package org.openmrs.module.ugandaemr.web.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.util.JSONPObject;
import org.json.JSONObject;
import org.openmrs.Cohort;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;


import org.openmrs.Patient;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.CohortService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;


@Controller
public class CohortRegistrationController {

	private final Log log = LogFactory.getLog(CohortRegistrationController.class);

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/delete", method = RequestMethod.GET)
	@ResponseBody
	public SimpleObject deleteCohort(
			@RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);
		SimpleObject response = new SimpleObject();
		Context.getCohortService().voidCohort(cohort,"retired");


		response.add("message", "Cohort Deleted");

		return response;
	}

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/edit", method = RequestMethod.GET)
	@ResponseBody
	public SimpleObject editCohort(
			@RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);
		SimpleObject response = new SimpleObject();

		response.add("name", cohort.getName());
		response.add("description", cohort.getDescription());
		response.add("uuid", cohort.getUuid());

		return response;
	}

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/saveEdit", method = RequestMethod.POST)
	@ResponseBody
	public SimpleObject saveEditedCohort(HttpServletRequest request,@RequestBody String body,
										 @RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);

		JSONObject newBody  = new JSONObject(body);
		cohort.setName(newBody.getString("name"));
		cohort.setDescription(newBody.getString("description"));
		cohort.setUuid(newBody.getString("uuid"));

		Context.getCohortService().saveCohort(cohort);

		SimpleObject response = new SimpleObject();

		response.add("name", cohort.getName());
		response.add("description", cohort.getDescription());
		response.add("uuid", cohort.getUuid());

		return response;
	}

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/patientCohorts", method = RequestMethod.GET)
	@ResponseBody

	public Object getCohortsByPatientUuid(
			@RequestParam(required = true, value = "patientUuid") String patientUuid) {

		List<SimpleObject> cohortsList = new ArrayList<>();

		try {
			Patient patient = Context.getPatientService().getPatientByUuid(patientUuid);
			if (patient != null) {
				List<List<Object>> patientCohorts = getCohortsByPatient(patient);
				if (patientCohorts.isEmpty()) {
					return new ResponseEntity<>("Patient has no enrolled cohorts", HttpStatus.OK);
				}
				for (List<Object> cohort : patientCohorts) {
					SimpleObject cohortObject = new SimpleObject();
					cohortObject.add("display", cohort.get(0));
					cohortObject.add("enrollmentStatus", cohort.get(1));

					handleCohortSpecifics(cohort, cohortObject);
					cohortsList.add(cohortObject);
				}
			} else {
				return new ResponseEntity<>("Patient not found", HttpStatus.NOT_FOUND);
			}
		} catch (Exception e) {
			return new ResponseEntity<>("Error processing request", HttpStatus.INTERNAL_SERVER_ERROR);
		}
		return new ResponseEntity<>(cohortsList, HttpStatus.OK);
	}

	private void handleCohortSpecifics(List<Object> cohort, SimpleObject cohortObject) {
		String cohortName = cohort.get(0).toString();
		if (UgandaEMRConstants.HIV_PROGRAM.equalsIgnoreCase(cohortName)) {
			cohortObject.add("uuid", UgandaEMRConstants.HIV_PROGRAM_UUID);
			cohortObject.add("enrollmentFormUuid", UgandaEMRConstants.HIV_ENROLLMENT_FORM_UUID);
			cohortObject.add("discontinuationFormUuid", UgandaEMRConstants.HIV_DISCONTINUATION_FORM_UUID);
		} else if (UgandaEMRConstants.TB_PROGRAM.equalsIgnoreCase(cohortName)) {
			cohortObject.add("uuid", UgandaEMRConstants.TB_PROGRAM_UUID);
			cohortObject.add("enrollmentFormUuid", UgandaEMRConstants.DS_TB_ENROLLMENT_FORM_UUID);
			cohortObject.add("discontinuationFormUuid", UgandaEMRConstants.TB_DISCONTINUATION_FORM_UUID);
		}
	}
	private List<List<Object>> getCohortsByPatient(Patient patient) {
		CohortService cohortService = Context.getCohortService();
		AdministrationService administrationService = Context.getAdministrationService();
		String hqlQuery = "SELECT DISTINCT c.name AS display, c.description AS enrollmentStatus\n" +
				"FROM cohort c\n" +
				"         INNER JOIN cohort_member cm ON c.cohort_id = cm.cohort_id\n" +
				"         INNER JOIN person p ON cm.patient_id = p.person_id\n" +
				"         INNER JOIN cohort_type ct ON c.cohort_type_id = ct.cohort_type_id\n" +
				"WHERE cm.voided = 0\n" +
				"  AND ct.uuid = '1345c89c-8463-41e9-9cd0-8c14aa255ba8'\n" +
				"  AND p.uuid = '"+patient.getUuid()+"'\n" +
				"  AND NOT EXISTS (\n" +
				"    SELECT 1\n" +
				"    FROM program k\n" +
				"    INNER JOIN patient_program pp ON k.program_id = pp.program_id\n" +
				"    WHERE k.name = c.name\n" +
				"      AND pp.patient_id = p.person_id\n" +
				"  );";

		List res = administrationService.executeSQL(hqlQuery, true);

		return res;
	}
	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/patientHistoricalEnrollment", method = RequestMethod.GET)
	@ResponseBody
	public ResponseEntity<Object> getPatientHistoricalEnrollment(
			@RequestParam(required = true, value = "patientUuid") String patientUuid) {
		try {
			Patient patient = Context.getPatientService().getPatientByUuid(patientUuid);
			if (patient == null) {
				return new ResponseEntity<>("Patient not found", HttpStatus.NOT_FOUND);
			}
			List<List<Object>> enrollmentHistory = getPatientEnrollmentHistory(patient);
			List<SimpleObject> patientHistoricalEnrollment = processEnrollmentHistory(enrollmentHistory);
			return new ResponseEntity<>(patientHistoricalEnrollment, HttpStatus.OK);
		} catch (Exception e) {
			return new ResponseEntity<>("Error processing request", HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	private List<SimpleObject> processEnrollmentHistory(List<List<Object>> enrollmentHistory) {
		List<SimpleObject> patientHistoricalEnrollment = new ArrayList<>();

		for (List<Object> enrollment : enrollmentHistory) {
			SimpleObject enrollmentObject = new SimpleObject();
			enrollmentObject.put("enrollmentUuid", enrollment.get(0));
			LocalDateTime dateEnrolled = enrollment.get(1) == null ? null : convertToDate(enrollment.get(1));
			enrollmentObject.put("dateEnrolled",dateEnrolled );
			LocalDateTime dateCompleted = enrollment.get(2) == null ? null : convertToDate(enrollment.get(2));
			enrollmentObject.put("dateCompleted", dateCompleted);
			enrollmentObject.put("programName", enrollment.get(3));
			String programName = enrollment.get(3).toString();
			setProgramSpecificFields(enrollmentObject, programName);
			enrollmentObject.put("active", dateCompleted == null);
			patientHistoricalEnrollment.add(enrollmentObject);
		}
		return patientHistoricalEnrollment;
	}
	private void setProgramSpecificFields(SimpleObject enrollmentObject, String programName) {
		if (UgandaEMRConstants.HIV_PROGRAM.equalsIgnoreCase(programName)) {
			enrollmentObject.put("discontinuationFormUuid", UgandaEMRConstants.HIV_DISCONTINUATION_FORM_UUID);
			enrollmentObject.put("discontinuationFormName", UgandaEMRConstants.HIV_DISCONTINUATION_FORM_NAME);
			enrollmentObject.add("enrollmentFormUuid", UgandaEMRConstants.HIV_ENROLLMENT_FORM_UUID);
			enrollmentObject.put("enrollmentFormName", UgandaEMRConstants.HIV_ENROLLMENT_FORM_NAME);
			enrollmentObject.put("artStartDate", "2020-09-17");

		} else if (UgandaEMRConstants.TB_PROGRAM.equalsIgnoreCase(programName)) {
			enrollmentObject.put("discontinuationFormUuid", UgandaEMRConstants.TB_DISCONTINUATION_FORM_UUID);
			enrollmentObject.put("discontinuationFormName", UgandaEMRConstants.TB_DISCONTINUATION_FORM_NAME);
			enrollmentObject.add("enrollmentFormUuid", UgandaEMRConstants.DS_TB_ENROLLMENT_FORM_UUID);
			enrollmentObject.put("enrollmentFormName", UgandaEMRConstants.TB_ENROLLMENT_FORM_NAME);
		}
	}
	private List<List<Object>> getPatientEnrollmentHistory(Patient patient) {
		AdministrationService administrationService = Context.getAdministrationService();
		String query = "SELECT pp.uuid AS enrollmentUuid, pp.date_enrolled AS dateEnrolled, pp.date_completed AS dateCompleted, j.name AS programName FROM patient_program pp\n" +
				"INNER JOIN program j ON (j.program_id=pp.program_id)\n" +
				"INNER JOIN person p ON (pp.patient_id=p.person_id)\n" +
				"WHERE p.uuid='" + patient.getUuid() + "'";
		return administrationService.executeSQL(query, true);
	}
	private LocalDateTime convertToDate(Object dateObject) {
		if (dateObject instanceof List) {
			List<Integer> dateComponents = (List<Integer>) dateObject;
			return LocalDateTime.of(dateComponents.get(0), dateComponents.get(1), dateComponents.get(2),
					dateComponents.get(3), dateComponents.get(4), dateComponents.get(5));
		}
		return null;
	}
}