package org.openmrs.module.ugandaemr.web.resource;

import io.swagger.models.Model;
import io.swagger.models.ModelImpl;
import io.swagger.models.properties.DateProperty;
import io.swagger.models.properties.RefProperty;
import io.swagger.models.properties.StringProperty;
import org.openmrs.Encounter;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandaemr.api.UgandaEMRService;
import org.openmrs.module.ugandaemr.api.lab.OrderObs;
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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + "/orderobs", supportedClass = OrderObs.class, supportedOpenmrsVersions = {
        "1.9.*", "1.10.*", "1.11.*", "1.12.*", "2.0.*", "2.1.*", "2.2.*", "2.3.*", "2.4.*", "2.5.*"})
public class OrderObsResource extends DelegatingCrudResource<OrderObs> {

    @Override
    public OrderObs newDelegate() {
        return new OrderObs();
    }

    @Override
    public OrderObs save(OrderObs OrderObs) {
        return Context.getService(UgandaEMRService.class).saveOrderObs(OrderObs);
    }

    @Override
    public OrderObs getByUniqueId(String uniqueId) {
        OrderObs orderObs;
        Integer id = null;

        orderObs = Context.getService(UgandaEMRService.class).getOrderObsByUuid(uniqueId);
        if (orderObs == null && uniqueId != null) {
            try {
                id = Integer.parseInt(uniqueId);
            } catch (Exception e) {
            }

            if (id != null) {
                orderObs = Context.getService(UgandaEMRService.class).getOrderObsById(id);
            }
        }

        return orderObs;
    }

    @Override
    public NeedsPaging<OrderObs> doGetAll(RequestContext context) throws ResponseException {
        return new NeedsPaging<OrderObs>(new ArrayList<OrderObs>(Context.getService(UgandaEMRService.class)
                .getAllOrderObs()), context);
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
            description.addProperty("obs", Representation.REF);
            description.addProperty("encounter", Representation.REF);
            description.addSelfLink();
            return description;
        } else if (rep instanceof FullRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("order", Representation.FULL);
            description.addProperty("obs", Representation.FULL);
            description.addProperty("encounter", Representation.FULL);
            description.addProperty("creator", Representation.FULL);
            description.addProperty("dateCreated");
            description.addProperty("changedBy", Representation.FULL);
            description.addProperty("dateChanged");
            description.addProperty("voidedBy", Representation.FULL);
            description.addProperty("dateVoided");
            description.addProperty("voidReason");
            description.addSelfLink();
            description.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
            return description;
        } else if (rep instanceof RefRepresentation) {
            DelegatingResourceDescription description = new DelegatingResourceDescription();
            description.addProperty("uuid");
            description.addProperty("order", Representation.DEFAULT);
            description.addProperty("obs", Representation.DEFAULT);
            description.addProperty("encounter", Representation.DEFAULT);
            description.addSelfLink();
            return description;
        }
        return null;
    }

    @Override
    protected void delete(OrderObs syncFhirCase, String s, RequestContext requestContext) throws ResponseException {

    }

    @Override
    public void purge(OrderObs syncFhirCase, RequestContext requestContext) throws ResponseException {

    }

    @Override
    public DelegatingResourceDescription getCreatableProperties() throws ResourceDoesNotSupportOperationException {
        DelegatingResourceDescription description = new DelegatingResourceDescription();
        description.addProperty("order", Representation.REF);
        description.addProperty("obs", Representation.REF);
        description.addProperty("encounter", Representation.REF);
        return description;
    }

    @Override
    protected PageableResult doSearch(RequestContext context) {
        UgandaEMRService ugandaEMRService = Context.getService(UgandaEMRService.class);
        String encounter = context.getParameter("encounter");
        Date before = null;
        Date after = null;
        if (context.getParameter("before") != null) {
            before = getDateFromString(context.getParameter("before"), "yyyy-MM-dd");
        }

        if (context.getParameter("before") != null) {
            after = getDateFromString(context.getParameter("after"), "yyyy-MM-dd");
        }

        String order = context.getParameter("order");
        Encounter encounters = Context.getEncounterService().getEncounterByUuid(encounter);

        List<Order> orders = new ArrayList<>();
        if (!order.isEmpty()) {
            String[] stringOrders = order.split(",");
            for (String orderString : stringOrders) {
                orders.add(Context.getOrderService().getOrderByUuid(orderString));
            }
        } else {
            orders = null;
        }

        List<OrderObs> orderObs = ugandaEMRService.getOrderObs(encounters, before, after, orders, null, false);

        return new NeedsPaging<OrderObs>(orderObs, context);
    }

    @Override
    public Model getGETModel(Representation rep) {
        ModelImpl model = (ModelImpl) super.getGETModel(rep);
        if (rep instanceof DefaultRepresentation || rep instanceof FullRepresentation) {
            model.property("uuid", new StringProperty())
                    .property("order", new RefProperty("#/definitions/OrderGetRef"))
                    .property("obs", new RefProperty("#/definitions/ObsGetRef"))
                    .property("encounter", new RefProperty("#/definitions/ObsGetRef"));
        }
        if (rep instanceof DefaultRepresentation) {
            model.property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"));

        } else if (rep instanceof FullRepresentation) {
            model.property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"));
        }
        return model;
    }

    @Override
    public Model getCREATEModel(Representation rep) {
        ModelImpl model = (ModelImpl) super.getGETModel(rep);
        if (rep instanceof DefaultRepresentation || rep instanceof FullRepresentation) {
            model.property("uuid", new StringProperty())
                    .property("order", new RefProperty("#/definitions/OrderGetRef"))
                    .property("obs", new RefProperty("#/definitions/ObsGetRef"))
                    .property("encounter", new RefProperty("#/definitions/ObsGetRef"));
        }
        if (rep instanceof DefaultRepresentation) {
            model.property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"));

        } else if (rep instanceof FullRepresentation) {
            model.property("creator", new RefProperty("#/definitions/UserGetRef"))
                    .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                    .property("voidedBy", new RefProperty("#/definitions/UserGetRef"));
        }
        return model;
    }

    @Override
    public Model getUPDATEModel(Representation rep) {
        return new ModelImpl().property("uuid", new StringProperty())
                .property("order", new RefProperty("#/definitions/OrderGetRef"))
                .property("obs", new RefProperty("#/definitions/ObsGetRef"))
                .property("encounter", new RefProperty("#/definitions/ObsGetRef"))
                .property("creator", new RefProperty("#/definitions/UserGetRef"))
                .property("changedBy", new RefProperty("#/definitions/UserGetRef"))
                .property("voidedBy", new RefProperty("#/definitions/UserGetRef"));
    }

    private Date getDateFromString(String dateString, String format) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        try {
            // Parse the string and convert it to a Date object
            return dateFormat.parse(dateString);
        } catch (Exception e) {
            log.error(e);
        }
        return new Date();
    }
}
