package org.openmrs.module.ugandaemr.api.lab.util;

import java.util.List;

public class ResultModelWrapper {

	private String testId;

	private List<ResultModel> results;

	public String getTestId() {
		return testId;
	}

	public void setTestId(String testId) {
		this.testId = testId;
	}

	public List<ResultModel> getResults() {
		return results;
	}

	public void setResults(List<ResultModel> results) {
		this.results = results;
	}
}
