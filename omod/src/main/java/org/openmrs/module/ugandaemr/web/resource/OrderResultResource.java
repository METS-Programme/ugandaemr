package org.openmrs.module.ugandaemr.web.resource;

import io.swagger.models.Model;
import io.swagger.models.ModelImpl;
import io.swagger.models.properties.RefProperty;
import io.swagger.models.properties.StringProperty;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.web.customdto.OrderResult;
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
import java.util.stream.Collectors;

@Resource(name = RestConstants.VERSION_1 + "/encountertestresults", supportedClass = OrderResult.class, supportedOpenmrsVersions = {
        "1.9.*", "1.10.*", "1.11.*", "1.12.*", "2.0.*", "2.1.*", "2.2.*", "2.3.*", "2.4.*", "2.5.*"})
public class OrderResultResource extends DelegatingCrudResource<OrderResult> {

    @Override
    public OrderResult newDelegate() {
        return new OrderResult();
    }

    @Override
    public OrderResult save(OrderResult OrderResult) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public OrderResult getByUniqueId(String uniqueId) {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public NeedsPaging<OrderResult> doGetAll(RequestContext context) throws ResponseException {
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
            description.addProperty("order", Representation.REF);
            description.addProperty("result", Representation.REF);
            description.addSelfLink();
            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("order", Representation.REF);
            description.addProperty("result", Representation.REF);
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("order", Representation.REF);
            description.addProperty("result", Representation.REF);
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected void delete(OrderResult syncFfhirProfile, String s, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public void purge(OrderResult syncFfhirProfile, RequestContext requestContext) throws ResponseException {
        throw new ResourceDoesNotSupportOperationException("Operation not supported");
    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() throws ResourceDoesNotSupportOperationException {
        DelegatingResourceDescription description = new DelegatingResourceDescription();
        description.addProperty("uuid");
        description.addProperty("order");
        description.addProperty("result");
        return description;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        UgandaEMRService ugandaEMRSyncService = Context.getService(UgandaEMRService.class);

        String encounterUuid = context.getParameter("encounterUuid");
        List<OrderResult> orderResults = new ArrayList<>();
        Encounter encounter = null;

        if (!encounterUuid.isEmpty()) {
            encounter = Context.getEncounterService().getEncounterByUuid(encounterUuid);
        }

        for (Order order : encounter.getOrders()) {
            try {
                if (encounter.getAllObs().stream().map(Obs::getOrder).collect(Collectors.toList()).contains(order)) {
                    OrderResult orderResult = new OrderResult();
                    orderResult.setOrder(order.getOrderNumber());
                    orderResult.setUuid(order.getUuid());
                    orderResult.setResult(Context.getService(UgandaEMRService.class).renderTests(order).stream().collect(Collectors.toList()));
                    orderResults.add(orderResult);
                }
            } catch (Exception e) {

            }
        }


        return new NeedsPaging<OrderResult>(orderResults, context);
    }

    @Override
    public Model getGETModel(Representation rep) {
        ModelImpl model = (ModelImpl) super.getGETModel(rep);
        if (rep instanceof DefaultRepresentation || rep instanceof FullRepresentation) {
            model.property("encounterUuid", new StringProperty());
        }
        if (rep instanceof DefaultRepresentation) {
            model.property("encounterUuid", new RefProperty("#/definitions/PatientIdentifierTypeGetRef"))
            ;

        } else if (rep instanceof FullRepresentation) {
            model.property("encounterUuid", new RefProperty("#/definitions/PatientIdentifierTypeGetRef"));
        }
        return model;
    }
}
