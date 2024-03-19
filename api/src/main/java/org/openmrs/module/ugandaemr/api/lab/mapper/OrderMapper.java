package org.openmrs.module.ugandaemr.api.lab.mapper;

import java.io.Serializable;

public class OrderMapper implements Serializable {

	private Integer encounterId;

	public OrderMapper() {
	}

	private Integer orderId;

	private String OrderUuid;

	private String patient;

	private Integer patientAge;

	private Integer patientId;

	private String orderType;

	private String orderClass;

	private String concept;

	private String conceptName;

	private String instructions;

	private String dateActivated;

	private String autoExpireDate;

	private String encounter;

	private String orderer;

	private String dateStopped;

	private String orderReason;

	private String accessionNumber;

	private String orderReasonNonCoded;

	private String urgency;

	private String orderNumber;

	private String commentToFulfiller;

	private String fulfillerStatus;

	private String fulfillerComment;

	private String careSetting;

	private String scheduledDate;

	private String status;

	public Integer getEncounterId() {
		return encounterId;
	}

	public void setEncounterId(Integer encounterId) {
		this.encounterId = encounterId;
	}

	public Integer getOrderId() {
		return orderId;
	}

	public void setOrderId(Integer orderId) {
		this.orderId = orderId;
	}

	public String getPatient() {
		return patient;
	}

	public void setPatient(String patient) {
		this.patient = patient;
	}


	public String getOrderClass() {
		return orderClass;
	}

	public void setOrderClass(String orderClass) {
		this.orderClass = orderClass;
	}

	public String getOrderType() {
		return orderType;
	}

	public void setOrderType(String orderType) {
		this.orderType = orderType;
	}

	public String getConcept() {
		return concept;
	}

	public void setConcept(String concept) {
		this.concept = concept;
	}

	public String getInstructions() {
		return instructions;
	}

	public void setInstructions(String instructions) {
		this.instructions = instructions;
	}

	public String getDateActivated() {
		return dateActivated;
	}

	public void setDateActivated(String dateActivated) {
		this.dateActivated = dateActivated;
	}

	public String getAutoExpireDate() {
		return autoExpireDate;
	}

	public void setAutoExpireDate(String autoExpireDate) {
		this.autoExpireDate = autoExpireDate;
	}

	public String getEncounter() {
		return encounter;
	}

	public void setEncounter(String encounter) {
		this.encounter = encounter;
	}

	public String getOrderer() {
		return orderer;
	}

	public void setOrderer(String orderer) {
		this.orderer = orderer;
	}

	public String getDateStopped() {
		return dateStopped;
	}

	public void setDateStopped(String dateStopped) {
		this.dateStopped = dateStopped;
	}

	public String getOrderReason() {
		return orderReason;
	}

	public void setOrderReason(String orderReason) {
		this.orderReason = orderReason;
	}

	public String getAccessionNumber() {
		return accessionNumber;
	}

	public void setAccessionNumber(String accessionNumber) {
		this.accessionNumber = accessionNumber;
	}

	public String getOrderReasonNonCoded() {
		return orderReasonNonCoded;
	}

	public void setOrderReasonNonCoded(String orderReasonNonCoded) {
		this.orderReasonNonCoded = orderReasonNonCoded;
	}

	public String getUrgency() {
		return urgency;
	}

	public void setUrgency(String urgency) {
		this.urgency = urgency;
	}

	public String getOrderNumber() {
		return orderNumber;
	}

	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}

	public String getCommentToFulfiller() {
		return commentToFulfiller;
	}

	public void setCommentToFulfiller(String commentToFulfiller) {
		this.commentToFulfiller = commentToFulfiller;
	}

	public String getCareSetting() {
		return careSetting;
	}

	public void setCareSetting(String careSetting) {
		this.careSetting = careSetting;
	}

	public String getScheduledDate() {
		return scheduledDate;
	}

	public void setScheduledDate(String scheduledDate) {
		this.scheduledDate = scheduledDate;
	}

	public String getConceptName() {
		return conceptName;
	}

	public void setConceptName(String conceptName) {
		this.conceptName = conceptName;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getPatientId() {
		return patientId;
	}

	public void setPatientId(int patientId) {
		this.patientId = patientId;
	}

	public Integer getPatientAge() {
		return patientAge;
	}

	public void setPatientAge(Integer patientAge) {
		this.patientAge = patientAge;
	}

	public String getFulfillerStatus() {
		return fulfillerStatus;
	}

	public void setFulfillerStatus(String fulfillerStatus) {
		this.fulfillerStatus = fulfillerStatus;
	}

	public String getFulfillerComment() {
		return fulfillerComment;
	}

	public void setFulfillerComment(String fulfillerComment) {
		this.fulfillerComment = fulfillerComment;
	}


	public String getOrderUuid() {
		return OrderUuid;
	}

	public void setOrderUuid(String orderUuid) {
		OrderUuid = orderUuid;
	}
}
