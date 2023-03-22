package org.openmrs.module.ugandaemr.metadata.core;

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

}
