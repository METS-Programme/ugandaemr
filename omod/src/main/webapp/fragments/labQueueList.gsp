<% if (clinicianLocation?.contains(currentLocation?.uuid)) { %>
<%
        ui.includeCss("coreapps", "patientsearch/patientSearchWidget.css")
        ui.includeJavascript("patientqueueing", "patientqueue.js")
        ui.includeJavascript("ugandaemr", "js/ugandaemr.js")
%>
<style>
.div-table {
    display: table;
    width: 100%;
}

.div-row {
    display: table-row;
    width: 100%;
}

.div-col1 {
    display: table-cell;
    margin-left: auto;
    margin-right: auto;
    width: 100%;
}

.div-col2 {
    display: table-cell;
    margin-right: auto;
    margin-left: auto;
    width: 50%;
}

.div-col3 {
    display: table-cell;
    margin-right: auto;
    margin-left: auto;
    width: 33%;
}

.div-col4 {
    display: table-cell;
    margin-right: auto;
    margin-left: auto;
    width: 25%;
}

.div-col5 {
    display: table-cell;
    margin-right: auto;
    margin-left: auto;
    width: 20%;
}

.div-col6 {
    display: table-cell;
    margin-right: auto;
    margin-left: auto;
    width: 16%;
}

.dialog {
    width: 550px;
}

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

.fade:not(.show) {
    opacity: 1;
}
</style>

<script>
    jq(document).ready(function () {
        jq("#tabs").tabs();
    })
    if (jQuery) {
        jq(document).ready(function () {
            jq(document).on('sessionLocationChanged', function () {
                window.location.reload();
            });
            jq("#clinician-list").hide();
            getPatientLabQueue();
            getOrders();
            getResults();
            setSpecimenSource();

            jq("#patient-lab-search").change(function () {
                if (jq("#patient-lab-search").val().length >= 3) {
                    getPatientLabQueue();
                }
            });

            jq("#submit-schedule").click(function () {
                if (jq("#refer_test").is("checked") && jq("#reference_lab").val() === "") {
                    jq().toastmessage('showErrorToast', "Specify the the Lab you are referring the  test to");
                    return;
                }
                var patientQueueId = null
                var unProcessedOrders = null

                if (jq("#patient-queue-id").val() != null && jq("#patient-queue-id").val() !== "undefined") {
                    patientQueueId = jq("#patient-queue-id").val();
                }

                if (jq("#unprocessed-orders").val() != null && jq("#unprocessed-orders").val() !== "undefined") {
                    unProcessedOrders = jq("#patient-queue-id").val();
                }

                jq.get('${ ui.actionLink("scheduleTest") }', {
                    orderId: jq("#order_id").val(),
                    sampleId: jq("#sample_id").val(),
                    referTest: jq("#refer_test").val(),
                    referenceLab: jq("#reference_lab").val(),
                    specimenSourceId: jq("#specimen_source_id").val(),
                    patientQueueId: patientQueueId,
                    unProcessedOrders: unProcessedOrders
                }, function (response) {
                    if (!response) {
                        ${ ui.message("coreapps.none ") }
                    }
                });
            });

            jq("#submit-order-reject").click(function () {
                var orderuuid = jq("#reject_order_id").val().trim().toLowerCase();
                var rejectComment = jq("#order_reject_comment").val().trim().toLowerCase();
                var dataToPost = "{\"fulfillerStatus\":\"EXCEPTION\",\"fulfillerComment\":\"" + rejectComment + "\"}";

                jq.ajax({
                    type: "POST",
                    url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/order/" + orderuuid + "/fulfillerdetails",
                    dataType: "json",
                    contentType: "application/json;",
                    data: dataToPost,
                    async: false,
                    success: function (response) {
                        serverResponse = response.results;
                        jq().toastmessage('showSuccessToast', "Successfuly rejected " + response.results.length + " Orders");
                        jq('#reject-order-dialog').modal('hide').data('bs.modal', null);
                        jq('#reject-order-dialog').modal("dispose");
                    },
                    error: function (response) {
                        if ((response.status == 200 || response.status == 201) && response.statusText === "Created") {
                            jq().toastmessage('showSuccessToast', response.statusText);
                        } else {
                            jq().toastmessage('showErrorToast', response.responseJSON.error.message);
                        }
                        jq('#reject-order-dialog').modal('hide').data('bs.modal', null);
                        jq('#reject-order-dialog').modal("dispose");
                    }
                });

                jq.get('${ ui.actionLink("scheduleTest") }', {
                    orderNumber: jq("#order_id").val().trim().toLowerCase(),
                    sampleId: jq("#sample_id").val().trim().toLowerCase(),
                    referTest: jq("#refer_test").val().trim().toLowerCase(),
                    referenceLab: jq("#reference_lab").val().trim().toLowerCase(),
                    specimenSourceId: jq("#specimen_source_id").val().trim().toLowerCase(),
                    patientQueueId: jq("#patient-queue-id").val().trim().toLowerCase(),
                    unProcessedOrders: jq("#unprocessed-orders").val().trim().toLowerCase()
                }, function (response) {
                    if (!response) {
                        ${ ui.message("coreapps.none ") }
                    }
                });
            });

            jq("#lab-results-tab").click(function () {
                jq("#result-search").show();
            });

            jq("#search-results").click(function () {
                getResults(jq("#asOfDate").val());
            });

            jq('#reject-order-dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget);
                var orderuuid = button.data('order-id');
                var modal = jq(this)
                modal.find("#reject_order_id").val(orderuuid);
                modal.find("#order_reject_comment").value = "";
            });


            jq('#pick_patient_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget);
                var modal = jq(this);
                modal.find("#patientQueueId").val(button.data('patientqueueid'));
                modal.find("#goToURL").val(button.data('url'));
            })
        });

        function scheduleBulkOrders(queueId,unprocessed) {
            var selectedOrders = []
            jq("#schedule-lab-orders-bulk" + queueId).find("input[type=checkbox]:checked").each(function () {
                selectedOrders.push(getOrderByOrderUuid(jq(this).val()));
            });
            getEditScheduleBulkTempLate(selectedOrders,unprocessed)
        }

        function getOrderByOrderUuid(uuid) {
            var order = {};

            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/order/" + uuid,
                dataType: "json",
                contentType: "application/json;",
                async: false,
                success: function (response) {
                    if (response) {
                        order = response;
                    }
                }
            }).error(function (data, status, err) {
            });
            return order;
        }

        function reloadPending() {
            getPatientLabQueue();
        }

        function reloadWorkList() {
            getOrders();
        }

        function reloadResults() {
            getResults();
        }

        function reloadReferred() {
            getResults();
        }
    }

    jq("form").submit(function (event) {
        alert("Handler for .submit() called.");
    });

    //GENERATION OF LISTS IN INTERFACE SUCH AS WORKLIST
    // Get Patients In Lab Queue
    function getPatientLabQueue() {
        jq("#pending-queue-lab-table").html("");
        jq.get('${ ui.actionLink("getPatientQueueList") }', {
            labSearchFilter: jq("#patient-lab-search").val().trim().toLowerCase()
        }, function (response) {
            if (response) {
                var responseData = response;
                displayLabData(responseData);
            } else if (!response) {
                jq("#pending-queue-lab-table").append(${ ui.message("coreapps.none ") });
            }
        });
    }

    // Gets Orders of List of WorkList and Refered Tests
    function getOrders() {

        var date = "${labWorkListBackLogDaysToDisplay}";
        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/order?orderTypes=52a447d3-a64a-11e3-9aeb-50e549534c5e&&careSetting=6f0c9a92-6f24-11e3-af88-005056821db0&activatedOnOrAfterDate=" + date + "&isStopped=false&fulfillerStatus=IN_PROGRESS&v=full",
            dataType: "json",
            contentType: "application/json;",
            async: false,
            success: function (response) {
                if (response) {
                    var responseData = response;
                    displayLabOrderApproachA(groupOrdersByEncounter(responseData));
                    //displayLabOrder(responseData)
                }
            }
        });
    }

    function groupOrdersByEncounter(data) {
        const groupedData = {"results": []};
        let itemNo = 0;
        data.results.forEach((item, index) => {
            const key = item.encounter.uuid;
            let keyExists = false;

            groupedData.results.forEach((groupItem, index) => {
                if (groupItem.encounter && groupItem.encounter === key) {
                    keyExists = true;
                    groupItem.orders.push(item)
                }
            });

            if (!keyExists) {
                groupedData.results[itemNo] = {"encounter": "" + key + "", "orders": [], "patient": item.patient};
                groupedData.results[itemNo].orders.push(item);
                itemNo++;
            }

        });
        return groupedData;
    }

    function groupOrderResultsByEncounter(data) {
        const groupedData = {"ordersList": []};
        let itemNo = 0;
        data.forEach((item, index) => {
            const key = item.encounterId;
            let keyExists = false;

            groupedData.ordersList.forEach((groupItem, index) => {
                if (groupItem.encounter && groupItem.encounter === key) {
                    keyExists = true;
                    groupItem.orders.push(item)
                }
            });

            if (!keyExists) {
                groupedData.ordersList[itemNo] = {"encounter": key, "orders": [], "patient": item.patient,};
                groupedData.ordersList[itemNo].orders.push(item);
                itemNo++;
            }

        });
        return groupedData;
    }

    // Gets Orders with results for The List of results
    function getResults(date) {
        jq.get('${ ui.actionLink("getOrderWithResult") }', {
            date: date
        }, function (response) {
            if (response) {
                displayLabOrderApproachB(groupOrderResultsByEncounter(JSON.parse(response.ordersList)));
            }
        });
    }

    function identifierToDisplay(identifiers) {
        var identifierToDisplay = "";
        jq.each(identifiers, function (index, element) {
            identifierToDisplay += element.identifierTypeName + " : " + element.identifier + " <br/> "
        });

        return identifierToDisplay
    }

    function displayLabData(response) {
        var content = "";
        var pendingCounter = 0;
        content = "<table><thead><tr><th>VISIT ID</th><th>PATIENT NO.</th><th>NAMES</th><th>AGE</th><th>ORDER FROM</th><th>WAITING TIME</th><th>TEST(S) ORDERED</th></tr></thead><tbody>";


        var dataToDisplay = [];

        if (response.patientLabQueueList.length > 0) {
            dataToDisplay = JSON.parse(response.patientLabQueueList).sort(function (a, b) {
                return a.patientQueueId - b.patientQueueId;
            });
        }

        jq.each(dataToDisplay, function (index, element) {
                var orders = displayLabOrderData(element, element.patientQueueId, true);
                if (orders !== null) {
                    var isPatientPicked = element.status === "PICKED";
                    var patientQueueListElement = element;
                    var waitingTime = getWaitingTime(patientQueueListElement.dateCreated, patientQueueListElement.dateChanged);

                    var visitNumber = "";
                    if (patientQueueListElement.visitNumber != null) {
                        visitNumber = patientQueueListElement.visitNumber.substring(15);
                    }

                    content += "<tr>";
                    content += "<td>" + visitNumber + "</td>";
                    content += "<td>" + identifierToDisplay(patientQueueListElement.patientIdentifier) + "</td>";
                    content += "<td>" + patientQueueListElement.patientNames + "</td>";
                    content += "<td>" + patientQueueListElement.age + "</td>";
                    content += "<td>" + patientQueueListElement.providerNames + " - " + patientQueueListElement.locationFrom + "</td>";
                    content += "<td>" + waitingTime + "</td>";
                    content += "<td>";
                    if (isPatientPicked || "${enablePatientQueueSelection}".trim() === "false") {
                        content += "<a class=\"icon-list-alt\" data-toggle=\"collapse\" href=\"#collapse-tab\" role=\"button\" aria-expanded=\"false\" aria-controls=\"collapseExample\"> <span style=\"color: red;\">TestNo</span> Tests Unproccessed</a>".replace("#collapse-tab", "#collapse-tab" + patientQueueListElement.patientQueueId).replace("TestNo", noOfTests(element));
                        content += "<div class=\"collapse\" id=\"collapse-tab" + patientQueueListElement.patientQueueId + "\"><div class=\"card card-body\">" + orders + "</div></div>";
                    }

                    if (!isPatientPicked && "${enablePatientQueueSelection}".trim() === "true") {
                        content += "<i  style=\"font-size: 25px;\" class=\"icon-signin view-action\" title=\"Select Patient\" data-toggle=\"modal\" data-target=\"#pick_patient_queue_dialog\" data-id=\"\" data-patientqueueid='" + patientQueueListElement.patientQueueId + "' data-url=\"\"></i>";
                    }
                    content += "</td>";
                    content += "</tr>";

                    pendingCounter += 1;
                }
            }
        );
        content += "</tbody></table>";
        jq("#pending-queue-lab-table").append(content);
        jq("#pending-queue-lab-number").html("");
        jq("#pending-queue-lab-number").append("   " + pendingCounter);
    }

    function displayLabOrderData(labQueueList, queueId, removeProccesedOrders) {
        var header = "<div id='schedule-lab-orders-bulk" + queueId + "'" + "><table><thead></thead><tbody>";
        var footer = "</tbody></table>" +
            "<br/><button onclick='scheduleBulkOrders(" + queueId + ","+noOfTests(labQueueList)+")' class='confirm'>Schedule Selected</button>";
        var orderedTestsRows = "";
        var urlToPatientDashBoard = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", labQueueList.patientId);

        jq.each(labQueueList.orderMapper, function (index, element) {
            if (removeProccesedOrders !== false && element.accessionNumber === null && element.status === "active" && element.fulfillerStatus === null && (element.orderClass==="LabSet" || element.orderClass==="Test") ) {
                var urlTransferPatientToAnotherQueue = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.orderNumber);
                orderedTestsRows += "<tr>";
                orderedTestsRows += "<td><input type='checkbox' name='test-to-accession' value='" + element.orderUuid + "'/></td>";
                orderedTestsRows += "<td>" + element.conceptName + "</td>";
                orderedTestsRows += "<td>";
                orderedTestsRows += "<a  data-toggle=\"modal\" data-target=\"#add-order-to-lab-worklist-dialog\" data-order-number=\"orderNumber\" data-order-id=\"orderId\" data-orderuuid=\"patientorderuuid\" data-unprocessed-orders=\"unProcessedOrders\" data-patientqueueid=\"patientQueueId\"><i style=\"font-size: 25px;\" class=\"icon-share\" title=\"Check In\"></i></a>".replace("orderNumber", element.orderNumber).replace("orderId", element.orderId).replace("patientorderuuid", element.orderUuid).replace("unProcessedOrders", noOfTests(labQueueList)).replace("patientQueueId", labQueueList.patientQueueId);
                orderedTestsRows += "<a  data-toggle=\"modal\" data-target=\"#reject-order-dialog\" data-order-number=\"orderNumber\" data-order-id=\"orderId\" data-unprocessed-orders=\"unProcessedOrders\" data-patientqueueid=\"patientQueueId\"><i style=\"font-size: 25px;\" class=\" icon-remove-sign\" title=\"Reject Order\"></i></a>".replace("orderNumber", element.orderNumber).replace("orderId", element.orderUuid).replace("unProcessedOrders", noOfTests(labQueueList)).replace("patientQueueId", labQueueList.patientQueueId);
                orderedTestsRows += "</td>";
                orderedTestsRows += "</tr>";
            }
        });


        if (orderedTestsRows !== "") {
            return header + orderedTestsRows + footer;
        } else {
            return null;
        }
    }

    function noOfTests(labQueueList) {
        var orderCount = 0;
        jq.each(labQueueList.orderMapper, function (index, element) {
            if (element.accessionNumber === null && element.status === "active" && element.fulfillerStatus === null && (element.orderClass==="LabSet" || element.orderClass==="Test")) {
                orderCount += 1;
            }
        });
        return orderCount;
    }

    function displayLabOrder(labQueueList) {
        var referedTests = "";
        var workListTests = "";

        var tableHeader = "<table><thead><tr><th>SAMPLE ID</th><th>PATIENT NAME</th><th>DATE</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";

        var tableFooter = "</tbody></table>";
        var refferedCounter = 0;
        var worklistCounter = 0;
        jq.each(labQueueList.results, function (index, element) {
            var orderedTestsRows = "";
            var instructions = element.instructions;
            var actionIron = "";
            var actionURL = "";
            if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                actionIron = "icon-tags edit-action";
                actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.uuid);
            } else {
                actionIron = "icon-tags edit-action";
                actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.uuid);
            }
            orderedTestsRows += "<tr>";
            orderedTestsRows += "<td>" + element.accessionNumber + "</td>";
            orderedTestsRows += "<td>" + element.patient.display + "</td>";
            orderedTestsRows += "<td>" + element.dateActivated + "</td>";
            orderedTestsRows += "<td>" + element.concept.display + "</td>";
            orderedTestsRows += "<td>" + element.fulfillerStatus + "</td>";
            orderedTestsRows += "<td>";
            orderedTestsRows += "<a title=\"Edit Result\" onclick='showEditResultForm(\"" + element.uuid + "\")'><i class=\"icon-list-ul small\"></i></a>";
            orderedTestsRows += "<i class=\" + actionIron + \" title=\"Transfer To Another Provider\" onclick='urlTransferPatientToAnotherQueue'></i>".replace("urlTransferPatientToAnotherQueue", actionURL);
            orderedTestsRows += "</td>";
            orderedTestsRows += "</tr>";
            if (element.accessionNumber !== null && (element.fulfillerStatus !== null && element.fulfillerStatus === "IN_PROGRESS")) {
                if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                    referedTests += orderedTestsRows;
                    refferedCounter += 1;
                } else {
                    workListTests += orderedTestsRows;
                    worklistCounter += 1;
                }
            }
        });

        jq("#lab-work-list-table").html("");
        jq("#referred-tests-list-table").html("");

        if (workListTests.length > 0) {
            jq("#lab-work-list-table").append(tableHeader + workListTests + tableFooter);
        } else {
            jq("#lab-work-list-table").append("No Data");
        }

        if (referedTests.length > 0) {
            jq("#referred-tests-list-table").append(tableHeader + referedTests + tableFooter);
        } else {
            jq("#referred-tests-list-table").append("No Data ");
        }

        jq("#lab-work-list-number").html("");
        jq("#lab-work-list-number").append("   " + worklistCounter);
        jq("#referred-tests-number").html("");
        jq("#referred-tests-number").append("   " + refferedCounter);
    }

    function displayLabOrderApproachA(labOrder) {

        var displayDivHeader = "<table> <thead> <tr><th></th> <th>Patient</th><th>Orders</th> </tr> </thead> <tbody>";
        var displayDivFooter = "</tbody></table>"
        var displayWorkListDiv = "";
        var displayReferralListDiv = "";
        var refferedCounter = 0;
        var worklistCounter = 0;

        labOrder.results.forEach((patientencounter, index) => {
            var referedTests = "";
            var workListTests = "";
            var orderWithResult = "";
            var trOpenTag = "<tr data-toggle=\"collapse\" data-target=\"#order" + index + "\" class=\"accordion-toggle\">";
            var tdOpenTag = "<td><i class=\" + icon-eye-open + \"/></td>";
            var tdPatientNames = "<td>" + patientencounter.patient.display + "</td>";
            var tdOrderSummary = "<td>" + patientencounter.orders.length + "</td>";
            var trCloseTag = "</tr>";
            var trCollapsedOpenTag = "<tr> <td colspan=\"12\" class=\"hiddenRow\"><div class=\"accordian-body collapse\" id=\"order" + index + "\">";
            var trCollapsedCloseTag = "</div></td>"

            var tableHeader = "<table><thead><tr><th>SAMPLE ID</th><th>DATE</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";
            var tableFooter = "</tbody></table>";

            jq.each(patientencounter.orders, function (index, element) {
                if(element.fulfillerStatus==="EXCEPTION" || element.dateStopped!==null){
                    return;
                }
                var orderedTestsRows = "";
                var orderedTestsRows = "";
                var instructions = element.instructions;
                var fulfillerComment = element.fulfillerComment;
                var actionIron = "";
                var actionURL = "";
                if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                    actionIron = "icon-tags edit-action";
                    actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.uuid);
                } else {
                    actionIron = "icon-tags edit-action";
                    actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.uuid);
                }
                orderedTestsRows += "<tr>";
                orderedTestsRows += "<td>" + element.accessionNumber + "</td>";
                orderedTestsRows += "<td>" + element.dateActivated + "</td>";
                orderedTestsRows += "<td>" + element.concept.display + "</td>";
                orderedTestsRows += "<td>" + element.fulfillerStatus + "</td>";
                orderedTestsRows += "<td>";
                orderedTestsRows += "<a title=\"Edit Result\" onclick='showEditResultForm(\"" + element.uuid + "\")'><i class=\"icon-list-ul small\"></i></a>";
                orderedTestsRows += "<a  data-toggle=\"modal\" data-target=\"#reject-order-dialog\" data-order-id=\"orderId\"><i style=\"font-size: 25px;\" class=\" icon-remove-sign\" title=\"Reject Order\"></i></a>".replace("orderId", element.uuid);
                orderedTestsRows += "<a  data-toggle=\"modal\" data-target=\"#add-order-to-lab-worklist-dialog\" data-order-number=\"orderNumber\" data-order-id=\"orderId\" data-unprocessed-orders=\"unProcessedOrders\" data-patientqueueid=\"patientQueueId\"><i style=\"font-size: 25px;\" class=\"icon-edit\" title=\"Revise Order\"></i></a>".replace("orderNumber", element.orderNumber).replace("orderId", element.uuid).replace("unProcessedOrders","").replace("patientQueueId","");
                orderedTestsRows += "<i class=\" + actionIron + \" title=\"Transfer To Another Provider\" onclick='urlTransferPatientToAnotherQueue'></i>".replace("urlTransferPatientToAnotherQueue", actionURL);
                orderedTestsRows += "</td>";
                orderedTestsRows += "</tr>";
                if (element.accessionNumber !== null && (element.fulfillerStatus !== null && element.fulfillerStatus === "IN_PROGRESS")) {
                    if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                        referedTests += orderedTestsRows;
                        refferedCounter += 1;
                    } else if (instructions === null && fulfillerComment != null && (fulfillerComment.toLowerCase().indexOf("has results") >= 0 || fulfillerComment.toLowerCase().indexOf("completed with results") >= 0)) {
                        orderWithResult += orderedTestsRows;
                    } else {
                        workListTests += orderedTestsRows;
                        worklistCounter += 1;
                    }
                }
            });
            if (workListTests.length > 0) {
                displayWorkListDiv += trOpenTag + tdOpenTag + tdPatientNames + tdOrderSummary + trCloseTag + trCollapsedOpenTag + tableHeader + workListTests + trCollapsedCloseTag + tableFooter
            }

            if (referedTests.length > 0) {
                displayReferralListDiv += trOpenTag + tdOpenTag + tdPatientNames + tdOrderSummary + trCloseTag + trCollapsedOpenTag + tableHeader + referedTests + trCollapsedCloseTag + tableFooter
            }

        })


        jq("#lab-work-list-table").html("");
        jq("#referred-tests-list-table").html("");

        if (displayWorkListDiv.length > 0) {
            jq("#lab-work-list-table").append(displayDivHeader + displayWorkListDiv + displayDivFooter);
        } else {
            jq("#lab-work-list-table").append("No Data");
        }

        if (displayReferralListDiv.length > 0) {
            jq("#referred-tests-list-table").append(displayDivHeader + displayReferralListDiv + displayDivFooter);
        } else {
            jq("#referred-tests-list-table").append("No Data ");
        }

        jq("#lab-work-list-number").html("");
        jq("#lab-work-list-number").append("   " + worklistCounter);
        jq("#referred-tests-number").html("");
        jq("#referred-tests-number").append("   " + refferedCounter);
    }

    //Sets the Specimen Source Options in the Select in the scheduleTestDialogue
    function setSpecimenSource() {
        jq("#error-specimen-source").html("");
        jq("#specimen_source_id").html("");
        var content = "";
        content += "<option value=\"\">" + "${ui.message("Specimen Source")}" + "</option>";
        <% if (specimenSource.size() > 0) {
                      specimenSource.each { %>
        content += "<option value=\"${it.uuid}\">" + "${it.getName().name}" + "</option>";
        <%} }else {%>
        jq("#error-specimen-source").append("${ui.message("patientqueueing.select.error")}");
        <%}%>
        jq("#specimen_source_id").append(content);
    }

    // Generates Sample ID for the Sample ID Field on the scheduleTestDialogue
    function generateLabNumber(orderUuid) {
        jq.get('${ ui.actionLink("generateLabNumber") }', {
            orderUuid: orderUuid
        }, function (response) {
            if (response) {
                jq(".accession-number").val(JSON.parse(response.defaultSampleId));
                jq("#sample_id").val(JSON.parse(response.defaultSampleId));
            }
        });
    }

    function formatDateFromString(string_date) {
        var date = new Date(string_date);
        var monthNames = [
            "January", "February", "March",
            "April", "May", "June", "July",
            "August", "September", "October",
            "November", "December"
        ];

        var day = date.getDate();
        var monthIndex = date.getMonth();
        var year = date.getFullYear();

        return day + ' ' + monthNames[monthIndex] + ' ' + year;
    }
</script>
${ui.includeFragment("ugandaemr", "lab/displayResultList")}

<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h2 style="color: maroon">${currentLocation.name} - ${ui.message("Queue")}</i></h2>
                    </div>

                    <div>
                        <h2>${currentProvider?.person?.personName?.fullName}</h2>
                    </div>

                    <div class="vertical" style="height: 100%"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-lab-search-form" onsubmit="return false">
                        <div class="row">
                            <div class="col-md-12">
                                <input type="text" id="patient-lab-search" name="patient-lab-search"
                                       placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                                       autocomplete="off" class="provider-dashboard-patient-search"/>
                            </div>
                        </div>

                        <div class="hidden" id="result-search">
                            <div class="row">
                                <div class="col-md-5">
                                    <input type="date" id="asOfDate" name="asOfDate" style="width: 100%;height: 50px;"/>
                                </div>

                                <div class="col-md-5">
                                    <button type="submit" class="confirm" id="search-results"
                                            style="height: 50px; width: 150px">Search</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body hidden-print">
        <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
            <li class="nav-item">
                <a class="nav-item nav-link active" id="pending-queue-lab-tab" data-toggle="tab"
                   href="#pending-queue-lab" role="tab"
                   aria-controls="pending-queue-lab-tab" aria-selected="true">TESTS ORDERED <span style="color:red"
                                                                                                  id="pending-queue-lab-number">0</span>
                    <i class="icon-repeat" style="text-align: right" id="reload_pending" onclick="reloadPending()"></i>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="lab-work-list-tab" data-toggle="tab" href="#lab-work-list" role="tab"
                   aria-controls="lab-work-list-tab" aria-selected="false">WORKLIST
                    <span style="color:red" id="lab-work-list-number">0</span>
                    <i class="icon-repeat" id="reload_worklist" onclick="reloadWorkList()"></i>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="referred-tests-tab" data-toggle="tab" href="#referred-tests" role="tab"
                   aria-controls="referred-tests-tab" aria-selected="false">REFFERED TESTS
                    <span style="color:red" id="referred-tests-number">0</span>
                    <i class="icon-repeat" style="text-align: right" id="reload_referred"
                       onclick="reloadReferred()"></i>
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" id="lab-results-tab" data-toggle="tab" href="#lab-results" role="tab"
                   aria-controls="lab-results-number-tab" aria-selected="false">REVIEW LIST
                    <span style="color:red" id="lab-results-number">0</span>
                    <i class="icon-repeat" style="text-align: right" id="reload_results" onclick="reloadResults()"></i>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="lab-results-approved-tab" data-toggle="tab" href="#lab-results-approved"
                   role="tab"
                   aria-controls="lab-results-approved-number-tab" aria-selected="false">Approved
                    <span style="color:red" id="lab-results-approved-number">0</span>
                    <i class="icon-repeat" style="text-align: right" id="reload_results_approved"
                       onclick="reloadResults()"></i>
                </a>
            </li>
        </ul>

        <div class="tab-content" id="myTabContent">
            <div class="tab-pane fade show active" id="pending-queue-lab" role="tabpanel"
                 aria-pharmacyelledby="pending-queue-lab-tab">
                <div class="info-body">
                    <div id="pending-queue-lab-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="lab-work-list" role="tabpanel"
                 aria-pharmacyelledby="lab-work-list-tab">
                <div class="info-body">
                    <div id="lab-work-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="referred-tests" role="tabpanel"
                 aria-pharmacyelledby="referred-tests-tab">
                <div class="info-body">
                    <div id="referred-tests-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="lab-results" role="tabpanel"
                 aria-pharmacyelledby="lab-results-tab">
                <div class="info-body">
                    <div id="lab-results-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="lab-results-approved" role="tabpanel"
                 aria-pharmacyelledby="lab-results-approved-tab">
                <div class="info-body">
                    <div id="lab-results-approved-list-table">
                    </div>
                </div>
            </div>
        </div>
    </div>
    ${ui.includeFragment("ugandaemr", "pickPatientFromQueue", [provider: currentProvider, currentLocation: currentLocation])}
</div>
${ui.includeFragment("ugandaemr", "reviewResults",[currentLocation: currentLocation])}
${ui.includeFragment("ugandaemr", "lab/rejectTestDialogue")}
${ui.includeFragment("ugandaemr", "lab/resultForm")}
${ui.includeFragment("ugandaemr", "printResults")}
${ui.includeFragment("ugandaemr", "lab/scheduleTestDialogue")}
${ui.includeFragment("ugandaemr", "lab/scheduleBulkTestDialogue")}
</div>
<% } %>




