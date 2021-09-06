package org.openmrs.module.ugandaemr.fragment.controller.patientsearch.covid;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Patient;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appframework.domain.Extension;
import org.openmrs.module.appframework.service.AppFrameworkService;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.coreapps.CoreAppsConstants;
import org.openmrs.module.emrapi.utils.GeneralUtils;
import org.openmrs.ui.framework.UiFrameworkConstants;
import org.openmrs.ui.framework.annotation.FragmentParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsConstants;

import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import static org.openmrs.module.ugandaemrfingerprint.core.FingerPrintConstant.PATIENT_NATIONAL_ID_SIMPLE_SEARCH_STRING;
/**
 * Fragment controller for patient search widget; sets the min # of search characters based on
 * global property, and loads last viewed patients for current user if "showLastViewedPatients"
 * fragment config param=true
 */
public class PatientSearchWidgetFragmentController {
	
	public static final String PATIENT_PRISONER_SEARCH_PATIENT_DETAILS_SUMMARY_LAST_ENCOUNTER_STRING = "{patient(identifier:{t:\"e7dad84a-9ae9-4be2-9ec2-62fc8832cffa\",v:\"%s\"}){uuid,birthdate,gender,dead,patientFacility{uuid,name},names{familyName,middleName,givenName,voided},addresses{country,countyDistrict,stateProvince,address3,address4,address5,address6},identifiers{identifier,identifierType},attributes{value,personAttributeType},mostRecentEncounter{obs{uuid,concept,encounterDate,encounterType,valueCoded,valueText,valueNumeric,valueDatetime,valueDrug,valueBoolean,valueComplex,voided}},summaryPage{obs{uuid,concept,encounterDate,encounterType,valueCoded,valueText,valueNumeric,valueDatetime,valueDrug,valueBoolean,valueComplex,voided}}}}";
	
	public static final String PATIENT_HIV_OBS_QUERY_STRING = "{patientObs(patientuuid:\"%s\",conceptsuuid:[\"dcdfe3ce-30ab-102d-86b0-7a5022ba4115\",\"dce12b4f-30ab-102d-86b0-7a5022ba4115\",\"ddcd8aad-9085-4a88-a411-f19521be4785\",\"89d3ee61-7c74-4537-b199-4026bd6a3f67\",\"ab505422-26d9-41f1-a079-c3d222000440\",\"c3332e8d-2548-4ad6-931d-6855692694a3\",\"dd2b0b4d-30ab-102d-86b0-7a5022ba4115\"]){concept,valueDrug,valueText,valueGroup,valueCoded,valueBoolean,valueNumeric,valueDatetime,valueCodedName}}";
	
	public void controller(FragmentModel model, UiSessionContext sessionContext, HttpServletRequest request,
	        @SpringBean("adminService") AdministrationService administrationService,
	        @SpringBean("appFrameworkService") AppFrameworkService appFrameworkService,
	        @FragmentParam(value = "showLastViewedPatients", required = false) Boolean showLastViewedPatients,
	        @FragmentParam(value = "initialSearchFromParameter", required = false) String searchByParam,
	        @FragmentParam(value = "registrationAppLink", required = false) String registrationAppLink) {
		
		showLastViewedPatients = showLastViewedPatients != null ? showLastViewedPatients : false;
		
		model.addAttribute("minSearchCharacters",
		    administrationService.getGlobalProperty(OpenmrsConstants.GLOBAL_PROPERTY_MIN_SEARCH_CHARACTERS, "1"));
		
		model.addAttribute("searchDelayShort",
		    administrationService.getGlobalProperty(CoreAppsConstants.GP_SEARCH_DELAY_SHORT, "300"));
		
		model.addAttribute("searchDelayLong",
		    administrationService.getGlobalProperty(CoreAppsConstants.GP_SEARCH_DELAY_LONG, "1000"));
		
		model.addAttribute("dateFormatJS", "DD MMM YYYY"); // TODO really should be driven by global property, but currently we only have a property for the java date format
		model.addAttribute("locale", Context.getLocale().getLanguage());
		model.addAttribute("defaultLocale",
		    new Locale(administrationService.getGlobalProperty((OpenmrsConstants.GLOBAL_PROPERTY_DEFAULT_LOCALE), "en"))
		            .getLanguage());
		model.addAttribute("dateFormatter",
		    new SimpleDateFormat(administrationService.getGlobalProperty(UiFrameworkConstants.GP_FORMATTER_DATE_FORMAT),
		            Context.getLocale()));
		model.addAttribute("searchWidgetDateFormatter", new SimpleDateFormat("yyyy-MM-dd"));
		model.addAttribute("showLastViewedPatients", showLastViewedPatients);
		
		String doInitialSearch = null;
		if (searchByParam != null && StringUtils.isNotEmpty(request.getParameter(searchByParam))) {
			doInitialSearch = request.getParameter(searchByParam);
		}
		model.addAttribute("doInitialSearch", doInitialSearch);
		
		AdministrationService administrationService1 = Context.getAdministrationService();
		
		model.addAttribute("searchOnline", administrationService.getGlobalProperty("ugandaemrfingerprint.searchOnline"));
		model.addAttribute("simpleNationalIdString", PATIENT_NATIONAL_ID_SIMPLE_SEARCH_STRING);
		model.addAttribute("patientObsQuery", PATIENT_HIV_OBS_QUERY_STRING);
		model.addAttribute("onlineIpAddress", administrationService.getGlobalProperty("ugandaemrsync.serverIP"));
		model.addAttribute("connectionProtocol", administrationService.getGlobalProperty("ugandaemrsync.protocol"));
		model.addAttribute("queryURL", "/api/query");
		model.addAttribute("queryUsername", "user");
		model.addAttribute("queryPassword", "password");
		
		if (showLastViewedPatients) {
			List<Patient> patients = GeneralUtils.getLastViewedPatients(sessionContext.getCurrentUser());
			model.addAttribute("lastViewedPatients", patients);
		}
		
		String listingAttributeTypesStr = administrationService.getGlobalProperty(
		    OpenmrsConstants.GLOBAL_PROPERTY_PATIENT_LISTING_ATTRIBUTES, "");
		List<String> listingAttributeTypeNames = new ArrayList<String>();
		if (StringUtils.isNotBlank(listingAttributeTypesStr)) {
			String[] attTypeNames = StringUtils.split(listingAttributeTypesStr.trim(), ",");
			for (String name : attTypeNames) {
				if (StringUtils.isNotBlank(name.trim())) {
					listingAttributeTypeNames.add(name.trim());
				}
			}
		}
		model.addAttribute("listingAttributeTypeNames", listingAttributeTypeNames);
		model.addAttribute("registrationAppLink", registrationAppLink);
		
		List<Extension> patientSearchExtensions = appFrameworkService
		        .getExtensionsForCurrentUser("coreapps.patientSearch.extension");
		Collections.sort(patientSearchExtensions);
		model.addAttribute("patientSearchExtensions", patientSearchExtensions);
		
		model.put("summaryPage", administrationService.getGlobalProperty("ugandaemrfingerprint.showOnlinePatientSummary"));
		model.put("displaySummaryPage",
		    administrationService.getGlobalProperty("ugandaemrfingerprint.showOnlinePatientSummary"));
		model.put("mostRecentEncounter",
		    administrationService.getGlobalProperty("ugandaemrfingerprint.showOnlinePatientLastTreatmentEncounter"));
		model.put("displayMostRecentEncounter",
		    administrationService.getGlobalProperty("ugandaemrfingerprint.showOnlinePatientLastTreatmentEncounter"));
		model.put(
		    "url",
		    administrationService.getGlobalProperty("ugandaemrsync.protocol")
		            + administrationService.getGlobalProperty("ugandaemrsync.serverIP") + "/api/query");
	}
	
}
