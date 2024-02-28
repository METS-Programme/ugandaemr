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
            hivEligibilityCohort(TB_ELIGIBILITY_QUERY, TB_ELIGIBILITY_COHORT_UUID);
            // HIV eligibility
            hivEligibilityCohort(HIV_ELIGIBILITY_QUERY, HIV_ELIGIBILITY_COHORT_UUID);
        } catch (Exception e) {
            log.error(e);
        }
    }

    private void hivEligibilityCohort(String query, String cohortUuid) {
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
                if (!cohortService.getCohort(cohort.getId()).contains(patient.getPatientId())) {
                    cohortService.addPatientToCohort(cohort, patient);

                    insertIntoCohortMember(patientId, cohort.getId());
                }
            } catch (Exception e) {
                log.error(e);
            }
        }
    }

    private void insertIntoCohortMember(int patientId, int cohortId) {
        try {
            if (!isMemberInCohort(patientId, cohortId)) {
                Context.getCohortService().addPatientToCohort(
                        Context.getCohortService().getCohort(cohortId),
                        Context.getPatientService().getPatient(patientId)
                );
            }
        } catch (Exception e) {
            log.error(e);
        }
    }

    private boolean isMemberInCohort(int patientId, int cohortId) {
        List<Cohort> cohorts = Context.getCohortService().getCohortsContainingPatientId(patientId);
        return cohorts.stream().anyMatch(cohort -> cohort.getId() == cohortId);
    }
}
