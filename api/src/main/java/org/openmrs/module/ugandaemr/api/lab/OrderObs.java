package org.openmrs.module.ugandaemr.api.lab;

import org.openmrs.Encounter;
import org.openmrs.Order;
import org.openmrs.Obs;
import org.openmrs.BaseOpenmrsData;

import javax.persistence.GeneratedValue;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.GenerationType;
import javax.persistence.ManyToOne;
import javax.persistence.JoinColumn;
import java.io.Serializable;

@Entity(name = "ugandaemr.OrderObs")
@Table(name = "order_obs")
public class OrderObs extends BaseOpenmrsData implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_obs_id")
    private Integer orderObsId;

    @ManyToOne
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne
    @JoinColumn(name = "obs_id")
    private Obs obs;

    @ManyToOne
    @JoinColumn(name = "encounter_id")
    private Encounter encounter;

    public OrderObs() {
    }

    public OrderObs(Order order, Obs obs, Encounter encounter) {
        this.order = order;
        this.obs = obs;
        this.encounter = encounter;
    }

    public Integer getOrderObsId() {
        return orderObsId;
    }

    public void setOrderObsId(Integer orderObsId) {
        this.orderObsId = orderObsId;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

    public Obs getObs() {
        return obs;
    }

    public void setObs(Obs obs) {
        this.obs = obs;
    }

    public Encounter getEncounter() {
        return encounter;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }

    @Override
    public Integer getId() {
        return orderObsId;
    }

    @Override
    public void setId(Integer id) {
        this.orderObsId = id;
    }
}
