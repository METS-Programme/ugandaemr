package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationDepartments.OPD;
import static org.openmrs.module.ugandaemr.metadata.core.location.LocationOrganization.PARENT;

public class LocationClinic {

	public static LocationDescriptor OPD_CLINIC = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "11d5d2b8-0fdd-42e0-9f53-257c760bb9a3";
		}

		@Override
		public String description() {
			return "Clinic where Out-Patient Services are provided";
		}

		@Override
		public String name() {
			return "OPD Clinic";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.CLINIC
			);

		}

	};
	public static LocationDescriptor TB_CLINIC = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "8ab22b55-9a17-4121-bf08-6134a9a2439f";
		}

		@Override
		public String description() {
			return "Clinic where TB Care and Treatment Services are provided";
		}

		@Override
		public String name() {
			return "TB Clinic";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.CLINIC,
					LocationTags.LOGIN_LOCATION
			);

		}

	};
	public static LocationDescriptor ART_CLINIC = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "86863db4-6101-4ecf-9a86-5e716d6504e4";
		}

		@Override
		public String description() {
			return "Clinic where ART Care and Treatment Services are provided";
		}

		@Override
		public String name() {
			return "ART Clinic";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.CLINIC,
					LocationTags.LOGIN_LOCATION
			);

		}

	};
	public static LocationDescriptor MCH_CLINIC = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "e9bc61b5-69ff-414b-9cf0-0c22d6dfca2b";
		}

		@Override
		public String description() {
			return "Clinic where MCH Services are provided";
		}

		@Override
		public String name() {
			return "MCH Clinic";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.CLINIC,
					LocationTags.LOGIN_LOCATION
			);

		}

	};
	public static LocationDescriptor COVID19_CLINIC = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "1748bd6f-b013-449f-8d38-91319b576f3f";
		}

		@Override
		public String description() {
			return "This is the location where Covid-19 cases are registered";
		}

		@Override
		public String name() {
			return "Covid 19 Clinic";
		}

		@Override
		public LocationDescriptor parent() {
			return OPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION
			);

		}

	};
}
