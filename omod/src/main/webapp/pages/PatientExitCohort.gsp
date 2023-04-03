<%
    ui.includeFragment("appui", "standardEmrIncludes")
    ui.includeCss("appui","bootstrap.min.css")
    ui.includeJavascript("appui", "popper.min.js")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")


    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("Patients in Cohorts") ])

    def htmlSafeId = { extension ->
        "${ extension.id.replace(".", "-") }-${ extension.id.replace(".", "-") }-extension"
    }
%>

<!DOCTYPE html>
<html>
<head>

</head>

<body>
<script type="text/javascript">
    var OPENMRS_CONTEXT_PATH = '${ ui.contextPath() }';
    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {label: "${ ui.escapeJs(ui.message("Exist patients from cohort  group")) }"}
    ]

</script>

<script type="text/javascript">
    if (jQuery) {
        var cohortType;
        jq(document).ready(function () {

            jq("#loading").hide();
            getCohortTypes();
            jq('#cohort-type').change(function (){
                jq('#loading').show();
                cohortType = jq('#cohort-type option:selected').val();
                getCohort(cohortType);

                jq('#loading').hide();
            });

        });


        function getPatientData(uri){
            var person;
            jq.ajax({
                type: "GET",
                url: uri+"?v=custom:(person)",
                dataType: "json",
                async: false,
                contentType: "application/json",
                accept: "application/json",
                success: function (data) {
                    person = data.person;
                }
            });
            return person;
        }

        function getCohortTypes(){
            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohorttype?v=default",
                dataType: "json",
                contentType: "application/json",
                async: false,
                success: function (data) {
                    var types = data.results;

                    for (var i = 0; i<types.length; i++) {
                        jq('#cohort-type').append("<option value='"+ types[i].uuid+"'>"+ types[i].name+ "</option>");
                    }

                }
            });
        }

        function getCohort(type){
            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort?v=custom:(name,cohortMembers,voided)&cohortType="+type,
                dataType: "json",
                contentType: "application/json",
                async: false,
                success: function (data) {
                    var cohorts = data.results;
                    jq('#mybody').empty();
                    displayCohortDetails(cohorts);
                    var table = jq('#example').DataTable();
                }
            });
        }

        function displayCohortDetails(data){
            var container = jq('#mybody');
            for (var i = 0; i <data.length; i++) {
                if(data[i].voided==false){
                    var cohort = data[i];
                    var cohortName = cohort.name;
                    var members = cohort.cohortMembers;
                    if(members.length>0){
                        for (var i = 0; i < members.length; i++) {
                            var member = members[i];
                            if(member.voided==false){
                                var uri = member.patient.links[0].uri;
                                person =getPatientData(uri)
                                var dob = new Date(person.birthdate).toLocaleDateString();
                                var startDate = new Date(member.startDate).toLocaleDateString();
                                var row = "<tr id=\""+member.uuid+"\">" +
                                    "<td>"+ person.display +"</td>" +
                                    "<td>"+ person.age +"</td>" +
                                    "<td>"+ dob +"</td>" +
                                    "<td>"+ person.gender +"</td>" +
                                    "<td>"+ cohortName +"</td>" +
                                    "<td>"+ startDate +"</td>" +
                                    "<td>" +
                                    "<i style=\"font-size: 25px\"  class=\"delete-item icon-remove\" title=\"Delete\" onclick=\"ConfirmDelete('"+member.uuid+"')\"></i></td>" +
                                    "</tr>";
                                container.append(row);
                            }
                        }
                    }

                }

            }
        }

        function deletePatientFromCohort(uuid){
            const today = new Date();
            const yyyy = today.getFullYear();
            let mm = today.getMonth() + 1; // Months start at 0!
            let dd = today.getDate();

            if (dd < 10) dd = '0' + dd;
            if (mm < 10) mm = '0' + mm;

            const formattedToday = yyyy+ '-' +mm + '-'+dd;
            var dataToPost = "{\"voided\": \"" +  true + "\", \"endDate\": \"" + formattedToday + "\"}";

            jq.ajax({
                type: "POST",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohortmember/"+uuid,
                dataType: "json",
                async:false,
                contentType: "application/json",
                accept: "application/json",
                data:dataToPost,
                success: function (data) {
                    jq().toastmessage('showSuccessToast', "Client Removed from Group");
                    getCohort(cohortType)
                },
                error: function (response) {
                    jq().toastmessage('showErrorToast',"Member does not exist in group");
                }
            });


        }

        function ConfirmDelete(uuid) {
            if(confirm("Are you sure to want to Delete?")==true)
                deletePatientFromCohort(uuid);
            else
                return false;
        }
    }
</script>
<div class="row">
    <div>
        <div class="col-6">
            <div class="form-group">
                <label>Group Type</label>
                <select class="form-control" name="cohortType" id="cohort-type">
                    <option value="">Select ---</option>
                </select>
            </div>
        </div>
        <div id="loading" class="col-6">
            <img src="/openmrs/ms/uiframework/resource/uicommons/images/spinner.gif">
        </div>
    </div>
</div>

<div>
    <table id="example" class="table table-striped table-bordered" style="width:100%">
        <thead>
        <tr>
            <th>Name</th>
            <th>Age</th>
            <th>Birthdate</th>
            <th>Gender</th>
            <th>Group</th>
            <th>Date Enrolled on Program</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody id="mybody">

        </tbody>
    </table>
</div>



</body>
</html>