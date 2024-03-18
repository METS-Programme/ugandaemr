package org.openmrs.module.ugandaemr.tasks;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.CohortService;
import org.openmrs.api.context.Context;
import org.openmrs.scheduler.tasks.AbstractTask;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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
            Optional<Object> firstElement = result.stream().findFirst(); // Using Optional to handle possible empty lists
            if (firstElement.isPresent()) {
                try {
                    Integer patientId = Integer.parseInt(firstElement.get().toString());
                    Patient patient = Context.getPatientService().getPatient(patientId);
                    Boolean patientInCohort = false;
                    if (cohort.getActiveMemberships().isEmpty()) {
                        patientInCohort = false;
                    } else {
                        if (!cohort.getActiveMemberships().isEmpty()) {
                            List<CohortMembership> memberships = cohort.getMemberships().stream().filter(cohortMembership -> cohortMembership.getPatientId().equals(patient.getPatientId())).collect(Collectors.toList());
                            if (memberships.size() > 0) {
                                patientInCohort = true;
                            }
                        }
                    }

                    if (!patientInCohort) {
                        CohortMembership cohortMembership = new CohortMembership(patient.getPatientId());
                        cohort.addMembership(cohortMembership);
                        cohortMembership.setCreator(Context.getUserService().getUser(1));
                        Context.getCohortService().saveCohort(cohort);
                    }
                } catch (Exception e) {
                    log.error(e);
                }
            } else {
                log.warn("Empty list encountered. Skipping processing.");
            }
        }
    }
}
