package org.openmrs.module.ugandaemr.metadata.core.location;

import org.openmrs.module.metadatadeploy.descriptor.LocationDescriptor;
import org.openmrs.module.metadatadeploy.descriptor.LocationTagDescriptor;

import java.util.Arrays;
import java.util.List;

import static org.openmrs.module.ugandaemr.metadata.core.location.LocationDepartments.IPD;

public class LocationWard {
	public static LocationDescriptor CAUSALITY_WARD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "062c1e31-7ebb-497a-bd68-ecea4387f808";
		}

		@Override
		public String description() {
			return "Causality  Ward";
		}

		@Override
		public String name() {
			return "Causality  Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.ADMISSION
			);

		}




	};

	public static LocationDescriptor GENERAL_WARD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "fca41e3e-99d3-4ee7-a973-463b3a756051 ";
		}

		@Override
		public String description() {
			return "General Ward";
		}

		@Override
		public String name() {
			return "General Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.DEPARTMENT
			);

		}
	};


	public static LocationDescriptor ISOLATION_WARD = new LocationDescriptor() {

		@Override
		public String uuid() {
			return "75c7546a-5ae1-4355-92fa-3e5df6724e3a ";
		}

		@Override
		public String description() {
			return "Isolation Ward";
		}

		@Override
		public String name() {
			return "Isolation Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.ADMISSION
			);

		}
	};

	public static LocationDescriptor GENERAL_MEN_WARD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "bce72935-e83a-4026-b837-e7a2383c0b3e";
		}

		@Override
		public String description() {
			return "General Men Ward";
		}

		@Override
		public String name() {
			return "General Men Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return GENERAL_WARD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.ADMISSION
			);

		}
	};

	public static LocationDescriptor GENERAL_WOMEN_WARD = new LocationDescriptor(){

		@Override
		public String uuid() {
			return "defa9b3c-7f98-4469-b898-82682cb2d646";
		}

		@Override
		public String description() {
			return "General Women Ward";
		}

		@Override
		public String name() {
			return "General Women Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return GENERAL_WARD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.ADMISSION
			);

		}
	};

	public static LocationDescriptor PEAD_WARD = new LocationDescriptor() {

		@Override
		public String uuid() {
			return "a48d4cee-029c-4f59-85ea-c14b7031cbdf";
		}

		@Override
		public String description() {
			return "Pead Ward";
		}

		@Override
		public String name() {
			return "Pead Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.ADMISSION
			);

		}
	};

	public static LocationDescriptor PRIVATE_WAR = new LocationDescriptor() {

		@Override
		public String uuid() {
			return "10682c1a-5651-43ad-909c-ada1dfb7dce8";
		}

		@Override
		public String description() {
			return "Private Ward";
		}

		@Override
		public String name() {
			return "Private Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.DEPARTMENT
			);

		}
	};

	public static LocationDescriptor TB_ARD = new LocationDescriptor() {

		@Override
		public String uuid() {
			return "b3a5108f-7b20-4261-b0ee-d7077fa2868c";
		}

		@Override
		public String description() {
			return "TB Ward";
		}

		@Override
		public String name() {
			return "TB Ward";
		}

		@Override
		public LocationDescriptor parent() {
			return IPD;
		}

		@Override
		public List<LocationTagDescriptor> tags() {

			return Arrays.asList(
					LocationTags.VISIT_LOCATION,
					LocationTags.DEPARTMENT
			);

		}
	};

}
