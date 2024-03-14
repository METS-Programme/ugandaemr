package org.openmrs.module.ugandaemr.dataintegrity;



import java.util.List;

import org.joda.time.DateTime;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.openmrs.Patient;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.dataintegrity.rule.RuleResult;
import org.openmrs.test.jupiter.BaseModuleContextSensitiveTest;

import static org.junit.Assert.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class InvalidTBEncountersTest extends BaseModuleContextSensitiveTest{
	
	protected static final String UGANDAEMR_STANDARD_DATASET_XML = "org/openmrs/module/ugandaemr/include/standardTestDataset.xml";
	protected static final String UGANDAEMR_DATA_VIOLATIONS_XML = "org/openmrs/module/ugandaemr/include/tbEncountersData.xml";

	InvalidTBEncounters invalidTBEncounters;

	@BeforeEach
	public void initialize() throws Exception {
		executeDataSet(UGANDAEMR_STANDARD_DATASET_XML);
		executeDataSet(UGANDAEMR_DATA_VIOLATIONS_XML);

		invalidTBEncounters = new InvalidTBEncounters();
	}
	
	@Test
	public void patientsWithNoFinalOutcomeNineMonthsAfterStartOfTreatmentTest() {
		DateTime date = new DateTime("2017-07-19");
		List<RuleResult<Patient>> result = invalidTBEncounters.patientsWithNoFinalOutcomeNineMonthsAfterStartOfTreatment(date);
		assertNotNull(result);
		assertEquals(3, result.size());
	}
	
	@Test
	public void multiplePatientsWithTheSameTBIdentifiersTest() {
		List<RuleResult<Patient>> result = invalidTBEncounters.multiplePatientsWithTheSameTBIdentifiers(UgandaEMRConstants.DISTRICT_TB_NUMBER, "District TB Number");
		assertNotNull(result);
		assertEquals(2, result.size());
		
	}

	@Test
	public void multiplePatientsWithTheSameTBIdentifiersTest2() {
		List<RuleResult<Patient>> result = invalidTBEncounters.multiplePatientsWithTheSameTBIdentifiers(UgandaEMRConstants.UNIT_TB_NUMBER, "UNIT TB Number");
		assertNotNull(result);
		assertEquals(3, result.size());
		
	}
	
	@Test
	public void singlePatientWithDuplicateTBNumberAcrossMultipleTreatmentProgramsTest() {
		List<RuleResult<Patient>> result = invalidTBEncounters.singlePatientWithDuplicateTBNumberAcrossMultipleTreatmentPrograms(UgandaEMRConstants.UNIT_TB_NUMBER, "Unit TB Number");
		assertNotNull(result);
		assertEquals(1, result.size());
		Patient patient = result.get(0).getEntity();
		assertEquals(10002, patient.getId().longValue());
		
	}
	
	@Test
	public void patientsWithMissingTBNumbersTest() {
		List<RuleResult<Patient>> result = invalidTBEncounters.patientsWithMissingTBNumbers(UgandaEMRConstants.HSD_TB_NUMBER, "HSD TB Number");
		assertNotNull(result);
		assertEquals(2, result.size());
		
	}
	
}
