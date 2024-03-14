package org.openmrs.module.ugandaemr.tasks;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.CohortService;
import org.openmrs.api.context.Context;
import org.openmrs.scheduler.tasks.AbstractTask;

import java.util.List;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.*;

public class IdentifyCohortMemberOfProgramsAndWorkflowsTask extends AbstractTask {

    private Log log = LogFactory.getLog(this.getClass());

    @Override
    public void execute() {
        try {
            // TB eligibility
            getCohortEligiblePatients(TB_ELIGIBILITY_QUERY, TB_ELIGIBILITY_COHORT_UUID);
            // HIV eligibility
            getCohortEligiblePatients(HIV_ELIGIBILITY_QUERY, HIV_ELIGIBILITY_COHORT_UUID);
        } catch (Exception e) {
            log.error(e);
        }
    }

    private void getCohortEligiblePatients(String query, String cohortUuid) {
        AdministrationService administrationService = Context.getAdministrationService();
        try {
            List<List<Object>> results = administrationService.executeSQL(query, true);
            enrollPatientInCohort(results, cohortUuid);
        } catch (Exception e) {
            log.error(e);
        }
    }

    private void enrollPatientInCohort(List<List<Object>> results, String cohortUuid) {
        CohortService cohortService = Context.getCohortService();
        Cohort cohort = cohortService.getCohortByUuid(cohortUuid);

        for (List<Object> result : results) {
            Integer patientId = Integer.parseInt(result.get(0).toString());
            try {
                Patient patient = Context.getPatientService().getPatient(patientId);
                if (cohort.getActiveMemberships().isEmpty() || (!cohort.getActiveMemberships().isEmpty() && cohort.getActiveMembership(patient) == null)) {
                    CohortMembership cohortMembership = new CohortMembership(patient.getPatientId());
                    cohort.addMembership(cohortMembership);
                    cohortMembership.setCreator(Context.getUserService().getUser(1));
                    Context.getCohortService().saveCohort(cohort);
                }
            } catch (Exception e) {
                log.error(e);
            }
        }
    }
}
