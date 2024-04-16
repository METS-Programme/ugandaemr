package org.openmrs.module.ugandaemr.web.resource;

import io.swagger.models.Model;
import io.swagger.models.ModelImpl;
import io.swagger.models.properties.*;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemr.web.customdto.IncompleteQueueDTO;
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
import org.openmrs.util.OpenmrsUtil;

import java.util.ArrayList;
import java.util.Arrays;

import java.util.Date;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + "/incompletequeue", supportedClass = IncompleteQueueDTO.class, supportedOpenmrsVersions = {"1.9.* - 9.*"})
public class IncompletePatientQueueResource extends DelegatingCrudResource<IncompleteQueueDTO> {

    @Override
    public IncompleteQueueDTO newDelegate() {
        return new IncompleteQueueDTO();
    }

    @Override
    public IncompleteQueueDTO save(IncompleteQueueDTO PatientQueue) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public IncompleteQueueDTO getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    protected void delete(IncompleteQueueDTO incompleteQueueDTO, String s, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public void purge(IncompleteQueueDTO incompleteQueueDTO, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public NeedsPaging<IncompleteQueueDTO> doGetAll(RequestContext context) throws ResponseException {
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
            description.addProperty("patientQueues", Representation.REF);

            description.addSelfLink();

            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("patientQueues", Representation.FULL);
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("patientQueues", Representation.FULL);
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        PatientQueueingService patientQueueingService = Context.getService(PatientQueueingService.class);
        Patient patient = null;
        Location location = null;
        Location queueRoom = null;
        List<IncompleteQueueDTO> incompleteQueueDTOS = new ArrayList<>();
        if (context.getParameter("queueRoom") != null) {
            queueRoom=Context.getLocationService().getLocationByUuid((context.getParameter("queueRoom")));
        }
        if (context.getParameter("patient") != null) {
            patient = Context.getPatientService().getPatientByUuid(context.getParameter("patient"));
        }

        if (context.getParameter("location") != null) {
            location=Context.getLocationService().getLocationByUuid(context.getParameter("location"));
        }
        if (patient != null) {
            Date today = new Date();
            IncompleteQueueDTO incompleteQueueDTO = new IncompleteQueueDTO();
            List<Patient> patients = new ArrayList<>();
            patients.add(patient);
            List<PatientQueue> possibleIncompleteQueues = new ArrayList<>();

            if (location != null || queueRoom != null) {
                possibleIncompleteQueues.addAll(patientQueueingService.getPatientQueueListBySearchParams(context.getParameter("patient"), OpenmrsUtil.firstSecondOfDay(today), OpenmrsUtil.getLastMomentOfDay(today), location, null, PatientQueue.Status.PENDING, queueRoom));
                possibleIncompleteQueues.addAll(patientQueueingService.getPatientQueueListBySearchParams(context.getParameter("patient"), OpenmrsUtil.firstSecondOfDay(today), OpenmrsUtil.getLastMomentOfDay(today), location, null, PatientQueue.Status.PICKED, queueRoom));
            }

            if (!possibleIncompleteQueues.isEmpty()) {
                incompleteQueueDTO.setUuid(possibleIncompleteQueues.get(0).getUuid());
                incompleteQueueDTO.setPatientQueues(possibleIncompleteQueues);
                incompleteQueueDTOS.add(incompleteQueueDTO);
            }
        }
        return new NeedsPaging<IncompleteQueueDTO>(incompleteQueueDTOS, context);
    }
}
