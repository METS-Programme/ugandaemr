<%
    if (clinicianLocation?.contains(currentLocation?.uuid)) {
        ui.includeCss("coreapps", "patientsearch/patientSearchWidget.css")
%>
<style>
.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

.my-tab .tab-pane {
    border: solid 1px blue;
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
    if (jQuery) {

        setInterval(function () {
            console.log("Checking IF Reloading works");
            getPatientQueue();
        }, 1 * 60000);

        document.addEventListener('DOMContentLoaded', function() {
            var searchInput = document.getElementById('patient-search');
            searchInput.addEventListener('keyup', function() {
                var tableId=jq("#myTabContent").find(".active")[0].id;
                var dataTable = document.getElementById(''+tableId+'').getElementsByTagName('tbody')[0];
                var filter = searchInput.value.toLowerCase();
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

            jq('#add_patient_to_other_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget);
                var patientId = button.data('patient-id');
                var modal = jq(this)
                modal.find("#patient_id").val(patientId);
            });

            setLocationsToSelect();
            getPatientQueue()

            jq('#exampleModal').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget) // Button that triggered the modal
                var recipient = button.data('whatever') // Extract info from data-* attributes
                var order_id = button.data('order_id') // Extract info from data-* attributes
                jq("#order_id").val(order_id);
                jq("#sample_id").val("");
                jq("#reference_lab").prop('selectedIndex', 0);
                jq("#specimen_source_id").prop('selectedIndex', 0);
                jq("#refer_test input[type=checkbox]").prop('checked', false);
                // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
                // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
                var modal = jq(this)
                modal.find('.modal-title').text('New message to ' + order_id)
                modal.find('.modal-body input').val(order_id)
            })

            jq('#pick_patient_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget)

                var enounterId = getEncounterId(button.data('patientqueueid'));
                if (enounterId !== "" && enounterId !== null) {
                    jq("#patientQueueId").val(button.data('patientqueueid'));
                    var url = button.data('url');
                    url = url.replace("encounterIdToReplace", enounterId)
                    jq("#goToURL").val(url);
                } else {
                    var urlToPatientDashBoard = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", button.data('patientuuid'));
                    jq("#goToURL").val(urlToPatientDashBoard);
                }
            })
        });
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

    function getPatientQueue() {
        var url = "patientqueue?location=${currentLocation.uuid}&v=custom:(uuid,creator:(uuid,person:(uuid,display)),dateCreated,dateChanged,voided,patient:(uuid,names:(display),display,gender,birthdate,identifiers:(voided,preferred,uuid,display,location:(uuid,display))),provider:(uuid,display,person:(uuid,display)),locationFrom:(uuid,display,tags:(uuid,display)),locationTo:(uuid,display,tags:(uuid,display)),queueRoom:(uuid,display,tags:(uuid,display)),encounter:(uuid,visit:(uuid)),status,priority,priorityComment,visitNumber,comment,datePicked,dateCompleted)"
        var responseData = queryRestData(url, "GET", {})

        displayClinicianData(responseData);
    }

    function setLocationsToSelect() {
        jq("#error_location_id").html("");
        jq("#location_id").html("");
        var content = "";
        content += "<option value=\"\">" + "${ui.message("Specimen Source")}" + "</option>";
        <% if (locationList.size() > 0) {
                      locationList.each { %>
        content += "<option value=\"${it.uuid}\">" + "${it.name}" + "</option>";
        <%} }else {%>
        jq("#error_location_id").append(${ui.message("patientqueueing.select.error")});
        <%}%>
        jq("#location_id").append(content);
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

    function navigateToVisit(url, patientuuid, patientqueueuuid) {
        var enounterId = getEncounterId(patientqueueuuid);
        if (enounterId !== "" && enounterId !== null) {
            url = url.replace("encounterIdToReplace", enounterId)
            window.location.href = url;
        } else {
            url = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", button.data('patientuuid'));
            window.location.href = url;
        }
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

    function displayClinicianData(response) {
        jq("#clinician-queue-list-table").html("No Patient In  Pending List");
        jq("#clinician-completed-list-table").html("No Patient In Completed List");
        jq("#from-lab-list-table").html("No Patient In Lab List");
        var stillInQueueDataRows = "";
        var completedDataRows = "";
        var servingDataRows = "";
        var fromLabDataRows = "";
        stillInQueue = 0;
        completedQueue = 0;
        servingQueue = 0;
        fromLabQueue = 0;
        var headerPending = "<table id=\"pending_table\"><thead><tr><th>TOKEN</th><th>PATIENT ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>VISIT TYPE</th><th>ENTRY POINT</th><th>STATUS</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerServing = "<table id=\"serving_table\"><thead><tr><th>TOKEN</th><th>PATIENT ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>VISIT TYPE</th><th>ATTENDING PROVIDER</th><th>STATUS</th><th>SERVING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerCompleted = "<table id=\"completed_table\"><thead><tr><th>TOKEN</th><th>PATIENT ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>ENTRY POINT</th><th>STATUS</th><th>TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerFromLab = "<table id=\"fromlab_table\"><thead><tr><th>TOKEN</th><th>PATIENT ID</th><th>NAMES</th><th>GENDER</th><th>DOB</th><th>ENTRY POINT</th><th>STATUS</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var footer = "</tbody></table>";

        var dataToDisplay = [];

        if (response.results.length > 0) {
            dataToDisplay = response.results.sort(function (a, b) {
                return a.dateCreated - b.dateCreated;
            });
        }

        if ("${enablePatientQueueSelection}".trim() === "true") {
            jq("#serving-list").removeClass("hidden");
            jq("#clinician-serving").removeClass("hidden");
        } else {
            jq("#serving-list").addClass("hidden");
            jq("#clinician-serving").addClass("hidden");
        }

        jq.each(dataToDisplay, function (index, element) {
                var patientQueue = element;
                var dataRowTable = "";
                var urlToPatientDashBoard = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", element.patient.uuid);
                var encounterUrl = "";
                if (element.encounter !== null) {
                    encounterUrl = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=" + element.patient.uuid + "&encounterId=encounterIdToReplace&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                }
                var waitingTime = getWaitingTime(patientQueue.dateCreated, patientQueue.dateChanged);
                dataRowTable += "<tr>";
                if (patientQueue.visitNumber !== null) {
                    dataRowTable += "<td>" + patientQueue.visitNumber.substring(15) + "</td>";
                } else {
                    dataRowTable += "<td></td>";
                }
                dataRowTable += "<td>" + identifierToDisplay(patientQueue.patient.identifiers) + "</td>";
                dataRowTable += "<td>" + patientQueue.patient.names[0].display + "</td>";
                dataRowTable += "<td>" + patientQueue.patient.gender + "</td>";
                dataRowTable += "<td>" + jq.datepicker.formatDate('dd.M.yy', new Date(patientQueue.patient.birthdate)) + "</td>";


                if (element.status === "PENDING" && element.locationFrom.display !== "Main Laboratory") {
                    if (patientQueue.priorityComment != null) {
                        dataRowTable += "<td>" + patientQueue.priorityComment + "</td>";
                    } else {
                        dataRowTable += "<td></td>";
                    }
                }


                dataRowTable += "<td>" + patientQueue.locationFrom.display.substring(0, 3) + "</td>";


                if (element.status === "PICKED") {
                    if (element.provider != null) {
                        dataRowTable += "<td>" + element.provider.person.display + "</td>";
                    } else {
                        dataRowTable += "<td></td>";
                    }
                }

                dataRowTable += "<td>" + patientQueue.status + "</td>";
                dataRowTable += "<td>" + waitingTime + "</td>";
                dataRowTable += "<td>";


                if ("${enablePatientQueueSelection}".trim() === "true" && patientQueue.status === "PENDING") {
                    dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-dashboard view-action\" title=\"Capture Vitals\" data-toggle=\"modal\" data-target=\"#pick_patient_queue_dialog\" data-id=\"\" data-patientqueueid='" + element.uuid + "' data-url='" + urlToPatientDashBoard + "'></i>";
                } else {
                    dataRowTable += "<i style=\"font-size: 25px;\" class=\"icon-dashboard view-action\" title=\"Goto Patient's Dashboard\" onclick=\"location.href = '" + urlToPatientDashBoard + "'\"></i>";
                }

                if (element.status === "PENDING" && element.locationFrom.display !== "Main Laboratory") {
                    dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-external-link edit-action\" title=\"Send Patient To Another Location\" data-toggle=\"modal\" data-target=\"#add_patient_to_other_queue_dialog\" data-id=\"\" data-patient-id=\"%s\"></i>".replace("%s", element.patient.uuid);
                } else if ((element.status === "PENDING" || element.status === "from lab") && element.locationFrom.display === "Main Laboratory" && "${enablePatientQueueSelection}".trim() === "true") {
                    dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Edit Patient Encounter\" data-toggle=\"modal\" data-target=\"#pick_patient_queue_dialog\" data-id=\"\" data-patientqueueid='" + element.uuid + "' data-url='" + encounterUrl + "'></i>";
                } else if ((element.status === "PENDING" || element.status === "from lab") && element.locationFrom.display === "Main Laboratory" && "${enablePatientQueueSelection}".trim() !== "true") {
                    dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Edit Patient Encounter\" onclick=\"navigateToVisit('" + encounterUrl + "','" + patientQueue.patient.uuid + "','" + element.uuid + "')\"></i>";
                }

                dataRowTable += "</td></tr>";

                if ((element.status === "PENDING" || element.status === "from lab") && element.locationFrom.display === "Main Laboratory") {
                    fromLabQueue += 1;
                    fromLabDataRows += dataRowTable;
                } else if (element.status === "PENDING" && element.locationFrom.display !== "Main Laboratory") {
                    stillInQueue += 1;
                    stillInQueueDataRows += dataRowTable;
                } else if (element.status === "PICKED") {
                    servingQueue += 1;
                    servingDataRows += dataRowTable;
                } else if (element.status === "COMPLETED" && element.locationFrom.display !== "Main Laboratory") {
                    completedQueue += 1;
                    completedDataRows += dataRowTable;
                }
            }
        )
        ;

        if (stillInQueueDataRows !== "") {
            jq("#clinician-queue-list-table").html("");
            jq("#clinician-queue-list-table").append(headerPending + stillInQueueDataRows + footer);

        }

        if (completedDataRows !== "") {
            jq("#clinician-completed-list-table").html("");
            jq("#clinician-completed-list-table").append(headerCompleted + completedDataRows + footer);
        }

        if (servingDataRows !== "") {
            jq("#clinician-serving-list-table").html("");
            jq("#clinician-serving-list-table").append(headerServing + servingDataRows + footer);
        }

        if (fromLabDataRows !== "") {
            jq("#from-lab-list-table").html("");
            jq("#from-lab-list-table").append(headerFromLab + fromLabDataRows + footer);
        }


        jq("#clinician-pending-number").html("");
        jq("#clinician-pending-number").append("   " + stillInQueue);
        jq("#clinician-serving-number").html("");
        jq("#clinician-serving-number").append("   " + servingQueue);
        jq("#clinician-completed-number").html("");
        jq("#clinician-completed-number").append("   " + completedQueue);
        jq("#from-lab-number").html("");
        jq("#from-lab-number").append("   " + fromLabQueue);
    }
</script>
<br/>

<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h3 style="color: maroon">${currentLocation.name} - ${ui.message("Queue")}</i></h3>
                    </div>

                    <div style="text-align: center">
                        <h4>${currentProvider?.person?.personName?.fullName}</h4>
                    </div>

                    <div class="vertical"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-search-form" onsubmit="return false">
                        <input type="text" id="patient-search"
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
                <a class="nav-item nav-link active" id="home-tab" data-toggle="tab" href="#clinician-pending" role="tab"
                   aria-controls="clinician-pending-tab" aria-selected="true">Patients New <span style="color:red"
                                                                                                 id="clinician-pending-number">0</span>
                </a>
            </li>
            <li class="nav-item hidden" id="serving-list">
                <a class="nav-link" id="serving-tab" data-toggle="tab" href="#clinician-serving" role="tab"
                   aria-controls="clinician-serving-tab" aria-selected="false">Serving<span style="color:red"
                                                                                            id="clinician-serving-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="profile-tab" data-toggle="tab" href="#from-lab" role="tab"
                   aria-controls="from-lab-tab" aria-selected="false">Patients - Lab Results<span style="color:red"
                                                                                                  id="from-lab-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="contact-tab" data-toggle="tab" href="#clinician-completed" role="tab"
                   aria-controls="clinician-completed-number-tab" aria-selected="false">Patients - Attended To<span
                        style="color:red" id="clinician-completed-number">0</span></a>
            </li>
        </ul>

        <div class="tab-content" id="myTabContent">
            <div class="tab-pane fade show active" id="clinician-pending" role="tabpanel"
                 aria-labelledby="clinician-pending-tab">
                <div class="info-body">
                    <div id="clinician-queue-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade hidden" id="clinician-serving" role="tabpanel"
                 aria-labelledby="clinician-serving-tab">
                <div class="info-body">
                    <div id="clinician-serving-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="from-lab" role="tabpanel" aria-labelledby="from-lab-tab">
                <div class="info-body">
                    <div id="from-lab-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="clinician-completed" role="tabpanel"
                 aria-labelledby="clinician-completed-tab">
                <div class="info-body">
                    <div id="clinician-completed-list-table">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
${ui.includeFragment("ugandaemr", "addPatientToAnotherQueue")}
${ui.includeFragment("ugandaemr", "pickPatientFromQueue", [provider: currentProvider, currentLocation: currentLocation])}
<% } %>