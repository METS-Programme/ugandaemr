package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.*;
import org.openmrs.api.EncounterService;
import org.openmrs.api.OrderService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.api.lab.OrderObs;
import org.openmrs.module.ugandaemr.api.lab.util.*;
import org.openmrs.module.ugandaemr.utils.DateFormatUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.BindParams;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Date;
import java.util.ArrayList;
import java.util.Set;
import java.util.Calendar;
import java.util.HashSet;
import java.util.GregorianCalendar;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.*;

public class LabQueueListFragmentController {

    protected final Log log = LogFactory.getLog(LabQueueListFragmentController.class);

    public LabQueueListFragmentController() {
    }

    public void controller(@SpringBean FragmentModel pageModel, UiSessionContext uiSessionContext) {

        pageModel.put("specimenSource", Context.getOrderService().getTestSpecimenSources());

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String labWorkListBackLogDaysToDisplay = Context.getAdministrationService().getGlobalProperty("ugandaemr.labWorkListBackLogDaysToDisplay");
        String labReferenceListBackLogDaysToDisplay = Context.getAdministrationService().getGlobalProperty("ugandaemr.labReferenceListBackLogDaysToDisplay");
        String dateStr = sdf.format(new Date());
        List<String> list = new ArrayList();
        list.add("ba158c33-dc43-4306-9a4a-b4075751d36c");
        pageModel.addAttribute("currentDate", dateStr);
        pageModel.addAttribute("locationSession", uiSessionContext.getSessionLocation().getUuid());
        pageModel.put("clinicianLocation", list);
        pageModel.put("currentProvider", uiSessionContext.getCurrentProvider());
        pageModel.put("enablePatientQueueSelection", Context.getAdministrationService().getGlobalProperty("ugandaemr.enablePatientQueueSelection"));
        pageModel.put("labReferenceListBackLogDaysToDisplay", getDateDaysBack(new Date(), Integer.parseInt(labReferenceListBackLogDaysToDisplay)));
        pageModel.put("labWorkListBackLogDaysToDisplay", getDateDaysBack(new Date(), Integer.parseInt(labWorkListBackLogDaysToDisplay)));
    }

    private String getDateDaysBack(Date date, int daysBack) {
        Calendar cal = new GregorianCalendar();
        cal.setTime(date);
        cal.add(Calendar.DAY_OF_MONTH, -daysBack);
        try {
            return DateFormatUtil.dateFormtterString(cal.getTime(), "00:00:00");
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }


    /**
     * Get Patients in Lab Queue
     *
     * @param searchfilter
     * @param uiSessionContext
     * @return
     * @throws IOException
     * @throws ParseException
     */
    public SimpleObject getPatientQueueList(@RequestParam(value = "labSearchFilter", required = false) String searchfilter, UiSessionContext uiSessionContext) throws IOException, ParseException {
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleObject simpleObject = new SimpleObject();
        List<PatientQueue> patientQueueList = new ArrayList();
        if (!searchfilter.equals("")) {
            patientQueueList = patientQueueingService.getPatientQueueListBySearchParams(searchfilter, OpenmrsUtil.firstSecondOfDay(new Date()), OpenmrsUtil.getLastMomentOfDay(new Date()), uiSessionContext.getSessionLocation(), null, null);
        } else {
            patientQueueList = patientQueueingService.getPatientQueueListBySearchParams(null, OpenmrsUtil.firstSecondOfDay(new Date()), OpenmrsUtil.getLastMomentOfDay(new Date()), uiSessionContext.getSessionLocation(), null, null);
        }
        simpleObject.put("patientLabQueueList", objectMapper.writeValueAsString(Context.getService(UgandaEMRService.class).mapPatientQueueToMapperWithOrders(patientQueueList)));
        return simpleObject;
    }

    /**
     * This Method Schedules an Order basing on the Instructions eg (Test Order, Send to Reference
     * Lab .....)
     *
     * @param orderNumber
     * @param sampleId
     * @param referenceLab
     * @return
     */
    public void scheduleTest(@RequestParam(value = "orderNumber") String orderNumber, @RequestParam(value = "sampleId") String sampleId, @RequestParam(value = "specimenSourceId", required = false) String specimenSourceId, @RequestParam(value = "referenceLab", required = false) String referenceLab, @RequestParam(value = "unProcessedOrders", required = false) Integer unProcessedOrders, @RequestParam(value = "patientQueueId", required = false) Integer patientQueueId) {
        OrderService orderService = Context.getOrderService();
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        Order order = orderService.getOrderByOrderNumber(orderNumber);

        if (referenceLab != "") {
            TestOrder testOrder = new TestOrder();
            testOrder.setAccessionNumber(sampleId);
            testOrder.setInstructions("REFER TO " + referenceLab);
            testOrder.setConcept(order.getConcept());
            testOrder.setEncounter(order.getEncounter());
            testOrder.setOrderer(order.getOrderer());
            testOrder.setPatient(order.getPatient());
            testOrder.setUrgency(Order.Urgency.STAT);
            testOrder.setCareSetting(order.getCareSetting());
            testOrder.setOrderType(order.getOrderType());
            testOrder.setPreviousOrder(order);
            testOrder.setAction(Order.Action.REVISE);
            testOrder.setFulfillerStatus(Order.FulfillerStatus.IN_PROGRESS);
            testOrder.setSpecimenSource(Context.getConceptService().getConcept(specimenSourceId));
            orderService.saveOrder(testOrder, null);
            orderService.voidOrder(order, "REVISED with new order " + testOrder.getOrderNumber());
        } else {
            orderService.updateOrderFulfillerStatus(order, Order.FulfillerStatus.IN_PROGRESS, "To be processed", sampleId);
        }

        if (unProcessedOrders.equals(1)) {
            patientQueueingService.completePatientQueue(patientQueueingService.getPatientQueueById(patientQueueId));
        }
    }


    /**
     * Get Lab Orders without Results
     *
     * @param asOfDate
     * @return
     * @throws IOException
     * @throws ParseException
     */
    public SimpleObject getOrderWithResult(@RequestParam(value = "date", required = false) String asOfDate) throws IOException, ParseException {
        SimpleObject simpleObject = new SimpleObject();
        ObjectMapper objectMapper = new ObjectMapper();
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);

        Date fromDate = new Date();
        if (!asOfDate.isEmpty()) {
            fromDate = getDateFromString(asOfDate, "yyyy-MM-dd");
        }
        List<OrderObs> orderObs = ugandaEMRService.getOrderObs(null, null, fromDate, null, null, false);
        Set<Order> orders = new HashSet<>();

        orderObs.forEach(orderObs1 -> {
            orders.add(orderObs1.getOrder());
        });

        simpleObject.put("ordersList", objectMapper.writeValueAsString(ugandaEMRService.processOrders(orders, true)));
        return simpleObject;
    }

    /**
     * Generates Sample ID on Call from interface
     *
     * @param orderNumber
     * @return
     * @throws ParseException
     * @throws IOException
     */
    public SimpleObject generateSampleID(@RequestParam(value = "orderId", required = false) String orderNumber) throws ParseException, IOException {
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        ObjectMapper objectMapper = new ObjectMapper();
        Order order = Context.getOrderService().getOrderByOrderNumber(orderNumber);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String date = sdf.format(new Date());
        String letter = order.getConcept().getConceptId().toString();
        String defaultSampleId = "";
        int id = 0;
        do {
            ++id;
            defaultSampleId = date + "-" + letter + "-" + id;
        } while (ugandaEMRService.isSampleIdExisting(defaultSampleId, orderNumber));

        return SimpleObject.create("defaultSampleId", objectMapper.writeValueAsString(defaultSampleId));
    }

    /**
     * Search for results of Test that have been done
     *
     * @param dateStr
     * @param phrase
     * @param investigationId
     * @param ui
     * @return
     */
    public List<SimpleObject> searchForResults(@RequestParam(value = "date", required = false) String dateStr, @RequestParam(value = "phrase", required = false) String phrase, @RequestParam(value = "investigation", required = false) Integer investigationId, UiUtils ui) {

        Order investigation = Context.getOrderService().getOrder(investigationId);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date date = null;
        List<SimpleObject> simpleObjects = new ArrayList<SimpleObject>();

        List<TestModel> tests = LaboratoryUtil.generateModelsFromTests(investigation);

        simpleObjects = SimpleObject.fromCollection(tests, ui, "startDate", "patientId", "patientIdentifier", "patientName", "gender", "age", "test.name", "investigation", "testId", "orderId", "sampleId", "status", "value");
        return simpleObjects;
    }

    public List<SimpleObject> getResultTemplate(@RequestParam("testId") String testId, UiUtils ui) {
        Order test = Context.getOrderService().getOrderByUuid(testId);
        if(test==null){
            test=Context.getOrderService().getOrder(Integer.parseInt(testId));
        }
        List<ParameterModel> parameters = new ArrayList<ParameterModel>();
        LaboratoryUtil.generateParameterModels(parameters, test.getConcept(), null, test);
        //Collections.sort(parameters);
        List<SimpleObject> resultsTemplate = new ArrayList<SimpleObject>();
        for (ParameterModel parameter : parameters) {
            SimpleObject resultTemplate = new SimpleObject();
            resultTemplate.put("type", parameter.getType());
            resultTemplate.put("id", parameter.getId());
            resultTemplate.put("container", parameter.getContainer());
            resultTemplate.put("containerId", parameter.getContainerId());
            resultTemplate.put("title", parameter.getTitle());
            resultTemplate.put("unit", parameter.getUnit());
            resultTemplate.put("validator", parameter.getValidator());
            resultTemplate.put("defaultValue", parameter.getDefaultValue());
            List<SimpleObject> options = new ArrayList<SimpleObject>();
            for (ParameterOption option : parameter.getOptions()) {
                SimpleObject parameterOption = new SimpleObject();
                parameterOption.put("label", option.getLabel());
                parameterOption.put("value", option.getValue());
                options.add(parameterOption);
            }
            resultTemplate.put("options", options);
            resultsTemplate.add(resultTemplate);
        }

        return resultsTemplate;
    }

    /**
     * Save Test Results
     *
     * @param resultWrapper
     * @param sessionContext
     * @return
     */
    public SimpleObject saveResult(@BindParams("wrap") ResultModelWrapper resultWrapper, UiSessionContext sessionContext) {
        Provider provider = sessionContext.getCurrentProvider();
        String result = null;
        String resultDisplay = "";
        OrderService orderService = Context.getOrderService();
        EncounterService encounterService = Context.getEncounterService();
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);

        Order test = orderService.getOrderByUuid(resultWrapper.getTestId());

        Encounter encounter = test.getEncounter();
        for (ResultModel resultModel : resultWrapper.getResults()) {
            result = resultModel.getSelectedOption() == null ? resultModel.getValue() : resultModel.getSelectedOption();
            if (StringUtils.isBlank(result)) {
                continue;
            }
            if (StringUtils.contains(resultModel.getConceptName(), ".")) {
                String[] parentChildConceptIds = StringUtils.split(resultModel.getConceptName(), ".");
                Concept testGroupConcept = Context.getConceptService().getConcept(parentChildConceptIds[0]);
                Concept testConcept = Context.getConceptService().getConcept(parentChildConceptIds[1]);
                ugandaEMRService.addLaboratoryTestObservation(encounter, testConcept, testGroupConcept, result, test);
                if (StringUtils.isNumeric(result)) {
                    resultDisplay += testConcept.getName().getName() + "\t" + Context.getConceptService().getConcept(result).getName().getName() + "\n";
                } else {
                    resultDisplay += testConcept.getName().getName() + "\t" + result + "\n";
                }
            } else {
                Concept concept = Context.getConceptService().getConcept(resultModel.getConceptName());
                ugandaEMRService.addLaboratoryTestObservation(encounter, concept, null, result, test);
                resultDisplay += concept.getName().getName() + "\t" + result + "\n";
            }
        }

        encounter = encounterService.saveEncounter(encounter);
        try {
            orderService.updateOrderFulfillerStatus(test, Order.FulfillerStatus.IN_PROGRESS, "Completed with results: " + resultDisplay);
            saveOrderObservations(encounter);
            sendPatientBackToClinician(encounter, encounter.getLocation(), sessionContext.getSessionLocation(), QUEUE_STATUS_SENT_TO_LAB);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return SimpleObject.create("status", "success", "message", "Saved!");
    }

    public SimpleObject approveResults(@RequestParam(value = "orders") String orders) {
        OrderService orderService = Context.getOrderService();

        String[] orderIds = orders.split(",");
        for (Object orderNumber : orderIds) {
            Order test = orderService.getOrder(Integer.parseInt(orderNumber.toString()));
            orderService.updateOrderFulfillerStatus(test, Order.FulfillerStatus.COMPLETED, test.getFulfillerComment());
        }
        return SimpleObject.create("status", "success", "message", "Approved!");
    }


    private void saveOrderObservations(Encounter encounter) {
        encounter.getAllObs().stream().filter(obs -> obs.getOrder() != null).forEach(obs -> {
            OrderObs orderObs = new OrderObs(obs.getOrder(), obs, obs.getEncounter());
            Context.getService(UgandaEMRService.class).saveOrderObs(orderObs);
        });
    }

    private PatientQueue sendPatientBackToClinician(Encounter encounter, Location locationTo, Location locationFrom, String previousQueueStatus) throws ParseException {
        PatientQueue patientQueue = new PatientQueue();

        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        Provider provider = ugandaEMRService.getProviderFromEncounter(encounter);

        SimpleObject simpleObject = new SimpleObject();
        SimpleObject orders = null;
        try {
            simpleObject = ugandaEMRService.getProcessedOrders(PROCESSED_ORDER_WITHOUT_RESULT_QUERY.concat(" AND patient_id=" + encounter.getPatient().getPatientId()), encounter.getDateCreated(), false);
            orders = (SimpleObject) simpleObject.get("ordersList");
        } catch (ParseException | IOException e) {
            log.error(e);
        }

        if (orders == null) {
            ugandaEMRService.completePreviousQueue(encounter.getPatient(), encounter.getLocation(), PatientQueue.Status.PENDING);
        }

        List<PatientQueue> patientQueueList = patientQueueingService.getPatientQueueList(null, OpenmrsUtil.firstSecondOfDay(new Date()), OpenmrsUtil.getLastMomentOfDay(new Date()), null, null, encounter.getPatient(), null);

        List<PatientQueue> fromLabQueue = new ArrayList<>();

        for (PatientQueue potentialQueueFromLab : patientQueueList) {
            if (potentialQueueFromLab.getEncounter() != null && potentialQueueFromLab.getEncounter().equals(encounter) && potentialQueueFromLab.getStatus() != null && potentialQueueFromLab.getStatus().equals(PatientQueue.Status.PENDING) && potentialQueueFromLab.getLocationFrom() == locationFrom && potentialQueueFromLab.getLocationTo().equals(encounter.getLocation())) {
                fromLabQueue.add(patientQueue);
            }
        }

        boolean queueExists = ugandaEMRService.patientQueueExists(encounter, encounter.getLocation(), locationFrom, PatientQueue.Status.PENDING);

        if (!queueExists) {
            if (fromLabQueue.isEmpty()) {
                patientQueue.setLocationFrom(locationFrom);
                patientQueue.setPatient(encounter.getPatient());
                patientQueue.setLocationTo(encounter.getLocation());
                patientQueue.setProvider(provider);
                patientQueue.setEncounter(encounter);
                patientQueue.setStatus(PatientQueue.Status.PENDING);
                patientQueue.setCreator(Context.getUserService().getUsersByPerson(provider.getPerson(), false).get(0));
                patientQueue.setDateCreated(new Date());
                patientQueueingService.assignVisitNumberForToday(patientQueue);
                patientQueueingService.savePatientQue(patientQueue);
            }
        }

        return patientQueue;
    }



    private Date getDateFromString(String dateString, String format) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        try {
            // Parse the string and convert it to a Date object
            return dateFormat.parse(dateString);
        } catch (Exception e) {
            log.error(e);
        }
        return new Date();
    }
}
