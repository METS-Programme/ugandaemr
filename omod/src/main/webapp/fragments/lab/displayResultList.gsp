<script>
    function displayLabResult(labQueueList) {
        var referedTests = "";
        var workListTests = "";

        var tableHeader = "<table><thead><tr><th>ORDER NO</th><th>PATIENT NAME</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";

        var tableFooter = "</tbody></table>";
        var resultListCounter=0;

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

            resultListCounter+=1;
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

        var displayDivHeader = "<table> <thead> <tr><th></th> <th>Patient</th><th>Orders</th> </tr> </thead> <tbody>";
        var displayDivFooter = "</tbody></table>"
        var displayWorkListDiv = "";
        var displayReferralListDiv = "";
        var resultListCounter=0;

        labOrder.ordersList.forEach((patientencounter, index) => {
            var referedTests = "";
            var trOpenTag = "<tr data-toggle=\"collapse\" data-target=\"#orderresult" + index + "\" class=\"accordion-toggle\">";
            var tdOpenTag = "<td><i class=\" + icon-eye-open + \"/></td>";
            var tdPatientNames = "<td>" + patientencounter.patient + "</td>";
            var tdOrderSummary = "<td>" + patientencounter.orders.length + "</td>";
            var trCloseTag = "</tr>";
            var trCollapsedOpenTag = "<tr> <td colspan=\"12\" class=\"hiddenRow\"><div class=\"accordian-body collapse\" id=\"orderresult" + index + "\">";
            var trCollapsedCloseTag = "</div></td>"

            var tableHeader = "<table><thead><tr><th>ORDER NO</th><th>TEST</th><th>STATUS</th><th>ACTION</th></tr></thead><tbody>";
            var tableFooter = "</tbody></table>";

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
                orderedTestsRows += "<a title=\"Edit Result\" onclick='showEditResultForm(" + element.orderId + ")'><i class=\"icon-list-ul small\"></i></a>";
                orderedTestsRows += "<a title=\"Print Results\" onclick='printresult(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-print small\"></i></a>";
                orderedTestsRows += "<a title=\"Review Results\" onclick='reviewresults(" + element.orderId + "," + element.patientId + ")'><i class=\"icon-print small\"></i></a>";
                orderedTestsRows += "</td>";
                orderedTestsRows += "</tr>";
                referedTests += orderedTestsRows;

                resultListCounter+=1;
            });

            if (referedTests.length > 0) {
                displayReferralListDiv += trOpenTag + tdOpenTag + tdPatientNames + tdOrderSummary + trCloseTag + trCollapsedOpenTag + tableHeader + referedTests + trCollapsedCloseTag + tableFooter
            }
        })

        jq("#lab-results-list-table").html("");
        if (displayReferralListDiv.length > 0) {
            jq("#lab-results-list-table").append(displayDivHeader + displayReferralListDiv + displayDivFooter);
        } else {
            jq("#lab-results-list-table").append("No Data ");
        }

        jq("#lab-results-number").html("");
        jq("#lab-results-number").append("   " + resultListCounter);
    }
</script>