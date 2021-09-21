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
            getCohortTypes();

        });

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
        function saveCohort(dataToPost,url){
            jq.ajax({
                type: "POST",
                url: url,
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
                    getCohorts();
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
            jq('#savedCohortsSections').empty();

            getCohort("e50fa0af-df36-4a26-853f-feb05244e5ca");
            getCohort("aa536e57-a3c3-453c-9413-cf70b5d2ad5d");
            getCohort("5b7136fa-d207-4229-94a8-da6661ae00bf");
        }

        function getCohort(type){

            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort?v=default&cohortType="+type,
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
            for (var i = 0; i <data.length; i++) {
                if(data[i].cohortType!=null && data[i].voided==false){
                    var uuid = new String(data[i].uuid);
                    var myDate = new Date(data[i].startDate);
                    var row = "<tr id=\""+uuid+"\">" +
                        "<td>"+data[i].name+"</td>" +
                        "<td>"+data[i].description+"</td>" +
                        "<td>"+data[i].cohortType.name+"</td>" +
                        "<td>"+myDate.getFullYear()+"-"+myDate.getMonth()+"-"+myDate.getDate()+"</td>" +
                        "<td>"+uuid+"</td>" +
                        "<td>" +
                         "<i style=\"font-size: 25px\" data-toggle=\"modal\" data-target=\"#addEditRefillGroupModal\" class=\"icon-edit edit-action\" title=\"Edit\" onclick=\"editCohort('"+uuid+"')\"></i>" +
                         "<i style=\"font-size: 25px\"  class=\"delete-item icon-remove\" title=\"Delete\" onclick=\"deleteCohort('"+uuid+"')\"></i></td>" +
                        "</tr>";
                    container.append(row);
                }

            }
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
                        getCohorts();
                    }
                });
            }
        }

        function editCohort(id){
            jq("#cohort-type").empty();
            getCohortTypes()
            var row = jq('#'+id);
            row.each(function (i) {
                var tds = jq(this).find('td');
                   var name = tds.eq(0).text();
                   var description = tds.eq(1).text();
                   var type= tds.eq(2).text();
                   var uuid = tds.eq(4).text();

                jq('#name').attr("value",name);
                jq('#description').attr("value",description);
                jq('#uuid').attr("value",uuid);
                jq("#cohort-type option:contains('"+type+"')").attr("selected", "selected");
            });

            jq('.modal-footer > input').attr("onclick","saveEditedData('"+id+"')");

        }

        function saveEditedData(id){
            var dataToPost = processFormData();
            var url = '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort/"+id;
            if(dataToPost!==""){
                saveCohort(dataToPost,url);
            }
        }

        function submit() {
            var dataToPost = processFormData();
            var url = '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/cohortm/cohort";
            if(dataToPost!==""){
                saveCohort(dataToPost,url);
            }
        }

        function processFormData(){
            var name = jq('#name').val();
            var description = jq('#description').val();
            var unique_id = jq('#uuid').val();
            var cohort_type = jq('#cohort-type option:selected').val();
            console.log(cohort_type);
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
                "\"location\":\"841cb8d9-b662-41ad-9e7f-d476caac48aa\","+
                " \"groupCohort\":\"false\","+
                "\"startDate\":\""+ date + "\"}";
            if(submitVal==false){
                dataToPost="";
            }
            return dataToPost;
        }
    }
</script>

<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h2 style="color: maroon">DSD Refill Groups</h2>
                    </div>

                    <div class="">

                        <button type="button" style="font-size: 25px" class="confirm icon-plus-sign" data-toggle="modal"
                                data-target="#addEditRefillGroupModal"  data-whatever="@mdo">Create</button>
                    </div>

                    <div class="vertical"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-search-form" onsubmit="return false">
                        <input type="text" id="patient-search"
                               placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                               autocomplete="off"/>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body">
        <div class="info-body">
            <table>
                <thead>
                <tr>
                    <th>NAME</th>
                    <th>Description</th>
                    <th>Group type</th>
                    <th>CREATED ON</th>
                    <th>Identifier</th>
                    <th>ACTION</th>
                </tr>
                </thead>
                <tbody id="savedCohortsSections">

                </tbody>
            </table>
        </div>
    </div>
</div>


<div class="modal fade" id="addEditRefillGroupModal" tabindex="-1" role="dialog"
     aria-labelledby="addEditRefillGroup"
     aria-hidden="true">
    <div class="modal-dialog  modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addEditRefillGroup">Refill Group</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>


                <input type="hidden" name="syncTaskTypeId" id="syncTaskTypeId" value="">

                <div class="modal-body">
                    <div class="container">
                        <div class="row">
                            <div class="col-6">
                                <div class="form-group">
                                    <label>Name:</label>
                                    <input type="text" class="form-control" id="name" name="name"
                                           placeholder=" ie CDDP Group Name">
                                </div>

                                <div class="form-group">
                                    <label>Description</label>
                                    <input class="form-control" type="text" id="description" name="description"/>

                                </div>

                                <div class="form-group">
                                    <label>Identifier Code</label>
                                    <input class="form-control" type="text" id="uuid" name="uuid"/>
                                </div>
                            </div>


                            <div class="col-6">
                                <div class="form-group">
                                    <label>Group Type</label>
                                    <select class="form-control" name="cohortType" id="cohort-type">
                                        <option value="">Select ---</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <input type="button" class="confirm " data-dismiss="modal" value="${ui.message("Save")}" onclick="submit()" />
                </div>
        </div>
    </div>
</div>
</body>
</html>