package org.openmrs.module.ugandaemr.fragment.controller;

import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Order;
import org.openmrs.api.OrderService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.api.lab.util.TestResultModel;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Created by Francis on 2/3/2016.
 */
public class ReviewResultsFragmentController {

	public void controller(UiSessionContext sessionContext, FragmentModel model) {

		sessionContext.requireAuthentication();
		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
		String dateStr = sdf.format(new Date());
		model.addAttribute("currentDate", dateStr);
		model.put("currentProvider", sessionContext.getCurrentProvider());
		model.addAttribute("healthCenter", Context.getAdministrationService().getGlobalProperty("ugandaemr.healthCenterName"));
	}

	/**
	 * Getting Results
	 *
	 * @param testId
	 * @param ui
	 * @return
	 */
	public SimpleObject getResults(@RequestParam(value = "testId") Integer testId, UiUtils ui) throws IOException {
		if (testId != null) {
			Order labTest = Context.getOrderService().getOrder(testId);
			UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);

			ObjectMapper objectMapper = new ObjectMapper();
			Set<TestResultModel> trms = ugandaEMRService.renderTests(labTest);

			List<SimpleObject> results = SimpleObject.fromCollection(trms, ui, "investigation", "set", "test", "value",
			    "hiNormal", "lowNormal", "lowAbsolute", "hiAbsolute", "hiCritical", "lowCritical", "unit", "level",
			    "concept", "encounterId", "testId","testUuid");

			SimpleObject currentResults = SimpleObject.create("data", objectMapper.writeValueAsString(results),"order",objectMapper.writeValueAsString(labTest.getUuid()));
			return currentResults;
		}
		return null;
	}
}
