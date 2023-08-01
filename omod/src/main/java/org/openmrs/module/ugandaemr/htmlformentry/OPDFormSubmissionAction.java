package org.openmrs.module.ugandaemr.htmlformentry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifierType;
import org.openmrs.PatientIdentifier;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.CustomFormSubmissionAction;
import org.openmrs.module.htmlformentry.FormEntryContext.Mode;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.util.OpenmrsUtil;

import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * Enrolls patients into DSDM programs
 */
public class OPDFormSubmissionAction implements CustomFormSubmissionAction {

    private static final Log log = LogFactory.getLog(OPDFormSubmissionAction.class);

    @Override
    public void applyAction(FormEntrySession session) {
        Patient patient = session.getPatient();
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        PatientService patientService = Context.getPatientService();
        PatientIdentifierType opdpatientIdentifierType = patientService.getPatientIdentifierTypeByUuid("be8f222a-3751-4f93-8c74-3aff399c19b6");
        Mode mode = session.getContext().getMode();

        if (!(mode.equals(Mode.ENTER) || mode.equals(Mode.EDIT))) {
            return;
        }

        if (ugandaEMRService.getPreviousQueue(session.getPatient(), session.getEncounter().getLocation(), PatientQueue.Status.PENDING) != null) {
            ugandaEMRService.processLabTestOrdersFromEncounterObs(session, true);

            ugandaEMRService.processDrugOrdersFromEncounterObs(session, true);
        }

        // Check if the patient has no OPD Number, Then create it
        PatientIdentifier OPDPatientIdentifer = patient.getPatientIdentifier(opdpatientIdentifierType);

        if(OPDPatientIdentifer == null) {
            PatientQueue patientQueue = Context.getService(PatientQueueingService.class).getMostRecentQueue(patient);
            if(patientQueue != null){
                String currentVisitNumber = patientQueue.getVisitNumber().replace("Rec-","").replace("/","");

                PatientIdentifier newIdentifier = new PatientIdentifier();
                newIdentifier.setIdentifierType(opdpatientIdentifierType);
                newIdentifier.setIdentifier(currentVisitNumber);
                patient.addIdentifier(newIdentifier);

                Context.getPatientService().savePatient(patient);
            }
        };
    }
}
