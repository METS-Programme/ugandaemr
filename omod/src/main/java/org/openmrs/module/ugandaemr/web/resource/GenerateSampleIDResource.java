/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 * <p>
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * <p>
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandaemr.web.resource;

import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.web.customdto.SampleId;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.DefaultRepresentation;
import org.openmrs.module.webservices.rest.web.representation.RefRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResourceDoesNotSupportOperationException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Resource(name = RestConstants.VERSION_1
        + "/generatesampleId", supportedClass = SampleId.class, supportedOpenmrsVersions = {"1.9.* - 9.*"})
public class GenerateSampleIDResource extends DelegatingCrudResource<SampleId> {

    @Override
    public List<Representation> getAvailableRepresentations() {
        return Arrays.asList(Representation.DEFAULT, Representation.FULL);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {
        if ((rep instanceof DefaultRepresentation) || (rep instanceof RefRepresentation)) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("sampleId", Representation.DEFAULT);
            return description;
        }
        return null;
    }

    @Override
    public SampleId getByUniqueId(String uuid) {
        throw new ResourceDoesNotSupportOperationException("delete of bed patient assignment not supported");
    }

    @Override
    protected void delete(SampleId bedPatientAssignment, String s, RequestContext requestContext)
            throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("delete of bed patient assignment not supported");
    }

    @Override
    public void purge(SampleId bedPatientAssignment, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("purge of bed patient assignment not supported");
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() throws ResourceDoesNotSupportOperationException {
        throw new ResourceDoesNotSupportOperationException("create of bed patient assignment not supported");
    }

    @Override
    public SampleId newDelegate() {
        throw new ResourceDoesNotSupportOperationException("create of bed patient assignment not supported");
    }

    @Override
    public SampleId save(SampleId bedPatientAssignment) {
        throw new ResourceDoesNotSupportOperationException("save of bed patient assignment not supported");
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        String orderNumber = context.getRequest().getParameter("uuid");

        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        ObjectMapper objectMapper = new ObjectMapper();
        Order order = Context.getOrderService().getOrderByUuid(orderNumber);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String date = sdf.format(new Date());
        String letter = order.getConcept().getConceptId().toString();
        String defaultSampleId = "";
        int id = 0;
        try {
            do {
                ++id;
                defaultSampleId = date + "-" + letter + "-" + id;
            } while (ugandaEMRService.isSampleIdExisting(defaultSampleId, orderNumber));
        } catch (Exception e) {
            log.error(e);
        }
        List<SampleId> sampleIds = new ArrayList<>();
        SampleId sampleId = new SampleId();
        sampleId.setSampleId(defaultSampleId);
        sampleIds.add(sampleId);

        return new NeedsPaging<SampleId>(sampleIds, context);
    }
}
