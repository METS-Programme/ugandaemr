package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Location;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.pharmacy.DispensingModelWrapper;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.annotation.BindParams;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import static org.openmrs.module.ugandaemr.UgandaEMRConstants.*;
import static org.openmrs.module.ugandaemr.UgandaEMRConstants.PHARMACY_LOCATION_UUID;

public class PharmacyQueueListFragmentController {

    protected final Log log = LogFactory.getLog(PharmacyQueueListFragmentController.class);

    public PharmacyQueueListFragmentController() {
        // This Method is a Constructor
    }

    public void controller(@SpringBean FragmentModel pageModel, UiSessionContext uiSessionContext) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String dateStr = sdf.format(new Date());
        List<String> list = new ArrayList();

        list.addAll(Context.getLocationService().getLocationsByTag(Context.getLocationService().getLocationTagByUuid("fe7c970f-2aba-11ed-ba4a-507b9dea1806")).stream().map(Location::getUuid).collect(Collectors.toList()));
        list.addAll(Context.getLocationService().getLocationsByTag(Context.getLocationService().getLocationTagByUuid("89a80c4d-2899-11ed-bdcb-507b9dea1806")).stream().map(Location::getUuid).collect(Collectors.toList()));

        pageModel.addAttribute("currentDate", dateStr);
        pageModel.addAttribute("locationSession", uiSessionContext.getSessionLocation().getUuid());
        pageModel.put("clinicianLocation", list);
        pageModel.put("currentProvider", uiSessionContext.getCurrentProvider());
        pageModel.put("healthCenterName", Context.getAdministrationService().getGlobalProperty(UgandaEMRConstants.GP_HEALTH_CENTER_NAME));
        pageModel.put("enablePatientQueueSelection", Context.getAdministrationService().getGlobalProperty("ugandaemr.enablePatientQueueSelection"));
        pageModel.put("enableStockManagement", Boolean.parseBoolean(Context.getAdministrationService().getGlobalProperty("ugandaemr.enableStockManagement")));
    }


    public SimpleObject getPharmacyQueueList(@RequestParam(value = "pharmacySearchFilter", required = false) String searchfilter, UiSessionContext uiSessionContext) throws IOException, ParseException {
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleObject simpleObject = new SimpleObject();
        List<PatientQueue> patientQueueList;
        if (!searchfilter.equals("")) {
            patientQueueList = patientQueueingService.getPatientQueueListBySearchParams(searchfilter, OpenmrsUtil.firstSecondOfDay(new Date()), OpenmrsUtil.getLastMomentOfDay(new Date()), uiSessionContext.getSessionLocation(), null, null);
        } else {
            patientQueueList = patientQueueingService.getPatientQueueListBySearchParams(null, OpenmrsUtil.firstSecondOfDay(new Date()), OpenmrsUtil.getLastMomentOfDay(new Date()), uiSessionContext.getSessionLocation(), null, null);
        }
        if (!patientQueueList.isEmpty()) {
            simpleObject.put("patientPharmacyQueueList", objectMapper.writeValueAsString(Context.getService(UgandaEMRService.class).mapPatientQueueToMapperWithDrugOrders(patientQueueList)));
        } else {
            simpleObject.put("patientPharmacyQueueList", "");
        }

        return simpleObject;
    }

    public SimpleObject dispense(@BindParams("wrap") DispensingModelWrapper resultWrapper, UiSessionContext sessionContext) throws Exception {
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        return ugandaEMRService.dispenseMedication(resultWrapper, sessionContext.getCurrentProvider(), sessionContext.getSessionLocation());
    }


}
