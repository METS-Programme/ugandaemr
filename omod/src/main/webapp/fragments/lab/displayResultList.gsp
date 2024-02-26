<script>
    function displayLabResult(labQueueList) {
        var referedTests = "";
        var workListTests = "";

        var tableHeader = "<table><thead><tr><th>ORDER NO</th><th>PATIENT NAME</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";

        var tableFooter = "</tbody></table>";
        var resultListCounter = 0;

        jq.each(labQueueList.ordersList, function (index, element) {
            var orderedTestsRows = "";
            var instructions = element.instructions;
            var actionIron = "";
            var actionURL = "";
            if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                actionIron = "icon-tags edit-action";
                actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.orderId);
            } else {
                actionIron = "icon-tags edit-action";
                actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.orderId);
            }
            orderedTestsRows += "<tr>";
            orderedTestsRows += "<td>" + element.orderNumber + "</td>";
            orderedTestsRows += "<td>" + element.patient + "</td>";
            orderedTestsRows += "<td>" + element.conceptName + "</td>";
            orderedTestsRows += "<td>" + element.status + "</td>";
            orderedTestsRows += "<td>";
            orderedTestsRows += "<a title=\"Edit Result\" onclick='showEditResultForm(" + element.orderId + ")'><i class=\"icon-list-ul small\"></i></a>";
            orderedTestsRows += "<a title=\"Print Results\" onclick='printresult(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-print small\"></i></a>";
            orderedTestsRows += "<a title=\"Review Results\" onclick='reviewresults(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-print small\"></i></a>";
            orderedTestsRows += "</td>";
            orderedTestsRows += "</tr>";
            referedTests += orderedTestsRows;

            resultListCounter += 1;
        });

        jq('#review-lab-test-dialog').on('show.bs.modal', function (event) {
            var button = jq(event.relatedTarget);
            var orderId = button.data('order-id');
            var patientId = button.data('patient-id');
            reviewResult(orderId, patientId);

        });

        jq("#lab-results-list-table").html("");
        if (referedTests.length > 0) {
            jq("#lab-results-list-table").append(tableHeader + referedTests + tableFooter);
        } else {
            jq("#lab-results-list-table").append("No Data ");
        }

        jq("#lab-results-number").html("");
        jq("#lab-results-number").append("   " + resultListCounter);
    }


    function displayLabOrderApproachB(labOrder) {

        var displayDivHeader = "<table> <thead> <tr><th></th> <th>Patient</th><th>Orders</th><th>Date</th><th>Action</th> </tr> </thead> <tbody>";
        var displayDivFooter = "</tbody></table>"
        var displayApprovedListDiv = "";
        var displayReviewListDiv = "";
        var resultApprovedListCounter = 0;
        var resultReviewListCounter = 0;

        labOrder.ordersList.forEach((patientencounter, index) => {
            var reviewResultTestList = "";
            var approvedResultTestList = "";
            var trOpenTag = "<tr data-toggle=\"collapse\" data-target=\"#orderresult" + index + "\" class=\"accordion-toggle\">";
            var tdOpenTag = "<td><i class=\" + icon-eye-open + \"/></td>";
            var tdPatientNames = "<td>" + patientencounter.patient + "</td>";
            var tdOrderSummary = "<td>" + patientencounter.orders.length + "</td>";
            var tdOrderDate = "<td>" + formatDateFromString(patientencounter.orders[0].dateActivated) + "</td>";
            var tdLabResultPrint = "<td><a title=\"Print Results\" onclick='printresult(" + patientencounter.orders[0].orderId + "," + patientencounter.orders[0].patientId + ")'><i class=\"icon-print small\"></i></a></td>";
            var tdLabResultReview = "<td><a title=\"Review Results\" onclick='reviewResult(" + patientencounter.orders[0].orderId + "," + patientencounter.orders[0].patientId + ")'><i class=\"icon-check small\"></i></a></td>";
            var trCloseTag = "</tr>";
            var trCollapsedOpenTag = "<tr> <td colspan=\"12\" class=\"hiddenRow\"><div class=\"accordian-body collapse\" id=\"orderresult" + index + "\">";
            var trCollapsedCloseTag = "</div></td>"

            var tableHeader = "<table><thead><tr><th>ORDER NO</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";
            var tableFooter = "</tbody></table>";
            var approvedResultsListCounter = 0;
            var reviewResultsListCounter = 0;

            jq.each(patientencounter.orders, function (index, element) {

                var orderedTestsRows = "";
                var instructions = element.instructions;
                var actionIron = "";
                var actionURL = "";
                if (instructions != null && instructions.toLowerCase().indexOf("refer to") >= 0) {
                    actionIron = "icon-tags edit-action";
                    actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.orderId);
                } else {
                    actionIron = "icon-tags edit-action";
                    actionURL = 'patientqueue.showAddOrderToLabWorkLIstDialog("patientIdElement")'.replace("patientIdElement", element.orderId);
                }
                orderedTestsRows += "<tr>";
                orderedTestsRows += "<td>" + element.orderNumber + "</td>";
                orderedTestsRows += "<td>" + element.conceptName + "</td>";
                orderedTestsRows += "<td>" + element.status + "</td>";
                orderedTestsRows += "<td>";
                if (element.fulfillerStatus === "IN_PROGRESS") {
                    orderedTestsRows += "<a title=\"Edit Result\" onclick='showEditResultForm(" + element.orderId + ")'><i class=\"icon-list-ul small\"></i></a>";
                    orderedTestsRows += "<a title=\"Review Results\" onclick='reviewResult(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-check small\"></i></a>";
                }else if(element.fulfillerStatus === "COMPLETED") {
                    orderedTestsRows += "<a title=\"Print Results\" onclick='printresult(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-print small\"></i></a>";
                }
                orderedTestsRows += "</td>";
                orderedTestsRows += "</tr>";
                if (element.fulfillerStatus === "IN_PROGRESS") {
                    reviewResultTestList += orderedTestsRows;
                    reviewResultsListCounter += 1;
                    resultReviewListCounter += 1;
                } else if (element.fulfillerStatus === "COMPLETED") {
                    approvedResultTestList += orderedTestsRows;
                    approvedResultsListCounter += 1;
                    resultApprovedListCounter += 1;
                }


            });

            if (reviewResultTestList.length > 0) {
                displayReviewListDiv += trOpenTag + tdOpenTag + tdPatientNames + tdOrderSummary +tdOrderDate+ tdLabResultReview + trCloseTag + trCollapsedOpenTag + tableHeader + reviewResultTestList + trCollapsedCloseTag + tableFooter
            }

            if (approvedResultTestList.length > 0) {
                displayApprovedListDiv += trOpenTag + tdOpenTag + tdPatientNames + tdOrderSummary +tdOrderDate+ tdLabResultPrint + trCloseTag + trCollapsedOpenTag + tableHeader + approvedResultTestList + trCollapsedCloseTag + tableFooter
            }
        })

        jq("#lab-results-list-table").html("");
        jq("#lab-results-approved-list-table").html("");
        if (displayReviewListDiv.length > 0) {
            jq("#lab-results-list-table").append(displayDivHeader + displayReviewListDiv + displayDivFooter);
        } else {
            jq("#lab-results-list-table").append("No Data ");
        }

        if (displayApprovedListDiv.length > 0) {
            jq("#lab-results-approved-list-table").append(displayDivHeader + displayApprovedListDiv + displayDivFooter);
        } else {
            jq("#lab-results-approved-list-table").append("No Data ");
        }

        jq("#lab-results-number").html("");
        jq("#lab-results-approved-number").html("");
        jq("#lab-results-number").append("   " + resultReviewListCounter);
        jq("#lab-results-approved-number").append("   " + resultApprovedListCounter);
    }
</script>