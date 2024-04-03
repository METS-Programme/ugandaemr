package org.openmrs.module.ugandaemr.page.controller;

import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

public class ManageProviderPageController {

    protected final org.apache.commons.logging.Log log = LogFactory.getLog(ManageProviderPageController.class);

    public ManageProviderPageController() {
    }

    public void controller(@SpringBean PageModel pageModel, @RequestParam(value = "breadcrumbOverride", required = false) String breadcrumbOverride, UiSessionContext sessionContext, PageModel model, UiUtils ui) {


        pageModel.put("breadcrumbOverride", breadcrumbOverride);
        pageModel.put("providers", Context.getProviderService().getAllProviders(false));
    }
}
