package org.openmrs.module.ugandaemr.fragment.controller;

import io.swagger.util.Json;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.velocity.runtime.directive.Parse;
import org.json.JSONArray;
import org.json.JSONObject;
import org.openmrs.*;
import org.openmrs.api.ConceptService;
import org.openmrs.api.EncounterService;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.idgen.IdentifierSource;
import org.openmrs.module.idgen.service.IdentifierSourceService;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.lang.reflect.Array;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.UUID;


public class TransferInCovidPatientFragmentController {

    public static Log log = LogFactory.getLog(TransferInCovidPatientFragmentController.class);
    public static final String VALUE_CODED = "8d4a48b6-c2cc-11de-8d13-0010c6dffd0f";
    public static final String VALUE_TEXT = "8d4a4ab4-c2cc-11de-8d13-0010c6dffd0f";
    public static final String VALUE_DATE = " 8d4a505e-c2cc-11de-8d13-0010c6dffd0f";
    public static final String VALUE_DATETIME = "8d4a5af4-c2cc-11de-8d13-0010c6dffd0f";
    public static final String VALUE_BOOLEAN = "8d4a5cca-c2cc-11de-8d13-0010c6dffd0f";
    public static final String VALUE_NUMERIC = "8d4a4488-c2cc-11de-8d13-0010c6dffd0f";
    public static final String PATIENT_ID_TYPE_UIC_UUID = "877169c4-92c6-4cc9-bf45-1ab95faea242";
    public TransferInCovidPatientFragmentController() {

    }

    public void processCovidPatient(FragmentModel model,
                                     @RequestParam(value = "patientDataFromRDS", required = false) java.lang.String patientDataFromRDS, UiUtils ui,UiSessionContext sessionContext) {
        log.info(patientDataFromRDS);
        JSONObject jsonObject = new JSONObject(patientDataFromRDS);
        //log.info(jsonObject);
        JSONArray container = (JSONArray) jsonObject.get("contained");
        JSONObject patientData = container.getJSONObject(3);
        Patient patient = createPatient(patientData);
        try {
            createCaseInvesitigationEncounter(container,patient,"",sessionContext);
        } catch (Exception e) {
            e.printStackTrace();
        }
        // redirect to case invesigation form


    }
    public Patient createPatient(JSONObject jsonObject) {
        PatientService patientService = Context.getPatientService();
        //Date date = new SimpleDateFormat("yyyy-MM-dd").parse(jsonObject.get("birthDate").toString());

        Date date = null;
        try {
            date = new SimpleDateFormat("yyyy-MM-dd").parse("1988-07-27");
        } catch (ParseException e) {
            e.printStackTrace();
        }

        String gender = String.valueOf(jsonObject.get("gender"));

        PersonName patientName = getPatientNames(jsonObject);

        Patient patient = new Patient();
        patient.addName(patientName);
        patient.setBirthdate(date);
        patient.setGender(gender);
        patient = getPatientIdentifiers(patient);

        return patientService.savePatient(patient);
    }


    private PersonName getPatientNames(JSONObject jsonObject) {
        JSONObject patientNamesObject = (JSONObject) ((JSONArray) jsonObject.get("name")).get(0);
        PersonName personName = new PersonName();

        String[] listOfNames= patientNamesObject.get("text").toString().split(" ");

        personName.setFamilyName(listOfNames[0]);
        personName.setGivenName(listOfNames[1]);


        return personName;
    }
    public Encounter createCaseInvesitigationEncounter(JSONArray jsonArray, Patient patient, String transferInFrom,
                                                      UiSessionContext session) throws Exception {
        ConceptService conceptService = Context.getConceptService();
        Provider provider = session.getCurrentProvider();
        EncounterService encounterService = Context.getEncounterService();

        Encounter encounter = new Encounter();
        encounter.setEncounterType(encounterService.getEncounterTypeByUuid("422ee220-9e83-451d-9b25-79a688a0413a"));
        encounter.setProvider(Context.getEncounterService().getEncounterRoleByUuid("240b26f9-dd88-4172-823d-4a8bfeb7841f"),
                provider);
        encounter.setLocation(session.getSessionLocation());
        encounter.setPatient(patient);
        encounter.setEncounterDatetime(new Date());
        encounter.setForm(Context.getFormService().getFormByUuid("d3270bd2-7cb3-11eb-9439-0242ac130002"));

        JSONObject labContainer      = (JSONObject) jsonArray.get(5);
        JSONObject facilityContainer = (JSONObject) jsonArray.get(4);
        JSONObject testContainer     = (JSONObject) jsonArray.get(1);
        JSONObject symptomsContainer  = (JSONObject) jsonArray.get(7);
        JSONObject patientData = (JSONObject) jsonArray.get(3);;

        String caseID =  ((JSONObject) labContainer.get("accessionIdentifier")).get("value").toString();
        if (!caseID.equalsIgnoreCase("")){
            Obs caseIdentifer = createNewObs(conceptService.getConcept(1646), encounter);
            caseIdentifer.setValueText(caseID);
            encounter.addObs(caseIdentifer);
        }

        String effectiveDateTime = testContainer.get("effectiveDateTime").toString();
        if (!effectiveDateTime.equalsIgnoreCase("")){
            Date datePositiveTest = new SimpleDateFormat("yyyy-MM-dd").parse(effectiveDateTime);
            Obs dateOfPositiveTest = createNewObs(conceptService.getConcept(166281), encounter);
            dateOfPositiveTest.setValueDate(datePositiveTest);
            encounter.addObs(dateOfPositiveTest);
        }

        //Obs testType = createNewObs(conceptService.getConcept(166284), encounter);
        //String conceptTestType = ((JSONObject) testContainer.get("code")).get("text").toString();
        //if ()
        //testType.setValueCoded();
        //encounter.addObs(testType);

        String careGiver = ((JSONObject)((JSONObject) ((JSONArray) patientData.get("contact")).get(0)).get("name")).get("text").toString();
        if (!careGiver.equalsIgnoreCase("")){
            Obs careGiverName = createNewObs(conceptService.getConcept(165919), encounter);
            careGiverName.setValueText(careGiver);
            encounter.addObs(careGiverName);
        }


        String careGiverphone = ((JSONObject) ((JSONArray) ((JSONObject) ((JSONArray) patientData.get("contact")).get(0)).get("telecom")).get(0)).get("value").toString();
        if (!careGiverphone.equalsIgnoreCase("")){
            Obs careGiverPhone = createNewObs(conceptService.getConcept(165924), encounter);
            careGiverPhone.setValueText(careGiverphone);
            encounter.addObs(careGiverPhone);
        }

        Obs isPatientSymptomatic = createNewObs(conceptService.getConcept(166285), encounter);
        String patientSymptomicValue = ((JSONObject) (JSONObject) jsonArray.get(7)).get("valueBoolean").toString();
        if (Boolean.parseBoolean(patientSymptomicValue.toString())){
            isPatientSymptomatic.setValueCoded(conceptService.getConcept(90003));
        }else {
            isPatientSymptomatic.setValueCoded(conceptService.getConcept(90004));
        }
        encounter.addObs(isPatientSymptomatic);

        Obs dateOnSet = createNewObs(conceptService.getConcept(166286), encounter);
        String dateOnset = ((JSONObject) ((JSONArray) symptomsContainer.get("component")).get(0)).get("valueDateTime").toString();
        if (!dateOnset.equalsIgnoreCase("")){
            dateOnSet.setValueText(dateOnset);
            encounter.addObs(dateOnSet);
        }

        //Context.getEncounterService().saveEncounter(encounter);
        encounterService.saveEncounter(encounter);
        return encounter;
    }
    private Obs createObsFromJSONArray(Encounter encounter, JSONObject jsonObject, Obs transferInObs) throws ParseException {
        ConceptService conceptService = Context.getConceptService();

        Obs obs = createNewObs(conceptService.getConceptByUuid(jsonObject.get("concept").toString()), encounter);

        assert obs != null;
        if (obs.getConcept().getConceptId() == 90315) {
            obs.setConcept(conceptService.getConcept(99064));
        }

        if (jsonObject.get("valueText") != null && !jsonObject.get("valueText").toString().equals("null")) {
            obs.setValueText(jsonObject.get("valueText").toString());
        }

        if (jsonObject.get("valueNumeric") != null && !jsonObject.get("valueNumeric").toString().equals("null")) {
            obs.setValueNumeric(Double.parseDouble(jsonObject.get("valueNumeric").toString()));
        }

        if (jsonObject.get("valueDatetime") != null && !jsonObject.get("valueDatetime").toString().equals("null")) {
            obs.setValueDatetime(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(jsonObject.get("valueDatetime")
                    .toString()));
        }

        if (jsonObject.get("valueCoded") != null && !jsonObject.get("valueCoded").toString().equals("null")) {
            obs.setValueCoded(conceptService.getConceptByUuid(jsonObject.get("valueCoded").toString()));
        }
        return obs;
    }
    private Obs createNewObs(Concept concept, Encounter encounter) {
        Obs obs = new Obs();
        obs.setObsDatetime(encounter.getEncounterDatetime());
        obs.setPerson(encounter.getPatient());
        obs.setLocation(encounter.getLocation());
        obs.setEncounter(encounter);
        obs.setConcept(concept);
        return obs;
    }


    public Obs createObsFromFhirObs(JSONObject jsonObject) {
        ConceptService conceptService = Context.getConceptService();
        Obs obs = new Obs();
        String code = ((JSONObject) ((JSONArray) ((JSONObject) jsonObject.get("code")).get("coding")).get(0)).get("code").toString();
        Concept question = conceptService.getConceptByMapping(code, "SNOMED CT");
        obs.setConcept(question);
        if (question.getDatatype().getUuid().equalsIgnoreCase(VALUE_CODED)) {
            String valueCoded = ((JSONObject) ((JSONArray) ((JSONObject) jsonObject.get("valueCodeableConcept")).get("coding")).get(0)).get("code").toString();
            obs.setValueCoded(conceptService.getConceptByMapping(valueCoded, "SNOMED CT"));
        } else if (question.getDatatype().getUuid().equalsIgnoreCase(VALUE_TEXT)) {
            obs.setValueText(jsonObject.get("valueString").toString());
        } else if (question.getDatatype().getUuid().equalsIgnoreCase(VALUE_DATE)) {
            obs.setValueDate(getDateFromString(jsonObject.get("valueDate").toString(), "yyyy-MM-dd"));
        }else  if(question.getDatatype().getUuid().equalsIgnoreCase(VALUE_DATETIME)){
            obs.setValueDate(getDateFromString(jsonObject.get("valueDate").toString(), "yyyy-MM-dd HH:mm:ss"));
        }else if(question.getDatatype().getUuid().equalsIgnoreCase(VALUE_BOOLEAN)){
            obs.setValueBoolean(Boolean.parseBoolean(jsonObject.get("valueBoolean").toString()));
        } else if(question.getDatatype().getUuid().equalsIgnoreCase(VALUE_NUMERIC)){
            obs.setValueNumeric(Double.parseDouble(jsonObject.get("valueBoolean").toString()));
        }
        return obs;
    }
    public static Date getDateFromString(String stringDate, String formart) {
        SimpleDateFormat formatter = new SimpleDateFormat(formart, Locale.ENGLISH);
        try {
            return formatter.parse(stringDate);
        } catch (Exception e) {
            log.error(e);
        }
        return null;
    }

    private Patient getPatientIdentifiers(Patient patient) {
        PatientService patientService = Context.getPatientService();
        UgandaEMRService aijarService = Context.getService(UgandaEMRService.class);

        if (patient.getIdentifiers().isEmpty()) {
            patient.addIdentifier(createPatientIdentifier(aijarService.generatePatientUIC(patient), PATIENT_ID_TYPE_UIC_UUID));
        }

        patient.addIdentifier(generatePatientIdentifier());

        return patient;

    }
    private PatientIdentifier createPatientIdentifier(String identifier, String identifierTypeUUID) {
        PatientService patientService = Context.getPatientService();
        PatientIdentifier patientIdentifier = new PatientIdentifier();
        patientIdentifier.setIdentifierType(patientService.getPatientIdentifierTypeByUuid(identifierTypeUUID));
        patientIdentifier.setIdentifier(identifier);
        return patientIdentifier;
    }

    private PatientIdentifier generatePatientIdentifier() {
        IdentifierSourceService iss = Context.getService(IdentifierSourceService.class);
        IdentifierSource idSource = iss.getIdentifierSource(1); // this is the default OpenMRS identifier source
        PatientService patientService = Context.getPatientService();

        UUID uuid = UUID.randomUUID();

        PatientIdentifierType patientIdentifierType = patientService
                .getPatientIdentifierTypeByUuid("05a29f94-c0ed-11e2-94be-8c13b969e334");

        PatientIdentifier pid = new PatientIdentifier();
        pid.setIdentifierType(patientIdentifierType);
        String identifier = iss.generateIdentifier(idSource, "New OpenMRS ID with CheckDigit");
        pid.setIdentifier(identifier);
        pid.setPreferred(true);
        pid.setUuid(String.valueOf(uuid));

        return pid;
    }
}
