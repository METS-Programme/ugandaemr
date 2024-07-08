package org.openmrs.module.ugandaemr.htmlformentry;


import org.openmrs.*;
import org.openmrs.api.EncounterService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.CustomFormSubmissionAction;
import org.openmrs.module.htmlformentry.FormEntryContext.Mode;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;

import java.util.*;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.GP_DSDM_CONCEPT_ID;
import static org.openmrs.module.ugandaemr.UgandaEMRConstants.GP_DSDM_PROGRAM_UUID_NAME;
import static org.openmrs.module.ugandaemr.UgandaEMRConstants.GP_DSDM_PROGRAM_UUID_NAME;
import static org.openmrs.module.ugandaemr.UgandaEMRConstants.CONCEPT_ID_NEXT_APPOINTMENT;
import static org.openmrs.module.ugandaemr.UgandaEMRConstants.CONCEPT_ID_TRANSFERED_OUT;

/**
 * Post form submission for patient
 */
public class HIVClinicalAssessmentSubmissionAction implements CustomFormSubmissionAction {

    @Override
    public void applyAction(FormEntrySession session) {
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        Mode mode = session.getContext().getMode();
        if (!(mode.equals(Mode.ENTER) || mode.equals(Mode.EDIT))) {
            return;
        }

        if (ugandaEMRService.getPreviousQueue(session.getPatient(), session.getEncounter().getLocation(), PatientQueue.Status.PENDING) != null) {
            ugandaEMRService.processLabTestOrdersFromEncounterObs(session, true);
            ugandaEMRService.processDrugOrdersFromEncounterObs(session, true);

            completeClinicianQueue(session.getEncounter());
        } else {
            orderViralLoadTest(session);
        }

        /**
         * Create TransferOut encounter When Patient is Transferred Out
         */
        createTransferOutEncounter(session);
    }

    private void completeClinicianQueue(Encounter encounter) {
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        for (Obs obs : encounter.getAllObs(false)) {
            if (obs.getConcept().getConceptId().equals(CONCEPT_ID_NEXT_APPOINTMENT) || obs.getConcept().getConceptId().equals(CONCEPT_ID_TRANSFERED_OUT)) {
                ugandaEMRService.completePreviousQueue(obs.getEncounter().getPatient(), encounter.getLocation(), PatientQueue.Status.PENDING);
                Context.getVisitService().endVisit(encounter.getVisit(), new Date());
            }

        }
    }


    private Encounter createTransferOutEncounter(FormEntrySession formEntrySession) {
        EncounterService encounterService = Context.getEncounterService();
        UgandaEMRService ugandaemrService = Context.getService(UgandaEMRService.class);
        Encounter encounter = null;

        if (getObsByConceptFromSet(formEntrySession.getEncounter().getAllObs(), 90306) != null) {
            encounter = new Encounter();
            encounter.setEncounterType(encounterService.getEncounterTypeByUuid("e305d98a-d6a2-45ba-ba2a-682b497ce27c"));
            encounter.setLocation(formEntrySession.getEncounter().getLocation());
            encounter.setPatient(formEntrySession.getPatient());
            encounter.setVisit(formEntrySession.getEncounter().getVisit());
            encounter.setEncounterDatetime(formEntrySession.getEncounter().getEncounterDatetime());
            encounter.setForm(Context.getFormService().getFormByUuid("45d9db68-e4b5-11e7-80c1-9a214cf093ae"));

            Obs transferOutToObs = ugandaemrService.generateObsFromObs(formEntrySession.getEncounter().getAllObs(), 90211, 90211, encounter);
            encounter.addObs(transferOutToObs);

            encounterService.saveEncounter(encounter);
        }

        return encounter;
    }

    private Obs getObsByConceptFromSet(Set<Obs> obsSet, Integer lookupConceptId) {
        for (Obs obs : obsSet) {
            if (lookupConceptId.equals(obs.getConcept().getConceptId())) {
                return obs;
            }
        }
        return null;
    }

    private Encounter orderViralLoadTest(FormEntrySession formEntrySession) {
        Obs viralLoadTest = null;
        Obs labNo = null;
        Obs specimenSource = null;
        Encounter encounter = null;
        for (Obs obs : formEntrySession.getEncounter().getAllObs()) {
            if (obs.getValueCoded() != null && obs.getValueCoded().getConceptId() == 165412) {
                viralLoadTest = obs;
            } else if (obs.getConcept().getConceptId() == 165845) {
                labNo = obs;
            } else if (obs.getConcept().getConceptId() == 159959) {
                specimenSource = obs;
            }
        }

        if (viralLoadTest != null && labNo != null && specimenSource != null) {
            encounter = Context.getService(UgandaEMRService.class).processRetrospectiveViralLoadOrder(viralLoadTest, labNo, specimenSource);
        }
        return encounter;
    }
}
