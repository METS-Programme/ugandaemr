package org.openmrs.module.ugandaemr.web.resource;

import org.openmrs.Encounter;
import org.openmrs.Form;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;

import org.openmrs.module.ugandaemr.web.customdto.DuplicateEncounter;
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
import org.openmrs.parameter.EncounterSearchCriteria;
import org.openmrs.util.OpenmrsUtil;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Resource(name = RestConstants.VERSION_1 + "/duplicateencounter", supportedClass = DuplicateEncounter.class, supportedOpenmrsVersions = {"1.9.* - 9.*"})
public class DuplicateEncounterResource extends DelegatingCrudResource<DuplicateEncounter> {

    @Override
    public DuplicateEncounter newDelegate() {
        return new DuplicateEncounter();
    }

    @Override
    public DuplicateEncounter save(DuplicateEncounter duplicateEncounter) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public DuplicateEncounter getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    protected void delete(DuplicateEncounter DuplicateEncounter, String s, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public void purge(DuplicateEncounter DuplicateEncounter, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public NeedsPaging<DuplicateEncounter> doGetAll(RequestContext context) throws ResponseException {
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
            description.addProperty("encounter", Representation.REF);

            description.addSelfLink();

            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("encounter", Representation.FULL);
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("encounter", Representation.FULL);
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        Date encounterDate = null;
        Patient patient = null;
        Form form = null;
        List<DuplicateEncounter> DuplicateEncounterS = new ArrayList<>();

        if (context.getParameter("formId") != null) {
            form = Context.getFormService().getForm(Integer.parseInt(context.getParameter("formId")));
        }
        if (context.getParameter("patient") != null) {
            patient = Context.getPatientService().getPatient(Integer.parseInt(context.getParameter("patient")));
        }

        if (context.getParameter("dateFormat") != null) {
            encounterDate = convertStringToDate(context.getParameter("dateFormat"), "", "yyyy-MM-dd");
        }

        EncounterSearchCriteria encounterSearchCriteria = new EncounterSearchCriteria(patient, null, OpenmrsUtil.firstSecondOfDay(encounterDate), OpenmrsUtil.getLastMomentOfDay(encounterDate), null, Arrays.asList(form), null, null, null, null, false);
        List<DuplicateEncounter> duplicateEncounters = new ArrayList<>();
        List<Encounter> encounter = Context.getEncounterService().getEncounters(encounterSearchCriteria);
        if (!encounter.isEmpty()) {
            DuplicateEncounter duplicateEncounter = new DuplicateEncounter();
            duplicateEncounter.setUuid(encounter.get(0).getUuid());
            duplicateEncounter.setEncounter(encounter);
            duplicateEncounters.add(duplicateEncounter);
        }

        return new NeedsPaging<DuplicateEncounter>(duplicateEncounters, context);
    }

    public Date convertStringToDate(String dateString, String time, String dateFormat) {

        DateFormat format = new SimpleDateFormat(dateFormat, Locale.ENGLISH);
        Date date = null;
        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

        SimpleDateFormat formatterExt = new SimpleDateFormat("dd/MM/yyyy");

        try {
            date = format.parse(dateString);
            if (date != null && time != "") {
                date = formatter.parse(formatterExt.format(date) + " " + time);

            }
        } catch (ParseException e) {
            log.error("failed to convert date to string", e);
        }

        return date;
    }
}
