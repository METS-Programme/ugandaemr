package org.openmrs.module.ugandaemr.htmlformentry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.OrderType;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.APIException;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.CustomFormSubmissionAction;
import org.openmrs.module.htmlformentry.FormEntryContext;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.metadata.core.Programs;

/**
 * Enrolls patients into the MCH program
 */
public class ExposedInfantClinicalEncounterEnrollmentPostSubmissionAction implements CustomFormSubmissionAction {
    UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);

    @Override
    public void applyAction(FormEntrySession session) {
        FormEntryContext.Mode mode = session.getContext().getMode();
        if (!(mode.equals(FormEntryContext.Mode.ENTER) || mode.equals(FormEntryContext.Mode.EDIT))) {
            return;
        }
        if (ugandaEMRService.getPreviousQueue(session.getPatient(), session.getEncounter().getLocation(), PatientQueue.Status.PENDING) != null) {
            ugandaEMRService.processLabTestOrdersFromEncounterObs(session, true);

            ugandaEMRService.processDrugOrdersFromEncounterObs(session, true);
        }


    }
}