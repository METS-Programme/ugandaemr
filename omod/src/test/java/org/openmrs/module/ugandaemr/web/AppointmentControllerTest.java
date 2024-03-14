/*
package org.openmrs.module.ugandaemr.web;

import org.apache.commons.beanutils.PropertyUtils;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RestConstants;

import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.bind.annotation.RequestMethod;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppointmentControllerTest extends RestControllerTestUtils {

    @BeforeEach
    public void setUp() throws Exception {
        executeDataSet("org/openmrs/module/ugandaemr/include/standardTestDataset.xml");
        executeDataSet("org/openmrs/module/ugandaemr/include/appointmentDataSet.xml");
    }

    @Test
    public void shouldReturnPatientsWhenNoSpecifiedEncounterUuids() throws Exception {
        String requestURI = "/rest/" + RestConstants.VERSION_1 + "/ugandaemr/appointmentcount";
        MockHttpServletRequest request = new MockHttpServletRequest(RequestMethod.GET.toString(), requestURI);
        request.addParameter("nextAppointmentDate", "14/08/2008");
        SimpleObject result = deserialize(handle(request));
        assertEquals("2008-08-14",PropertyUtils.getProperty(result, "appointmentdate"));
        assertEquals("",PropertyUtils.getProperty(result, "encountertypeUuid"));
        assertEquals(3,PropertyUtils.getProperty(result, "appointmentcount"));

    }

    @Test
    public void shouldReturnPatientsWithSpecifiedEncounterUuid() throws Exception {
        String requestURI = "/rest/" + RestConstants.VERSION_1 + "/ugandaemr/appointmentcount";
        MockHttpServletRequest request = new MockHttpServletRequest(RequestMethod.GET.toString(), requestURI);
        request.addParameter("nextAppointmentDate", "14/08/2008");
        request.addParameter("encounterTypeUuid", "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f");
        SimpleObject result = deserialize(handle(request));
        assertEquals("2008-08-14",PropertyUtils.getProperty(result, "appointmentdate"));
        assertEquals("8d5b2be0-c2cc-11de-8d13-0010c6dffd0f",PropertyUtils.getProperty(result, "encountertypeUuid"));
        assertEquals(2,PropertyUtils.getProperty(result, "appointmentcount"));
    }

    @Test
    public void shouldReturnPatientsWithSpecifiedEncounterUuids() throws Exception {
        String requestURI = "/rest/" + RestConstants.VERSION_1 + "/ugandaemr/appointmentcount";
        MockHttpServletRequest request = new MockHttpServletRequest(RequestMethod.GET.toString(), requestURI);
        request.addParameter("nextAppointmentDate", "14/08/2008");
        request.addParameter("encounterTypeUuid",
                "8d5b2be0-c2cc-11de-8d13-0010c6dffd0f,334bf97e-28e2-4a27-8727-a5ce31c7cd66");
        SimpleObject result = deserialize(handle(request));
        assertEquals("2008-08-14",PropertyUtils.getProperty(result, "appointmentdate"));
        assertEquals("8d5b2be0-c2cc-11de-8d13-0010c6dffd0f,334bf97e-28e2-4a27-8727-a5ce31c7cd66",PropertyUtils.getProperty(result, "encountertypeUuid"));
        assertEquals(3,PropertyUtils.getProperty(result, "appointmentcount"));
    }

    @Test
    public void shouldReturnNoPatientsWhenSpecifiedDateDoesntHaveEncounter() throws Exception {
        String requestURI = "/rest/" + RestConstants.VERSION_1 + "/ugandaemr/appointmentcount";
        MockHttpServletRequest request = new MockHttpServletRequest(RequestMethod.GET.toString(), requestURI);
        request.addParameter("nextAppointmentDate", "01/01/1980");
        SimpleObject result = deserialize(handle(request));
        assertEquals(0,PropertyUtils.getProperty(result, "appointmentcount"));
    }

    @Test
    public void shouldReturnNoPatientsWhenSpecifiedEncounterUuidDoesntExist() throws Exception {
        String requestURI = "/rest/" + RestConstants.VERSION_1 + "/ugandaemr/appointmentcount";
        MockHttpServletRequest request = new MockHttpServletRequest(RequestMethod.GET.toString(), requestURI);
        request.addParameter("nextAppointmentDate", "14/08/2008");
        request.addParameter("encounterTypeUuid", "8p5b2be0-c2cc-11de-8d13-0010c6dffd0f");
        SimpleObject result = deserialize(handle(request));
        assertEquals(0,PropertyUtils.getProperty(result, "appointmentcount"));
    }
}

*/
