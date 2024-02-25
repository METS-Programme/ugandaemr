package org.openmrs.module.ugandaemr.api.lab.mapper;

import java.io.Serializable;

public class TestOrderMapper implements Serializable {

	private String orderId;
	private String accessionNumber;
	private String specimenSourceId;
	private String instructions;

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}

	public String getAccessionNumber() {
		return accessionNumber;
	}

	public void setAccessionNumber(String accessionNumber) {
		this.accessionNumber = accessionNumber;
	}

	public String getSpecimenSourceId() {
		return specimenSourceId;
	}

	public void setSpecimenSourceId(String specimenSourceId) {
		this.specimenSourceId = specimenSourceId;
	}

	public String getInstructions() {
		return instructions;
	}

	public void setInstructions(String instructions) {
		this.instructions = instructions;
	}
}
