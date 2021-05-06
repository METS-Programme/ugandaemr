package org.openmrs.module.ugandaemr.dataintegrity;

import org.hibernate.Query;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.module.dataintegrity.DataIntegrityRule;
import org.openmrs.module.dataintegrity.rule.RuleResult;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Checks for ART Regimen Lines
 *
 * <ol>
 * <li>Patients with Unknown Status - which means no Regimen line set </li>
 * </ol>
 *
 * */

@Component
public class ARTRegimenLinesValidationRules extends BasePatientRuleDefinition {
    @Override
    public List<RuleResult<Patient>> evaluate() {
        List<RuleResult<Patient>> ruleResults = new ArrayList<>();
        ruleResults.addAll(patientsWithUnknownRegimenLine());

        return ruleResults;
    }

    /**
     * Patients with current unknown Regimen Status in the Program Workflow
     * @return
     */
    public List<RuleResult<Patient>> patientsWithUnknownRegimenLine() {
        log.info("Executing rule to find patients with Unknown Regimen line");
        String queryString = "SELECT ps.patientProgram from PatientState ps WHERE ps.state = 10 AND ps.endDate IS NULL";

        Query query = getSession().createQuery(queryString);

        List<PatientProgram> patientProgramList = query.list();
        log.info("There are " + patientProgramList.size() + " patients with Unknown Regimen Line");

        List<RuleResult<Patient>> ruleResults = new ArrayList<>();
        for (PatientProgram patientProgram : patientProgramList) {
            RuleResult<Patient> ruleResult = new RuleResult<>();
            Patient patient = patientProgram.getPatient();
            ruleResult.setActionUrl("coreapps/patientdashboard/patientDashboard.page?patientId=" + patient.getUuid());
            ruleResult.setNotes("Client #" + getHIVClinicNumber(patient) + " has Unknown Regimen Line ");
            ruleResult.setEntity(patient);

            ruleResults.add(ruleResult);
        }

        return ruleResults;
    }

    @Override
    public DataIntegrityRule getRule() {
        DataIntegrityRule rule = new DataIntegrityRule();
        rule.setRuleCategory("patient");
        rule.setHandlerConfig("java");
        rule.setHandlerClassname(getClass().getName());
        rule.setRuleName("ART Regimen Line Validation Rules");
        rule.setUuid("840dbe64-5896-4d04-bdbd-23549086cc13\n");
        return rule;
    }
}
