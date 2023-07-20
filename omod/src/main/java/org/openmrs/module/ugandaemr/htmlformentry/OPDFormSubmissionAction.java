package org.openmrs.module.ugandaemr.htmlformentry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
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

/**
 * Enrolls patients into DSDM programs
 */
public class OPDFormSubmissionAction implements CustomFormSubmissionAction {

    private static final Log log = LogFactory.getLog(OPDFormSubmissionAction.class);

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
        }


    }
}
