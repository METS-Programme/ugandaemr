<% if (currentLocation?.uuid?.equals(triageLocation)) { %>
<%
        ui.includeCss("coreapps", "patientsearch/patientSearchWidget.css")
        ui.includeJavascript("patientqueueing", "patientqueue.js")
        ui.includeJavascript("ugandaemr", "js/ugandaemr.js")
%>
<style>
.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

.vertical {
    border-left: 1px solid #c7c5c5;
    height: 79px;
    position: absolute;
    left: 99%;
    top: 11%;
}
</style>
<script>
    var stillInQueue = 0;
    var servingQueue = 0;
    var completedQueue = 0;
    jq(document).ready(function () {
        jq("#tabs").tabs();
    })
    if (jQuery) {
        /*setInterval(function () {
            console.log("Checking IF Reloading works");
            getPatientQueue();
        }, 3000);*/

        document.addEventListener('DOMContentLoaded', function() {
            var searchInput = document.getElementById('patient-triage-search');
            searchInput.addEventListener('keyup', function() {
                var tableId=jq("#myTabContent").find(".active")[0].id;
                var dataTable = document.getElementById(''+tableId+'').getElementsByTagName('tbody')[0];
                var filter = searchInput[0].value.toLowerCase();
                var rows = dataTable.getElementsByTagName('tr');

                for (var i = 0; i < rows.length; i++) {
                    var cells = rows[i].getElementsByTagName('td');
                    var rowText = '';
                    for (var j = 0; j < cells.length; j++) {
                        rowText += cells[j].textContent.toLowerCase();
                    }

                    if (rowText.indexOf(filter) > -1) {
                        rows[i].style.display = '';
                    } else {
                        rows[i].style.display = 'none';
                    }
                }
            });
        });

        jq(document).ready(function () {
            jq(document).on('sessionLocationChanged', function () {
                window.location.reload();
            });
            jq("#clinician-list").hide();
            getPatientQueue();
            jq('#pick_patient_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget)
                var patientVisits = queryRestData("visit?patient=" + button.data('patientuuid') + "&includeInactive=false&visitType=7b0f5697-27e3-40c4-8bae-f4049abfb4ed&v=custom:(uuid,dateCreated)")
                var enounterId = getEncounterId(button.data('patientqueueid'));
                if (patientVisits !== null && patientVisits.results.length > 0) {
                    jq("#patientQueueId").val(button.data('patientqueueid'));
                    var url = button.data('url');
                    url = url.replace("visitIdToReplace", patientVisits.results[0].uuid)
                    if (enounterId !== "" && enounterId !== null) {
                        url = url.replace("encounterIdToReplace", enounterId)
                    }
                    jq("#goToURL").val(url);
                } else {
                    var urlToPatientDashBoard = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", button.data('patientuuid'));
                    jq("#goToURL").val(urlToPatientDashBoard);
                }
            })
        });
    }
    jq("form").submit(function (event) {
        alert("Handler for .submit() called.");
    });

    function navigateToVisit(url, patientuuid, patientqueueuuid) {
        var enounterId = getEncounterId(patientqueueuuid);
        var patientVisits = queryRestData("visit?patient=" + patientuuid + "&includeInactive=false&visitType=7b0f5697-27e3-40c4-8bae-f4049abfb4ed&v=custom:(uuid,dateCreated)")
        if (patientVisits !== null && patientVisits.results.length > 0) {
            url = url.replace("visitIdToReplace", patientVisits.results[0].uuid)
            if (enounterId !== "" && enounterId !== null) {
                url = url.replace("encounterIdToReplace", enounterId)
            }
            window.location.href = url;
        } else {
            url = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", button.data('patientuuid'));
            window.location.href = url;
        }
    }


    //GENERATION OF LISTS IN INTERFACE SUCH AS WORKLIST
    // Get Patients In Triage Queue
    function getPatientQueue() {
        var url = "patientqueue?location=${currentLocation.uuid}&v=custom:(uuid,creator:(uuid,person:(uuid,display)),dateCreated,dateChanged,voided,patient:(uuid,names:(display),display,gender,birthdate,identifiers:(voided,preferred,uuid,display,location:(uuid,display))),provider:(uuid,display,person:(uuid,display)),locationFrom:(uuid,display,tags:(uuid,display)),locationTo:(uuid,display,tags:(uuid,display)),queueRoom:(uuid,display,tags:(uuid,display)),encounter:(uuid,visit:(uuid)),status,priority,priorityComment,visitNumber,comment,datePicked,dateCompleted)"
        var responseData = queryRestData(url, "GET", {})

        displayTriageData(responseData);
    }


    function queryRestData(url, method, data) {
        var responseData = null;
        jq.ajax({
            type: method,
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/" + url,
            dataType: "json",
            contentType: "application/json",
            accept: "application/json",
            async: false,
            data: data,
            success: function (response) {
                responseData = response;
            },
            error: function (response) {
                responseData = response
            }
        });
        return responseData;
    }

    function getEncounterId(patientQueueUuid) {
        var encounterId = null;
        jq.ajax({
            type: "GET",
            url: "${ui.actionLink("getEncounterId")}" + "&patientQueueUuid=" + patientQueueUuid,
            async: false,
            success: function (response) {
                encounterId = response.encounterId;
            },
            error: function (response) {
            }
        });
        return encounterId
    }

    function identifierToDisplay(identifiers) {
        var identifierToDisplay = "";
        jq.each(identifiers, function (index, element) {
            if (element.voided === false && element.preferred === true) {
                identifierToDisplay += element.display.replace("=", ":") + " <br/> "
            }
        });

        return identifierToDisplay
    }

    function displayTriageData(response) {
        jq("#triage-queue-list-table").html("");
        var stillInQueueDataRows = "";
        var completedDataRows = "";
        var servingDataRows = "";
        stillInQueue = 0;
        servingQueue = 0;
        completedQueue = 0;
        var headerPending = "<table id=\"pending\"><thead><tr><th>TOKEN & ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>VISIT STATUS</th><th>ENTRY POINT</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerCompleted = "<table id=\"completed\"><thead><tr><th>TOKEN & ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>ENTRY POINT</th><th>COMPLETED TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerServing = "<table id=\"serving\"><thead><tr><th>TOKEN & ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>VISIT STATUS</th><th>PICKED POINT</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var footer = "</tbody></table>";

        var dataToDisplay = [];

        if (response.results.length > 0) {
            dataToDisplay = response.results.sort(function (a, b) {
                return a.dateCreated - b.dateCreated;
            });
        }

        if ("${enablePatientQueueSelection}".trim() === "true") {
            jq("#serving-list").removeClass("hidden");
            jq("#triage-serving-list").removeClass("hidden");
        } else {
            jq("#serving-list").addClass("hidden");
            jq("#triage-serving-list").addClass("hidden");
        }

        jq.each(dataToDisplay, function (index, element) {
                var patientQueue = element;
                var dataRowTable = "";
                var vitalsPageLocation = "";
                if (element.status !== "COMPLETED" && element.encounter == null) {
                    vitalsPageLocation = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/enterHtmlFormWithStandardUi.page?patientId=" + patientQueue.patient.uuid + "&visitId=visitIdToReplace&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                } else if (element.status !== "COMPLETED" && element.encounter !== null) {
                    vitalsPageLocation = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=" + patientQueue.patient.uuid + "&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&encounterId=encounterIdToReplace&visitId=visitIdToReplace&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                } else if (element.encounter !== null) {
                    vitalsPageLocation = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=" + patientQueue.patient.uuid + "&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&encounterId=encounterIdToReplace&visitId=visitIdToReplace&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                }

                var action = "";

                if ("${enablePatientQueueSelection}".trim() === "true" && patientQueue.status === "PENDING") {
                    action += "<i  style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Capture Vitals\" data-toggle=\"modal\" data-target=\"#pick_patient_queue_dialog\" data-id=\"\" data-patientqueueid='" + element.uuid + "' data-patientuuid='" + element.patient.uuid + "' data-url='" + vitalsPageLocation + "'></i>";
                } else {
                    action += "<a onclick=\"navigateToVisit('" + vitalsPageLocation + "','" + patientQueue.patient.uuid + "','" + element.uuid + "')\" <i style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Capture Vitals\"></i></a>";
                }

                var waitingTime = getWaitingTime(patientQueue.dateCreated, patientQueue.dateChanged);
                dataRowTable += "<tr>";
                if (patientQueue.visitNumber !== null) {
                    dataRowTable += "<td> Token No: " + patientQueue.visitNumber.substring(15) + "<br/>" + identifierToDisplay(patientQueue.patient.identifiers) + "</td>";
                } else {
                    dataRowTable += "<td></td>";
                }
                dataRowTable += "<td>" + patientQueue.patient.names[0].display + "</td>";
                dataRowTable += "<td>" + patientQueue.patient.gender + "</td>";
                dataRowTable += "<td>" + jq.datepicker.formatDate('dd.M.yy', new Date(patientQueue.patient.birthdate)) + "</td>";

                if (element.status !== "COMPLETED") {

                    if (patientQueue.status != null) {
                        dataRowTable += "<td>" + patientQueue.status + "</td>";
                    } else {
                        dataRowTable += "<td></td>";
                    }
                }
                dataRowTable += "<td>" + patientQueue.locationFrom.display.substring(0, 3) + "</td>";
                dataRowTable += "<td>" + waitingTime + "</td>";
                dataRowTable += "<td>" + action + "</td>";
                dataRowTable += "</tr>";
                if (element.status === "PENDING") {
                    stillInQueue += 1;
                    stillInQueueDataRows += dataRowTable;

                } else if (element.status === "PICKED") {
                    servingQueue += 1;
                    servingDataRows += dataRowTable;
                } else if (element.status === "COMPLETED") {
                    completedQueue += 1;
                    completedDataRows += dataRowTable;
                }
            }
        );

        if (stillInQueueDataRows !== "") {
            jq("#triage-queue-list-table").html("");
            jq("#triage-queue-list-table").append(headerPending + stillInQueueDataRows + footer);

        }
        if (servingDataRows !== "") {
            jq("#triage-serving-list-table").html("");
            jq("#triage-serving-list-table").append(headerServing + servingDataRows + footer);

        }
        if (completedDataRows !== "") {
            jq("#triage-completed-list-table").html("");
            jq("#triage-completed-list-table").append(headerCompleted + completedDataRows + footer);

        }
        jq("#triage-pending-number").html("");
        jq("#triage-pending-number").append(stillInQueue);
        jq("#triage-serving-number").html("");
        jq("#triage-serving-number").append(servingQueue);
        jq("#triage-completed-number").html("");
        jq("#triage-completed-number").append(completedQueue);
    }

    //SUPPORTIVE FUNCTIONS//
    //Get Waiting Time For Patient In Queue

</script>
<br/>


<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h1 style="color: maroon" class="">${ui.message("Triage Queue")}</i></h1>
                    </div>

                    <div>
                        <h2>${currentProvider?.person?.personName?.fullName}</h2>
                    </div>

                    <div class="vertical"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-triage-search-form" onsubmit="return false">
                        <input id="patient-triage-search" name="patient-triage-search"
                               placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                               autocomplete="off" class="provider-dashboard-patient-search"/>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body">
        <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
            <li class="nav-item">
                <a class="nav-item nav-link active" id="home-tab" data-toggle="tab" href="#queue-triage" role="tab"
                   aria-controls="queue-triage-tab" aria-selected="true">Pending Patients <span style="color:red"
                                                                                                id="triage-pending-number">0</span>
                </a>
            </li>
            <li class="nav-item hidden" id="serving-list">
                <a class="nav-link" id="serving-tab" data-toggle="tab" href="#triage-serving-list" role="tab"
                   aria-controls="triage-serving-list-tab" aria-selected="true">Serving Patients<span style="color:red"
                                                                                                      id="triage-serving-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="profile-tab " data-toggle="tab" href="#triage-completed-list" role="tab"
                   aria-controls="triage-completed-list-tab" aria-selected="false">Completed Patients <span
                        style="color:red" id="triage-completed-number">0</span>
                </a>
            </li>
        </ul>

        <div class="tab-content" id="myTabContent">
            <div class="tab-pane fade show active" id="queue-triage" role="tabpanel"
                 aria-labelledby="queue-triage-tab">
                <div class="info-body">
                    <div id="triage-queue-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade hidden" id="triage-serving-list" role="tabpanel"
                 aria-labelledby="triage-serving-list-tab">
                <div class="info-body">
                    <div id="triage-serving-list-table">
                    </div>
                </div>
            </div>


            <div class="tab-pane fade" id="triage-completed-list" role="tabpanel"
                 aria-labelledby="triage-completed-list-tab">
                <div class="info-body">
                    <div id="triage-completed-list-table">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

${ui.includeFragment("ugandaemr", "pickPatientFromQueue", [provider: currentProvider, currentLocation: currentLocation])}

<% } %>







