<%
    ui.includeFragment("appui", "standardEmrIncludes")
    ui.includeCss("appui","bootstrap.min.css")
    ui.includeCss("appui","bootstrap.min.js")

    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("SMS Patients") ])

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
        {label: "${ ui.escapeJs(ui.message("SMS Patients")) }"}
    ]
</script>

<script type="text/javascript">
    if (jQuery) {
        var appointmentCohortUuid= "c418984c-fe55-431a-90be-134da0a5ec67";
        var exiting=false;
        jq(document).ready(function () {
            getPatientInSMSCohort();

        });


        function getPatientInSMSCohort(){
            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort/"+appointmentCohortUuid+"?v=custom:(cohortMembers)",
                dataType: "json",
                contentType: "application/json",
                accept: "application/json",
                success: function (data) {
                    var person;
                    var container = jq('#mybody');
                    var members = data.cohortMembers;
                    if(members.length>0){
                        for (var i = 0; i < members.length; i++) {
                            var member = members[i];
                            var uri = member.patient.links[0].uri;
                            jq.ajax({
                                type: "GET",
                                url: uri+"?v=custom:(person)",
                                dataType: "json",
                                contentType: "application/json",
                                accept: "application/json",
                                success: function (data) {
                                    person = data.person;
                                    var row = "<tr id=\""+member.uuid+"\">" +
                                        "<td>"+ person.display +"</td>" +
                                        "<td>"+ person.age +"</td>" +
                                        "<td>"+ person.birthdate +"</td>" +
                                        "<td>"+ person.gender +"</td>" +
                                        "<td>"+ member.startDate.trim() +"</td>" +
                                        "<td>" +
                                        "<i style=\"font-size: 25px\"  class=\"delete-item icon-remove\" title=\"Delete\" onclick=\"deletePatientFromCohort('"+member.links[0].uri+"')\"></i></td>" +
                                        "</tr>";
                                    container.append(row);
                                }
                            });
                        }
                    }

                }
            });
        }

        function deletePatientFromCohort(uri){
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
                url: uri,
                dataType: "json",
                contentType: "application/json",
                accept: "application/json",
                data:dataToPost,
                success: function (data) {
                    jq().toastmessage('showSuccessToast', "Client Removed from Group");
                },
                error: function (response) {
                    jq().toastmessage('showErrorToast',"Member does not exist in group");
                }
            });
        }



    }
</script>
<div>
    <table id="example" class="table table-striped table-bordered" style="width:100%">
        <thead>
        <tr>
            <th>Name</th>
            <th>Age</th>
            <th>Birthdate</th>
            <th>Gender</th>
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