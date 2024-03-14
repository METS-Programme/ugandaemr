package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationOrganization.PARENT;

public class LocationOther {

	public static LocationDescriptor Community = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "841cb8d9-b662-41ad-9e7f-d476caac48aa";
		}

		@Override
		public String description() {
			return "This is a location that caters for  all clients served in the community ";
		}

		@Override
		public String name() {
			return "Community";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION
			);

		}

	};

	public static LocationDescriptor UNKNOWN = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "8d6c993e-c2cc-11de-8d13-0010c6dffd0f";
		}

		@Override
		public String description() {
			return "Unknown location";
		}

		@Override
		public String name() {
			return "Unknown";
		}

		@Override
		public LocationDescriptor parent() {
			return PARENT;
		}

	};
}
