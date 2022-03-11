package org.openmrs.module.ugandaemr.htmlformentry;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.APIException;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.CustomFormSubmissionAction;
import org.openmrs.module.htmlformentry.FormEntryContext;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.ugandaemr.metadata.core.Programs;

import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Enrolls patients into the SMS program
 */
public class SMSProgramEnrollmentPostSubmissionAction implements CustomFormSubmissionAction {
	
	@Override
	public void applyAction(FormEntrySession session) {
		
		ProgramWorkflowService service = Context.getService(ProgramWorkflowService.class);
		Program smsProgram = service.getProgramByUuid(Programs.SMS_PROGRAM.uuid());
		if (smsProgram == null) {
			throw new APIException("The SMS Program does not exist. Please restore it if deleted");
		}
		Patient patient = session.getPatient();
		Obs date_of_exit = getObsByConceptFromSet(session.getEncounter().getAllObs(false),165276);

		//enroll only on initial form submission
		if (session.getContext().getMode().equals(FormEntryContext.Mode.ENTER)) {
			//return if patient is already enrolled in the program
			for (PatientProgram patientProgram : service.getPatientPrograms(patient, smsProgram, null, null, null, null,
					false)) {
				if (patientProgram.getActive() && date_of_exit!=null) {
					// if active but with a date of exit
					patientProgram.setDateCompleted(date_of_exit.getValueDate());
					service.savePatientProgram(patientProgram);
				}else if(patientProgram.getActive() && date_of_exit==null){
					//when active and date of exit is provided
					return;
				}
			}

			if(date_of_exit==null){
				//enroll into program
				PatientProgram enrollment = new PatientProgram();
				enrollment.setProgram(smsProgram);
				enrollment.setPatient(patient);
				enrollment.setDateEnrolled(session.getEncounter().getEncounterDatetime());
				service.savePatientProgram(enrollment);
			}

		}else if(session.getContext().getMode().equals(FormEntryContext.Mode.EDIT) && date_of_exit!=null){
			//exit on edit and date of exit is provided
			for (PatientProgram patientProgram : service.getPatientPrograms(patient, smsProgram, null, null, null, null, false)) {
				if (patientProgram.getActive()) {
					patientProgram.setDateCompleted(date_of_exit.getValueDate());
					service.savePatientProgram(patientProgram);
				}
			}

		}

	}

	private Obs getObsByConceptFromSet(Set<Obs> obsSet, Integer lookupConceptId) {
		for (Obs obs : obsSet) {
			if (lookupConceptId.equals(obs.getConcept().getConceptId())) {
				return obs;
			}
		}
		return null;
	}
}
