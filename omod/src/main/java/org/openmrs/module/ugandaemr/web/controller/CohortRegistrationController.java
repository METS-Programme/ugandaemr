package org.openmrs.module.ugandaemr.web.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.util.JSONPObject;
import org.json.JSONObject;
import org.openmrs.Cohort;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.UgandaEMRConstants;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;


@Controller
public class CohortRegistrationController {

	private final Log log = LogFactory.getLog(CohortRegistrationController.class);

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/delete", method = RequestMethod.GET)
	@ResponseBody
	public SimpleObject deleteCohort(
			@RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);
		SimpleObject response = new SimpleObject();
		Context.getCohortService().voidCohort(cohort,"retired");


		response.add("message", "Cohort Deleted");

		return response;
	}

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/edit", method = RequestMethod.GET)
	@ResponseBody
	public SimpleObject editCohort(
			@RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);
		SimpleObject response = new SimpleObject();

		response.add("name", cohort.getName());
		response.add("description", cohort.getDescription());
		response.add("uuid", cohort.getUuid());

		return response;
	}

	@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/" + UgandaEMRConstants.UGANDAEMR_MODULE_ID
			+ "/cohort/saveEdit", method = RequestMethod.POST)
	@ResponseBody
	public SimpleObject saveEditedCohort(HttpServletRequest request,@RequestBody String body,
			@RequestParam(required = true, value = "uuid") String cohortUuid) {

		Cohort cohort = Context.getCohortService().getCohortByUuid(cohortUuid);

		JSONObject newBody  = new JSONObject(body);
		cohort.setName(newBody.getString("name"));
		cohort.setDescription(newBody.getString("description"));
		cohort.setUuid(newBody.getString("uuid"));

		Context.getCohortService().saveCohort(cohort);

		SimpleObject response = new SimpleObject();

		response.add("name", cohort.getName());
		response.add("description", cohort.getDescription());
		response.add("uuid", cohort.getUuid());

		return response;
	}

}
