<%
    ui.includeFragment("appui", "standardEmrIncludes")
    ui.includeCss("appui","bootstrap.min.css")
    ui.includeCss("appui","bootstrap.min.js")

    ui.decorateWith("appui", "standardEmrPage", [ title: ui.message("Cohort Group Registration") ])

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
        {label: "${ ui.escapeJs(ui.message("Cohort Registration")) }"}
    ]
</script>

<script type="text/javascript">
    if (jQuery) {

        jq(document).ready(function () {
            getCohorts();


            jq.ajax({
                    type: "GET",
                    url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohorttype?v=default",
                    dataType: "json",
                    contentType: "application/json",
                    async: false,
                    success: function (data) {
                        var types = data.results;
                        console.log(types);
                        for (var i = 0; i<types.length; i++) {
                            jq('#cohort-type').append("<option value='"+ types[i].uuid+"'>"+ types[i].name+ "</option>");
                        }

                    }
            });

        });
        function saveCohort(dataToPost){
            jq.ajax({
                type: "POST",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort",
                dataType: "json",
                contentType: "application/json",
                accept: "application/json",
                data: dataToPost,
                async: false,
                success: function (data) {
                    jq('#name:text').val("");
                    jq('#description:text').val("");
                    jq('#uuid:text').val("");
                    jq().toastmessage('showSuccessToast', "CDDP Group Saved Successfully");
                },
                error: function (response) {
                    jq().toastmessage('showErrorToast', "Error while Saving CDDP Group");
                }
            });
        }

        function hasWhiteSpace(s) {
            return s.indexOf(' ') >= 0;
        }

        function getCohorts(){
            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort?v=custom:(name,uuid,description)&amp;cohortType=e50fa0af-df36-4a26-853f-feb05244e5ca",
                dataType: "json",
                contentType: "application/json",
                async: false,
                success: function (data) {
                    var cohorts = data.results;
                    displaySavedCohorts(cohorts);
                }
            });
        }

        function displaySavedCohorts(data){
            var container = jq('#savedCohortsSections');
            // container.empty();
            var table = "<table>" +
                "<thead>" +
                "<th>Name</th>" +
                "<th>Description</th>" +
                "<th>Identifier</th>" +
                "<th></th></thead>" +
                "<tbody>";
            for (var i = 0; i <data.length; i++) {
                var id = new String(data[i].uuid);
                var row = "<tr>" +
                    "<td>"+data[i].name+"</td>" +
                    "<td>"+data[i].description+"</td>" +
                    "<td>"+data[i].uuid+"</td>" +
                    "<td><input type='button' value='delete' onclick='deleteCohort("+ "\""+ id +"\""+")'/></td>" +
                    "</tr>";
                table = table + row;
            }
            table = table + "</tbody>" +
            "</table>";
            container.append(table);
        }

        function deleteCohort(id){
            if(id!==null){
                jq.ajax({
                    type: "DELETE",
                    url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort/"+id,
                    dataType: "json",
                    contentType: "application/json",
                    async: false,
                    success: function (data) {
                        jq().toastmessage('showSuccessToast', "Cohort Deleted");
                    }
                });
            }
        }


        function submit() {
            var name = jq('#name').val();
            var description = jq('#description').val();
            var unique_id = jq('#uuid').val();
            var cohort_type = jq('#cohort-type').val();
            var submitVal = true;


            if (name == ""){
                submitVal = false;
                jq().toastmessage('showErrorToast', "CDDP Name is required");
            }

            if (description== ""){
                submitVal = false;
                jq().toastmessage('showErrorToast', "CDDP Description is required");
            }

            if (unique_id == "") {
                submitVal = false;
                jq().toastmessage('showErrorToast', "CDDP unique identifier is required");
            }

            if (cohort_type == "") {
                submitVal = false;
                jq().toastmessage('showErrorToast', "Group Type is required");
            }

            if(hasWhiteSpace(unique_id)){
                submitVal = false;
                jq().toastmessage('showErrorToast', "No spaces are allowed in the unique identifier");
            }

            var today = new Date();
            var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
            var dataToPost = "{\"name\":\"" +  name + "\"," +
                " \"description\": \"" + description + "\"," +
                " \"uuid\":\"" + unique_id + "\","+
                " \"cohortType\":\"" + cohort_type + "\","+
                "\"location\":\"3ec8ff90-3ec1-408e-bf8c-22e4553d6e17\","+
                " \"groupCohort\":\"false\","+
                "\"startDate\":\""+ date + "\"}";
            if(submitVal){
                saveCohort(dataToPost)
            }
            console.log(dataToPost);
        }
    }
</script>

<div id="body-wrapper">
    <div class="container">
        <div class="headers" style="text-align: center;">
            <h3 style="background: #94979A; padding: 10px;">DSD SubGroup Management </h3>
        </div>
        <section>
            <div class="row">
                <div class="col-md-6">
                    <div class="row">
                        <div class="col-md-3">
                            <label>Name:</label>
                        </div>
                        <div class="col-md-4">
                            <input type="text" id="name" name="name"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-3">
                            <label>Description:</label>
                        </div>
                        <div class="col-md-4">
                            <input type="text" id="description" name="description"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-3">
                            <label>Identifier No:</label>
                        </div>
                        <div class="col-md-4">
                            <input type="text" id="uuid" name="uuid"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-3">
                            <label>Group type:</label>
                        </div>
                        <div class="col-md-4">
                            <select name="cohortType" id="cohort-type">
                                <option>Select ---</option>
                            </select>
                        </div>
                    </div>

                    <br/>
                    <input type="button" onclick="submit()" value="Save"/>
                </div>
                <div class="col-md-6">
                    <div class="well">
                        <div id="savedCohortsSections">

                        </div>
                    </div>
                </div>
            </div>

        </section>

    </div>


</div>
</body>
</html>