package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationOrganization.PARENT;

public class LocationSupportService {

	public static LocationDescriptor PHARMACY = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "3ec8ff90-3ec1-408e-bf8c-22e4553d6e17";
		}

		@Override
		public String description() {
			return "A place for preparing, dispensing, and reviewing drugs and providing additional clinical services";
		}

		@Override
		public String name() {
			return "Pharmacy";
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
					LocationTags.MAIN_PHARMACY,
					LocationTags.QUEUE_ROOM,
					LocationTags.SUPPORTIVE_SERVICE
			);

		}

	};

	public static LocationDescriptor LABORATORY = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "ba158c33-dc43-4306-9a4a-b4075751d36c";
		}

		@Override
		public String description() {
			return "Area for carrying out patient tests";
		}

		@Override
		public String name() {
			return "Main Laboratory";
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
					LocationTags.LABORATORY,
					LocationTags.QUEUE_ROOM,
					LocationTags.SUPPORTIVE_SERVICE
			);

		}

	};

	public static LocationDescriptor MAIN_THEATER = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "c6d1bb42-3846-11ee-be56-0242ac120002";
		}

		@Override
		public String description() {
			return "A facility within a hospital where surgical operations are carried out in an aseptic environment.";
		}

		@Override
		public String name() {
			return "Main Theater";
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
					LocationTags.THEATER,
					LocationTags.QUEUE_ROOM,
					LocationTags.SUPPORTIVE_SERVICE
			);

		}

	};

}
