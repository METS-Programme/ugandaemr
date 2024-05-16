package org.openmrs.module.ugandaemr.web.resource;

import org.openmrs.TestOrder;
import org.openmrs.api.OrderService;
import org.openmrs.api.context.Context;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.web.customdto.AccessionOrder;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.ConversionUtil;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.DefaultRepresentation;
import org.openmrs.module.webservices.rest.web.representation.FullRepresentation;
import org.openmrs.module.webservices.rest.web.representation.RefRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingCrudResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResourceDoesNotSupportOperationException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;
import org.openmrs.module.webservices.validation.ValidateUtil;

import java.util.Arrays;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + "/accessionorder", supportedClass = AccessionOrder.class, supportedOpenmrsVersions = {"1.9.* - 9.*"})
public class AccessionOrderResource extends DelegatingCrudResource<AccessionOrder> {

    @Override
    public AccessionOrder newDelegate() {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public AccessionOrder save(AccessionOrder TestResult) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public Object create(SimpleObject propertiesToCreate, RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public Object update(String uuid, SimpleObject propertiesToUpdate, RequestContext context) throws ResponseException {
        OrderService orderService = Context.getOrderService();
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        if (propertiesToUpdate.get("sampleId") != null || propertiesToUpdate.get("sampleId") != "null" || propertiesToUpdate.get("sampleId") != "") {
            TestOrder testOrder = ugandaEMRService.accessionLabTest(uuid, propertiesToUpdate.get("sampleId").toString(), propertiesToUpdate.get("specimenSourceId").toString(), propertiesToUpdate.get("referenceLab").toString());

            if (propertiesToUpdate.get("unProcessedOrders").toString().equals(1)) {
                patientQueueingService.completePatientQueue(patientQueueingService.getPatientQueueByUuid(propertiesToUpdate.get("patientQueueId").toString()));
            }

            AccessionOrder delegate = new AccessionOrder();

            delegate.setOrder(testOrder);

            ValidateUtil.validate(delegate);
            SimpleObject ret = (SimpleObject) ConversionUtil.convertToRepresentation(testOrder, context.getRepresentation());
            // add the 'type' discriminator if we support subclasses
            if (hasTypesDefined()) {
                ret.add(RestConstants.PROPERTY_FOR_TYPE, getTypeName(delegate));
            }
            return ret;
        }else {
            throw new ResourceDoesNotSupportOperationException("The accession number or the barcode or the sample id is required");
        }
    }

    @Override
    public AccessionOrder getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public NeedsPaging<AccessionOrder> doGetAll(RequestContext context) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public List<Representation> getAvailableRepresentations() {
        return Arrays.asList(Representation.DEFAULT, Representation.FULL);
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation rep) {
        if (rep instanceof DefaultRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("order");
            description.addSelfLink();
            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("order", Representation.REF);
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("order", Representation.REF);
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected void delete(AccessionOrder TestResult, String s, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public void purge(AccessionOrder TestResult, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public DelegatingResourceDescription getUpdatableProperties() throws ResourceDoesNotSupportOperationException {
        DelegatingResourceDescription description = new DelegatingResourceDescription();
        description.addProperty("sampleId");
        description.addProperty("referenceLab");
        description.addProperty("specimenSourceId");
        description.addProperty("patientQueueId");
        return description;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }
}
