package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

public class LocationTags {

	public static LocationTagDescriptor RECEPTION = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "376df607-be89-4d8f-87e7-47919904523c";
		}

		@Override
		public String name() {
			return "Reception";
		}

		@Override
		public String description() {
			return "Tha tag to identify a reception point";
		}

	};

	public static LocationTagDescriptor TRIAGE = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "3e525526-cd66-46ad-96b3-224d46e75676";
		}

		@Override
		public String name() {
			return "Triage";
		}

		@Override
		public String description() {
			return "Tha tag to identify a triage point";
		}

	};

	public static LocationTagDescriptor CLINICAL_ROOM = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "96be1b53-e65c-494b-be41-b36899cb5d09";
		}

		@Override
		public String name() {
			return "Clinical Room";
		}

		@Override
		public String description() {
			return "Tha tag to identify a Clinical Room point";
		}

	};

	public static LocationTagDescriptor LABORATORY = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "1e6acc3e-696d-47de-8f74-63ed7bbe6e81";
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

	public static LocationTagDescriptor ADMISSION = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "1c783dca-fd54-4ea8-a0fc-2875374e9cb6";
		}

		@Override
		public String name() {
			return "Admission Location";
		}

		@Override
		public String description() {
			return "Patients may only be admitted to inpatient care in a location with this tag";
		}

	};

	public static LocationTagDescriptor SUPPORTIVE_SERVICE = new LocationTagDescriptor(){

		@Override
		public String uuid() {
			return "50b2a204-4887-11ee-be56-0242ac120002";
		}

		@Override
		public String name() {
			return "Supportive Service";
		}

		@Override
		public String description() {
			return "Services that support patient care such as lab pharmacy";
		}

	};

}
