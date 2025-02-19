package org.openmrs.module.ugandaemr.activator;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.FormService;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.utils.ExtensionFormUtil;
import org.openmrs.module.formentryapp.FormEntryAppService;
import org.openmrs.module.formentryapp.FormManager;
import org.openmrs.module.formentryapp.page.controller.forms.ExtensionForm;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.htmlformentry.HtmlFormEntryService;
import org.openmrs.module.htmlformentryui.HtmlFormUtil;
import org.openmrs.ui.framework.resource.ResourceFactory;
import org.openmrs.ui.framework.resource.ResourceProvider;

/**
 * Sets up the HFE forms
 * 1) Scans the webapp/resources/htmlforms folder
 * 2) Attempts to create an HFE form from each of the files
 * 3) Adds the forms as in Configure Metadata \ Manage Forms
 */
public class HtmlFormsInitializer implements Initializer {

    protected static final Log log = LogFactory.getLog(HtmlFormsInitializer.class);

    protected static final String formsPath = "htmlforms/";

    protected String providerName;
    private String formFilePath;

    public HtmlFormsInitializer(String newProviderName,String newFormFilePath) {
        this.providerName = newProviderName;
        this.formFilePath = newFormFilePath;
    }

    /**
     * @see Initializer#started()
     */
    public synchronized void started() {
        log.info("Setting HFE forms for " + getProviderName());

         ResourceFactory resourceFactory = ResourceFactory.getInstance();
         ResourceProvider resourceProvider = resourceFactory.getResourceProviders().get(getProviderName());
         String fileFormPathLocal=formsPath;

        // Scanning the forms resources folder
         List<String> formPaths = new ArrayList<String>();
        if(!formFilePath.equals("")){
            fileFormPathLocal=this.formFilePath;
        }
         File formsDir = resourceProvider.getResource(fileFormPathLocal);
        if(!formFilePath.equals("")){
            resourceProvider.getResource(fileFormPathLocal);
        }
        if (formsDir == null || formsDir.isDirectory() == false) {
            log.error("No HTML forms could be retrieved from the provided folder: " + getProviderName() + ":" + fileFormPathLocal);
            return;
        }
        for (File file : formsDir.listFiles())
            formPaths.add(fileFormPathLocal + file.getName());    // Adding each file's path to the list

        // Save form + add its meta data
        final FormManager formManager = Context.getRegisteredComponent("formManager", FormManager.class);
        final FormEntryAppService hfeAppService = Context.getRegisteredComponent("formEntryAppService", FormEntryAppService.class);
        final FormService formService = Context.getFormService();
        final HtmlFormEntryService hfeService = Context.getService(HtmlFormEntryService.class);
        for (String formPath : formPaths) {
            // Save form
            HtmlForm htmlForm = null;
            try {
                htmlForm = HtmlFormUtil.getHtmlFormFromUiResource(resourceFactory, formService, hfeService, getProviderName(), formPath);
                try {
                    // Adds meta data
                    ExtensionForm extensionForm = ExtensionFormUtil.getExtensionFormFromUiResourceAndForm(resourceFactory, getProviderName(), formPath, hfeAppService, formManager, htmlForm.getForm());
                    log.info("The form at " + formPath + " has been successfully loaded with its metadata");
                } catch (Exception e) {
                    log.error("The form was created but its extension point could not be created in Manage Forms \\ Configure Metadata: " + formPath, e);
                    throw new RuntimeException("The form was created but its extension point could not be created in Manage Forms \\ Configure Metadata: " + formPath, e);
                }
            } catch (IOException e) {
                log.error("Could not generate HTML form from the following resource file: " + formPath, e);
                throw new RuntimeException("Could not generate HTML form from the following resource file: " + formPath, e);
            } catch (IllegalArgumentException e) {
                log.error("Error while parsing the form's XML: " + formPath, e);
                throw new IllegalArgumentException("Error while parsing the form's XML: " + formPath, e);
            }
            
        }
    }

    /**
     * @see Initializer#stopped()
     */
    public void stopped() {
        //TODO: Perhaps disable the forms?
    }

    /**
     * Get the name of the provider where the forms are located - useful when extending this functionlality
     *
     * @return the name of the provider
     */
    public String getProviderName() {
        return this.providerName;
    }

}
