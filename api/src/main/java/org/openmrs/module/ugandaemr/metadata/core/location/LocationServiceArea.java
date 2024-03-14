package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationClinic.ART_CLINIC;
import static org.openmrs.module.ugandaemr.metadata.core.location.LocationDepartments.OPD;
import static org.openmrs.module.ugandaemr.metadata.core.location.LocationOrganization.PARENT;

public class LocationServiceArea {
	public static LocationDescriptor TRIAGE = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "ff01eaab-561e-40c6-bf24-539206b521ce";
		}

		@Override
		public String description() {
			return "A location for categorization of patients";
		}

		@Override
		public String name() {
			return "Triage";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.LOGIN_LOCATION,
					LocationTags.VISIT_LOCATION,
					LocationTags.QUEUE_ROOM
			);

		}

	};

	public static LocationDescriptor RECEPTION = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "4501e132-07a2-4201-9dc8-2f6769b6d412";
		}

		@Override
		public String description() {
			return "A Location for registering patients";
		}

		@Override
		public String name() {
			return "Reception";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.LOGIN_LOCATION,
					LocationTags.VISIT_LOCATION,
					LocationTags.QUEUE_ROOM
			);

		}

	};

	public static LocationDescriptor COUNSELING_CENTER = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "7c231e1a-1db5-11ea-978f-2e728ce88125";
		}

		@Override
		public String description() {
			return "A location where counseling and screening is done for a patient";
		}

		@Override
		public String name() {
			return "Counseling Center";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.QUEUE_ROOM,
					LocationTags.LOGIN_LOCATION
			);

		}

	};
}
