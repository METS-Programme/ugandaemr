/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 * <p/>
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * <p/>
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandaemr;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.ConceptService;
import org.openmrs.api.LocationService;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.Module;
import org.openmrs.module.ModuleActivator;
import org.openmrs.module.ModuleFactory;
import org.openmrs.module.ugandaemr.activator.AppConfigurationInitializer;
import org.openmrs.module.ugandaemr.activator.HtmlFormsInitializer;
import org.openmrs.module.ugandaemr.activator.Initializer;
import org.openmrs.module.ugandaemr.activator.JsonFormsInitializer;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.api.deploy.bundle.CommonMetadataBundle;
import org.openmrs.module.ugandaemr.api.deploy.bundle.UgandaAddressMetadataBundle;
import org.openmrs.module.ugandaemr.api.deploy.bundle.UgandaEMRPatientFlagMetadataBundle;
import org.openmrs.module.ugandaemr.metadata.core.PatientIdentifierTypes;
import org.openmrs.module.appframework.service.AppFrameworkService;
import org.openmrs.module.dataexchange.DataImporter;
import org.openmrs.module.emrapi.EmrApiConstants;
import org.openmrs.module.emrapi.utils.MetadataUtil;
import org.openmrs.module.idgen.IdentifierSource;
import org.openmrs.module.idgen.service.IdentifierSourceService;
import org.openmrs.module.metadatadeploy.api.MetadataDeployService;
import org.openmrs.module.metadatamapping.MetadataTermMapping;
import org.openmrs.module.metadatamapping.api.MetadataMappingService;
import org.openmrs.notification.AlertService;
import org.openmrs.util.OpenmrsUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * This class contains the logic that is run every time this module is either started or stopped.
 * <p>
 * TODO: Refactor the whole class to use initializers like
 */
public class UgandaEMRActivator extends org.openmrs.module.BaseModuleActivator {

    protected Log log = LogFactory.getLog(getClass());

    /**
     * @see ModuleActivator#willRefreshContext()
     */
    public void willRefreshContext() {
        log.info("Refreshing ugandaemr Module");
    }

    /**
     * @see ModuleActivator#contextRefreshed()
     */
    public void contextRefreshed() {
        log.info("ugandaemr Module refreshed");
    }

    /**
     * @see ModuleActivator#willStart()
     */
    public void willStart() {
        log.info("Starting ugandaemr Module");
    }

    /**
     * @see ModuleActivator#started()
     */
    public void started() {
        String initialiseMetaDataOnStart=Context.getAdministrationService().getGlobalProperty("ugandaemr.initialiseMetadataOnStart");
        if(initialiseMetaDataOnStart.equals("true")) {
            Context.getService(UgandaEMRService.class).initaliseMetaData();
        }
    }
    /**
     * @see ModuleActivator#willStop()
     */
    public void willStop() {
        log.info("Stopping ugandaemr Module");
    }

    /**
     * @see ModuleActivator#stopped()
     */
    public void stopped() {

        log.info("ugandaemr Module stopped");
    }
}