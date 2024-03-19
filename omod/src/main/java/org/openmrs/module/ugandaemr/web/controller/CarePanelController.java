package org.openmrs.module.ugandaemr.web.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.node.ArrayNode;
import org.codehaus.jackson.node.JsonNodeFactory;
import org.codehaus.jackson.node.ObjectNode;
import org.json.JSONObject;
import org.openmrs.*;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.CohortService;
import org.openmrs.api.ConceptService;
import org.openmrs.api.context.Context;
import org.openmrs.calculation.result.CalculationResult;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.ugandaemr.utils.EncounterBasedRegimenUtils;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.api.PatientService;
import org.openmrs.api.ProgramWorkflowService;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;


@Controller
public class CarePanelController {

    private final Log log = LogFactory.getLog(CarePanelController.class);

    static SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");

    /**
     * ARV drugs
     * @return custom ARV drugs object for non standard regimen
     */
    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            + "/arvDrugs", method = RequestMethod.GET)
    @ResponseBody
    public Object getArvDrugs() {
        ConceptService concService = Context.getConceptService();
        ArrayNode drugs = JsonNodeFactory.instance.arrayNode();
        ObjectNode drugsObj = JsonNodeFactory.instance.objectNode();

        List<Concept> arvDrugs = Arrays.asList(
                concService.getConcept(814),
                concService.getConcept(796),
                concService.getConcept(633),
                concService.getConcept(628),
                concService.getConcept(631),
                concService.getConcept(625),
                concService.getConcept(802),
                concService.getConcept(797),
                concService.getConcept(630),
                concService.getConcept(794),
                concService.getConcept(792),
                concService.getConcept(635)
        );

        for (Concept con: arvDrugs) {
            ObjectNode node = JsonNodeFactory.instance.objectNode();
            node.put("name", con.getName() != null ? con.getName().toString() : "");
            node.put("uuid", con.getUuid() != null ? con.getUuid().toString() : "");
            drugs.add(node);
        }

        drugsObj.put("results", drugs);
        return drugsObj.toString();
    }

    /**
     * Current Program Details
     */
    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            + "/currentProgramDetails", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public String getCurrentProgramDetails(@RequestParam("patientUuid") String patientUuid) {
        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Object> programDetails = new HashMap<>();

        // Retrieve patient by UUID
        Patient patient = Context.getPatientService().getPatientByUuid(patientUuid);

        if (patient != null) {
            // Check for both HIV and TB programs
            programDetails.put("HIV", fetchProgramData(patient, "HIV Program"));
            programDetails.put("TB", fetchProgramData(patient, "TB Program"));
        } else {
            System.out.println("Patient not found.");
        }

        try {
            // Convert the program details map to JSON
            return objectMapper.writeValueAsString(programDetails);
        } catch (Exception e) {
            e.printStackTrace();
            return "Error converting to JSON";
        }
    }

    // Method to fetch program data for a given patient and program
    private Map<String, Object> fetchProgramData(Patient patient, String programName) {
        ProgramWorkflowService programWorkflowService = Context.getProgramWorkflowService();
        Map<String, Object> programData = new HashMap<>();

        Program program = programWorkflowService.getProgramByName(programName);

        if (program != null) {
            List<PatientProgram> patientPrograms = programWorkflowService.getPatientPrograms(patient, program, null, null, null, null, false);

            if (!patientPrograms.isEmpty()) {
                PatientProgram patientProgram = patientPrograms.get(0);

                // Accessing specific program data based on program name
                if ("HIV Program".equals(programName)) {
                    programData.put("whoStage", getAttribute(patientProgram, "WHO Stage"));
                    programData.put("whoStageDate", getAttributeDate(patientProgram, "WHO Stage Date"));
                    programData.put("cd4", getAttribute(patientProgram, "CD4 Count"));
                    programData.put("cd4Date", getAttributeDate(patientProgram, "CD4 Count Date"));
                    programData.put("cd4Percent", getAttribute(patientProgram, "CD4 Percent"));
                    programData.put("cd4PercentDate", getAttributeDate(patientProgram, "CD4 Percent Date"));
                    programData.put("ldlValue", getAttribute(patientProgram, "LDL Value"));
                    programData.put("ldlDate", getAttributeDate(patientProgram, "LDL Value Date"));
                    programData.put("enrolledInHiv", true);
                    programData.put("lastEncDetails", null);
                } else if ("TB Program".equals(programName)) {
                    programData.put("diseaseClassification", getAttribute(patientProgram, "Disease Classification"));
                    programData.put("PatientClassification", getAttribute(patientProgram, "PatientClassification"));
                }
            } else {
                System.out.println("Patient not enrolled in the " + programName + ".");
            }
        } else {
            System.out.println(programName + " not found.");
        }

        return programData;
    }

    // Helper method to get attribute value from a patient program
    private String getAttribute(PatientProgram patientProgram, String attributeName) {
        for (PatientProgramAttribute attribute : patientProgram.getAttributes()) {
            if (attribute.getAttributeType().getName().equals(attributeName)) {
                Object value = attribute.getValue();
                return value != null ? value.toString() : "None";
            }
        }
        return "None";
    }

    // Helper method to get attribute date from a patient program
    private String getAttributeDate(PatientProgram patientProgram, String attributeName) {
        for (PatientProgramAttribute attribute : patientProgram.getAttributes()) {
            if (attribute.getAttributeType().getName().equals(attributeName)) {
                // Assuming there's a corresponding date attribute
                return getAttribute(patientProgram, attributeName + " Date");
            }
        }
        return "";
    }


    /**
     * Returns regimen history for a patient
     * @param category // ARV or TB
     * @param patientUuid
     * @return
     */
    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            + "/regimenHistory", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public Object getRegimenHistory(@RequestParam("patientUuid") String patientUuid, @RequestParam("category") String category) {
        ObjectNode regimenObj = JsonNodeFactory.instance.objectNode();
        if (StringUtils.isBlank(patientUuid)) {
            return new ResponseEntity<Object>("You must specify patientUuid in the request!",
                    new HttpHeaders(), HttpStatus.BAD_REQUEST);
        }

        Patient patient = Context.getPatientService().getPatientByUuid(patientUuid);

        if (patient == null) {
            return new ResponseEntity<Object>("The provided patient was not found in the system!",
                    new HttpHeaders(), HttpStatus.NOT_FOUND);
        }
        ArrayNode regimenNode = JsonNodeFactory.instance.arrayNode();
        List<SimpleObject> obshistory = EncounterBasedRegimenUtils.getRegimenHistoryFromObservations(patient, category);
        for (SimpleObject obj : obshistory) {
            ObjectNode node = JsonNodeFactory.instance.objectNode();;
            node.put("startDate", obj.get("startDate").toString());
            node.put("endDate", obj.get("endDate").toString());
            node.put("regimenShortDisplay", obj.get("regimenShortDisplay").toString());
            node.put("regimenLine", obj.get("regimenLine").toString());
            node.put("regimenLongDisplay", obj.get("regimenLongDisplay").toString());
            node.put("changeReasons", obj.get("changeReasons").toString());
            node.put("regimenUuid", obj.get("regimenUuid").toString());
            node.put("current", obj.get("current").toString());
            regimenNode.add(node);
        }

        regimenObj.put("results", regimenNode);
        return regimenObj.toString();

    }

    /**
     * Returns regimen change/stop reasons
     * @return
     */
    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            +"/regimenReason", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public Object getRegimenReason() {
        ObjectNode regimenReasonObj = JsonNodeFactory.instance.objectNode();

        ArrayNode reasons = JsonNodeFactory.instance.arrayNode();
        ObjectNode arvReasonsObj = JsonNodeFactory.instance.objectNode();
        ObjectNode tbReasonsObj = JsonNodeFactory.instance.objectNode();
        Map<String, String> arvReasonOptionsMap = new HashMap<String, String>();
        Map<String, String> tbReasonOptionsMap = new HashMap<String, String>();
        arvReasonOptionsMap.put("Toxicity / side effects", "102AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Pregnancy", "1434AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Risk of pregnancy", "160559AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("New diagnosis of TB", "160567AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("New drug available", "160561AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Drugs out of stock", "1754AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Clinical treatment failure", "843AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Immunological failure", "160566AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Virological Failure", "160569AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Poor Adherence", "159598AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Inpatient care or hospitalization", "5485AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Refusal / patient decision", "127750AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Planned treatment interruption", "160016AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Completed total PMTCT", "1253AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Tuberculosis treatment started", "1270AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        arvReasonOptionsMap.put("Patient lacks finance", "819AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

        ArrayNode arvReasons = JsonNodeFactory.instance.arrayNode();
        for (Map.Entry<String, String> entry : arvReasonOptionsMap.entrySet()) {
            ObjectNode arvCategoryReasonObj = JsonNodeFactory.instance.objectNode();
            arvCategoryReasonObj.put("label", entry.getKey());
            arvCategoryReasonObj.put("value", entry.getValue());
            arvReasons.add(arvCategoryReasonObj);
        }
        arvReasonsObj.put("category", "ARV");
        arvReasonsObj.put("reason", arvReasons);
        reasons.add(arvReasonsObj);

        tbReasonOptionsMap.put("Toxicity / side effects", "102AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Pregnancy", "1434AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Clinical treatment failure", "843AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Poor Adherence", "159598AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Inpatient care or hospitalization", "5485AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Drugs out of stock", "1754AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Planned treatment interruption", "160016AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Refusal / patient decision", "127750AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Drug formulation changed", "1258AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        tbReasonOptionsMap.put("Patient lacks finance", "819AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");


        ArrayNode tbReasons = JsonNodeFactory.instance.arrayNode();
        for (Map.Entry<String, String> entry : tbReasonOptionsMap.entrySet()) {
            ObjectNode tbCategoryReasonObj = JsonNodeFactory.instance.objectNode();
            tbCategoryReasonObj.put("label", entry.getKey());
            tbCategoryReasonObj.put("value", entry.getValue());
            tbReasons.add(tbCategoryReasonObj);
        }
        tbReasonsObj.put("category", "TB");
        tbReasonsObj.put("reason", tbReasons);
        reasons.add(tbReasonsObj);
        regimenReasonObj.put("results", reasons);
        return regimenReasonObj.toString();

    }

    /**
     * Last Regimen Encounter
     */
    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            +"/lastRegimenEncounter", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public Object getLastRegimenEncounterUuid(@RequestParam("category") String category, @RequestParam("patientUuid") String patientUuid) {
        ObjectNode encObj = JsonNodeFactory.instance.objectNode();
        ObjectNode node = JsonNodeFactory.instance.objectNode();
        Patient patient = Context.getPatientService().getPatientByUuid(patientUuid);
        String event = null;

        Encounter enc = EncounterBasedRegimenUtils.getLastEncounterForCategory(patient, category);

        String ARV_TREATMENT_PLAN_EVENT = "1255AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        String DATE_REGIMEN_STOPPED = "1191AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        String endDate = null;

        if (enc != null) {
            Date latest = null;
            List<Date> dates = new ArrayList<Date>();
            for(Obs obs:enc.getObs()) {
                dates.add(obs.getObsDatetime());
                latest = Collections.max(dates);
            }

            for(Obs obs:enc.getObs()) {
                if(obs.getConcept().getUuid().equals(ARV_TREATMENT_PLAN_EVENT) && obs.getObsDatetime().equals(latest)) {
                    event =obs.getValueCoded() != null ?  obs.getValueCoded().getName().getName() : "";
                }
                if (obs.getConcept() != null && obs.getConcept().getUuid().equals(DATE_REGIMEN_STOPPED)) {
                    if(obs.getValueDatetime() != null){
                        endDate = DATE_FORMAT.format(obs.getValueDatetime());
                    }
                }

            }

        }
        node.put("uuid", enc != null ?  enc.getUuid() : "");
        node.put("startDate", enc != null ? DATE_FORMAT.format(enc.getEncounterDatetime()): "");
        node.put("endDate", endDate);
        node.put("event", event);
        encObj.put("results", node);

        return encObj.toString();
    }


    @RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
            + "/standardRegimen", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public Object getStandardRegimen() throws SAXException, IOException, ParserConfigurationException {
        ArrayNode standardRegimenCategories = JsonNodeFactory.instance.arrayNode();
        ObjectNode resultsObj = JsonNodeFactory.instance.objectNode();

        for (RegimenConfiguration configuration : Context.getRegisteredComponents(RegimenConfiguration.class)) {
            try (InputStream stream = getDefinitionsStream(configuration)) {
                Document document = parseXml(stream);
                processCategories(document, standardRegimenCategories);
            } catch (Exception e) {
                e.printStackTrace();
                throw new RuntimeException("Unable to load " + configuration.getModuleId() + ":" +
                        configuration.getDefinitionsPath(), e);
            }
        }

        resultsObj.put("results", standardRegimenCategories);
        return resultsObj.toString();
    }

    private InputStream getDefinitionsStream(RegimenConfiguration configuration) throws IOException {
        InputStream stream = configuration.getClassLoader().getResourceAsStream(configuration.getDefinitionsPath());
        if (stream == null || stream.available() == 0) {
            throw new RuntimeException("Empty or unavailable stream for " + configuration.getDefinitionsPath());
        }
        return stream;
    }

    private Document parseXml(InputStream stream) throws ParserConfigurationException, IOException, SAXException {
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = dbFactory.newDocumentBuilder();
        return builder.parse(stream);
    }

    private void processCategories(Document document, ArrayNode standardRegimenCategories) {
        Element root = document.getDocumentElement();
        NodeList categoryNodes = root.getElementsByTagName("category");

        for (int c = 0; c < categoryNodes.getLength(); c++) {
            ObjectNode categoryObj = JsonNodeFactory.instance.objectNode();
            Element categoryElement = (Element) categoryNodes.item(c);
            String categoryCode = categoryElement.getAttribute("code");
            categoryObj.put("categoryCode", categoryCode);

            processGroups(categoryElement, categoryObj);
            standardRegimenCategories.add(categoryObj);
        }
    }

    private void processGroups(Element categoryElement, ObjectNode categoryObj) {
        NodeList groupNodes = categoryElement.getElementsByTagName("group");
        ArrayNode standardRegimen = JsonNodeFactory.instance.arrayNode();

        for (int g = 0; g < groupNodes.getLength(); g++) {
            ObjectNode standardRegimenObj = JsonNodeFactory.instance.objectNode();
            Element groupElement = (Element) groupNodes.item(g);
            String groupName = groupElement.getAttribute("name");
            String regimenLineValue = getRegimenLineValue(groupName);

            standardRegimenObj.put("regimenline", groupName);
            standardRegimenObj.put("regimenLineValue", regimenLineValue);

            processRegimens(groupElement, standardRegimenObj);
            standardRegimen.add(standardRegimenObj);
        }
        categoryObj.put("category", standardRegimen);
    }

    private String getRegimenLineValue(String groupName) {
        // Use a map or switch for more complex mapping
        switch (groupName.toLowerCase()) {
            case "adult (first line)":
                return "AF";
            case "adult (second line)":
                return "AS";
            case "adult (third line)":
                return "AT";
            case "child (first line)":
                return "CF";
            case "child (second line)":
                return "CS";
            case "child (third line)":
                return "CT";
            case "intensive phase (adult)":
                return "Intensive Phase (Adult)";
            case "intensive phase (child)":
                return "Intensive Phase (Child)";
            case "continuation phase (adult)":
                return "Continuation Phase (Adult)";
            default:
                return "";
        }
    }

    private void processRegimens(Element groupElement, ObjectNode standardRegimenObj) {
        ArrayNode regimen = JsonNodeFactory.instance.arrayNode();
        NodeList regimenNodes = groupElement.getElementsByTagName("regimen");

        for (int r = 0; r < regimenNodes.getLength(); r++) {
            ObjectNode regimenObj = JsonNodeFactory.instance.objectNode();
            Element regimenElement = (Element) regimenNodes.item(r);
            String name = regimenElement.getAttribute("name");
            String conceptRef = regimenElement.getAttribute("conceptRef");

            regimenObj.put("name", name);
            regimenObj.put("conceptRef", conceptRef);
            regimen.add(regimenObj);
        }
        standardRegimenObj.put("regimen", regimen);
    }

}