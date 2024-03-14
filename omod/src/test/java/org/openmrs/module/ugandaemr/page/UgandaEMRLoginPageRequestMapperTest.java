package org.openmrs.module.ugandaemr.page;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import org.junit.jupiter.api.Test;
import org.openmrs.ui.framework.page.PageRequest;
import org.openmrs.ui.framework.session.Session;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockHttpSession;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Created by ssmusoke on 18/02/2016.
 */
public class UgandaEMRLoginPageRequestMapperTest {

	@Test
	public void overrideRequestForReferenceApplicationLoginPage() {
		PageRequest request = createPageRequest(null, null);
		request.setProviderName("referenceapplication");
		request.setPageName("login");

		assertEquals(request.getMappedProviderName(), "referenceapplication");
		assertEquals(request.getMappedPageName(), "login");

		UgandaEMRLoginPageRequestMapper mapper = new UgandaEMRLoginPageRequestMapper();

		assertTrue(mapper.mapRequest(request));
		assertEquals(request.getMappedProviderName(), "ugandaemr");
		assertEquals(request.getMappedPageName(), "ugandaEMRLogin");

	}

	private PageRequest createPageRequest(HttpServletRequest httpRequest, HttpServletResponse httpResponse) {
		HttpServletRequest request = (httpRequest != null) ? httpRequest : new MockHttpServletRequest();
		HttpServletResponse response = (httpResponse != null) ? httpResponse : new MockHttpServletResponse();
		return new PageRequest(null, null, request, response, new Session(new MockHttpSession()));
	}
}
