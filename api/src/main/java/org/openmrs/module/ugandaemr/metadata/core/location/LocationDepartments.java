package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationOrganization.PARENT;

public class LocationDepartments {

	public static LocationDescriptor OPD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "c8b19970-087a-4ed9-9054-c40ba8015358";
		}

		@Override
		public String description() {
			return "Clinic where Out-Patient Services are provided";
		}

		@Override
		public String name() {
			return "Out Patient Department";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.DEPARTMENT
			);

		}

	};

	public static LocationDescriptor IPD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "79b169dd-4b35-4312-a2f0-d72ece1ac4ba";
		}

		@Override
		public String description() {
			return "The Overall Internal Medicine department";
		}

		@Override
		public String name() {
			return "In Patient Department";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.DEPARTMENT
			);

		}

	};

	public static LocationDescriptor RADIOLOGY = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "f586757c-3846-11ee-be56-0242ac120002";
		}

		@Override
		public String description() {
			return "The Overall department for Imaging Center and Radiology Services";
		}

		@Override
		public String name() {
			return "Radiology Department";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.DEPARTMENT,
					LocationTags.LOGIN_LOCATION
			);

		}

	};
}
