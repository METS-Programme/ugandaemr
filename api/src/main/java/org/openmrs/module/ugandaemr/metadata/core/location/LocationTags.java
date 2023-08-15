package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

public class LocationTags {

	public static LocationTagDescriptor LOGIN_LOCATION = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "b8bbf83e-645f-451f-8efe-a0db56f09676";
		}

		@Override
		public String name() {
			return "Login Location";
		}

		@Override
		public String description() {
			return "When a user logs in and chooses a session location, they may only choose one with this tag";
		}
		
	};

	public static LocationTagDescriptor VISIT_LOCATION = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "37dd4458-dc9e-4ae6-a1f1-789c1162d37b";
		}

		@Override
		public String name() {
			return "Visit Location";
		}

		@Override
		public String description() {
			return "Visits are only allowed to happen at locations tagged with this location tag or at locations that descend from a location tagged with this tag.";
		}
		
	};

	public static LocationTagDescriptor MAIN_PHARMACY = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "89a80c4d-2899-11ed-bdcb-507b9dea1806";
		}

		@Override
		public String name() {
			return "Main Pharmacy";
		}

		@Override
		public String description() {
			return "Main pharmacy location.";
		}

	};

	public static LocationTagDescriptor DEPARTMENT = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "1d3e4706-382a-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Department";
		}

		@Override
		public String description() {
			return "Identifies a department in a Hospital/clinic etc";
		}

	};

	public static LocationTagDescriptor ORGANIZATION = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "1d3e456c-382a-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Organization";
		}

		@Override
		public String description() {
			return "Identifies an Organization";
		}

	};

	public static LocationTagDescriptor CLINIC = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "1d3e4224-382a-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Clinic";
		}

		@Override
		public String description() {
			return "Identifies a clinic in the organization/hospital";
		}

	};

	public static LocationTagDescriptor QUEUE_ROOM = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "c0e1d1d8-c97d-4869-ba16-68d351d3d5f5";
		}

		@Override
		public String name() {
			return "Queue Room";
		}

		@Override
		public String description() {
			return "A tag to indicate a queue room used by the queuing module";
		}

	};

	public static LocationTagDescriptor LABORATORY = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "c0e1d1d8-c97d-4869-ba16-68d351d3d5f5";
		}

		@Override
		public String name() {
			return "Laboratory";
		}

		@Override
		public String description() {
			return "A tag to indicate a laboratory";
		}

	};

	public static LocationTagDescriptor THEATER = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "303ab6e0-3844-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Theater";
		}

		@Override
		public String description() {
			return "A tag to indicate a theater";
		}

	};

	public static LocationTagDescriptor RADIOLOGY = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "7984dc1e-3848-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Radiology";
		}

		@Override
		public String description() {
			return "A tag to indicate a radiology service room";
		}

	};

}
