package org.openmrs.module.ugandaemr.api.lab.mapper;

import org.openmrs.module.patientqueueing.mapper.PatientQueueMapper;
import org.openmrs.module.ugandaemr.api.queuemapper.Identifier;

import java.io.Serializable;
import java.util.List;
import java.util.Set;

public class LabQueueMapper extends PatientQueueMapper implements Serializable {

	Set<OrderMapper> orderMapper;

	List<Identifier> patientIdentifier;

	public LabQueueMapper() {
	}

	public Set<OrderMapper> getOrderMapper() {
		return orderMapper;
	}

	public void setOrderMapper(Set<OrderMapper> orderMapper) {
		this.orderMapper = orderMapper;
	}

	public List<Identifier> getPatientIdentifier() {
		return patientIdentifier;
	}

	public void setPatientIdentifier(List<Identifier> patientIdentifier) {
		this.patientIdentifier = patientIdentifier;
	}
}
