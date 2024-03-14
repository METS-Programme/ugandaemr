package org.openmrs.module.ugandaemr.web.resource;

import io.swagger.models.Model;
import io.swagger.models.ModelImpl;
import io.swagger.models.properties.*;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
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
import java.util.ArrayList;
import java.util.Arrays;

import java.util.List;

@Resource(name = RestConstants.VERSION_1 + "/incompletequeue", supportedClass = PatientQueue.class, supportedOpenmrsVersions = {
        "1.9.*", "1.10.*", "1.11.*", "1.12.*", "2.0.*", "2.1.*", "2.2.*", "2.3.*", "2.4.*", "2.5.*"})
public class IncompletePatientQueueResource extends DelegatingCrudResource<PatientQueue> {

    @Override
    public PatientQueue newDelegate() {
        return new PatientQueue();
    }

    @Override
    public PatientQueue save(PatientQueue PatientQueue) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public PatientQueue getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public NeedsPaging<PatientQueue> doGetAll(RequestContext context) throws ResponseException {
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
            description.addProperty("uuid");
            description.addProperty("patient", Representation.REF);
            description.addProperty("datePicked");
            description.addProperty("dateCompleted");
            description.addProperty("locationFrom", Representation.REF);
            description.addProperty("locationTo", Representation.REF);
            description.addProperty("provider", Representation.REF);
            description.addProperty("encounter", Representation.REF);
            description.addProperty("status");
            description.addProperty("priority");
            description.addProperty("priorityComment");
            description.addProperty("visitNumber");
            description.addProperty("comment");
            description.addProperty("queueRoom", Representation.REF);

            description.addSelfLink();

            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("creator");
            description.addProperty("dateCreated");
            description.addProperty("changedBy");
            description.addProperty("dateChanged");
            description.addProperty("voided");
            description.addProperty("dateVoided");
            description.addProperty("voidedBy");
            description.addProperty("patient");
            description.addProperty("provider");
            description.addProperty("locationFrom");
            description.addProperty("locationTo");
            description.addProperty("encounter");
            description.addProperty("status");
            description.addProperty("priority");
            description.addProperty("priorityComment");
            description.addProperty("visitNumber");
            description.addProperty("comment");
            description.addProperty("queueRoom");
            description.addProperty("datePicked");
            description.addProperty("dateCompleted");
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("visitNumber");
            description.addProperty("dateCreated");
            description.addProperty("dateChanged");
            description.addProperty("locationFrom");
            description.addProperty("locationTo");
            description.addProperty("status");
            description.addProperty("queueRoom");
            description.addProperty("datePicked");
            description.addProperty("dateCompleted");
            description.addProperty("provider");
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected void delete(PatientQueue syncFhirCase, String s, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public void purge(PatientQueue syncFhirCase, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }


    @Override
    protected PageableResult doSearch(RequestContext context) {
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        Patient patient = null;
        Location location = null;
        Location queueRoom = Context.getLocationService().getLocationByUuid((context.getParameter("queueRoom")));
        if (context.getParameter("patient") != null) {
           patient=Context.getPatientService().getPatientByUuid(context.getParameter("patient"));
        }

        if (context.getParameter("location") != null) {
            Context.getLocationService().getLocationByUuid(context.getParameter("location"));
        }

        List<PatientQueue> patientQueues= new ArrayList<>();

        patientQueues.add(patientQueueingService.getIncompletePatientQueue(patient,location,queueRoom));


        return new NeedsPaging<PatientQueue>(patientQueues, context);
    }

    @Override
    public Model getGETModel(Representation rep) {
        ModelImpl model = (ModelImpl) super.getGETModel(rep);
        if (rep instanceof DefaultRepresentation || rep instanceof FullRepresentation) {
            model.property("uuid", new StringProperty()).property("dateCreated", new DateProperty())
                    .property("voided", new BooleanProperty()).property("priority", new IntegerProperty())
                    .property("priorityComment", new StringProperty()).property("visitNumber", new StringProperty())
                    .property("comment", new StringProperty()).property("status", new StringProperty())
                    .property("datePicked", new DateProperty()).property("dateCompleted", new DateProperty());
        }
        if (rep instanceof DefaultRepresentation) {
            model.property("patient", new RefProperty("#/definitions/PatientGetRef"))
                    .property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("provider", new RefProperty("#/definitions/ProviderGetRef"))
                    .property("locationFrom", new RefProperty("#/definitions/LocationGetRef"))
                    .property("locationTo", new RefProperty("#/definitions/LocationGetRef"))
                    .property("encounter", new RefProperty("#/definitions/EncounterGetRef"));

        } else if (rep instanceof FullRepresentation) {
            model.property("patient", new RefProperty("#/definitions/PatientGetRef"))
                    .property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("provider", new RefProperty("#/definitions/ProviderGetRef"))
                    .property("locationFrom", new RefProperty("#/definitions/LocationGetRef"))
                    .property("locationTo", new RefProperty("#/definitions/LocationGetRef"))
                    .property("encounter", new RefProperty("#/definitions/EncounterGetRef"));
        }
        return model;
    }
}
