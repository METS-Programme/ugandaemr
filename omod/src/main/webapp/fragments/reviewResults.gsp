<script>
    var _reviewresults = {'_items': ko.observableArray([])};
    var reviewResults = {'items': ko.observableArray([])};

    jq(document).ready(function () {
        ko.applyBindings(_reviewresults, jq("#patient-review-report")[0]);

        jq("#approve-results").click(function () {
            var selectedForApproval = new Array();
            jq("#patient-review-report").find("input[type='checkbox']:checked").each(function () {
                selectedForApproval.push(jq(this).val());
            });

            var dataToPost = "{\"orders\":\"" + selectedForApproval + "\"}";

            jq.ajax({
                type: "POST",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/approveorder",
                dataType: "json",
                contentType: "application/json;",
                data: dataToPost,
                async: false,
                success: function (response) {
                    serverResponse = response.results;
                    navigateToURL(jq("#goToURL").val())

                },
                error: function (response) {
                    console.log(response.responseJSON.error.message);
                }
            });
        });
    });

    function organiseLabTest(data) {
        var final = [];
        var investigations = data.map(function (d) {
            return d['investigation'];
        });
        investigations = Array.from(new Set(investigations));

        investigations.forEach(function (investigation) {
            var obj = new Object();
            obj['investigation'] = investigation;

            var sets = data.filter(function (d) {
                return d['investigation'] == investigation;
            });
            sets = sets.map(function (d) {
                return d['set'];
            });
            sets = Array.from(new Set(sets));
            obj['sets'] = [];

            sets.forEach(function (set) {
                var _obj = new Object();
                _obj['name'] = set;
                var wanted = data.filter(function (d) {
                    return d['investigation'] == investigation && d['set'] == set;
                });
                _obj['testId'] = wanted[0].testId;
                _obj['data'] = wanted;
                obj['sets'].push(_obj);
            });
            final.push(obj);
        });

        console.log(final);
        final.forEach(function (o) {
            _reviewresults._items.push(o);
        });

        jq('#review-lab-test-dialog').modal("show");
    }

    function getPatientDetails(order) {
        jq("#patient-name-review").text("");
        jq("#patient-identifier").text("");

        var patientOrder = getOpenMRSObject(order, "order");
        var patient = null;
        var provider = null;
        if (patientOrder !== null) {
            patient = getOpenMRSObject(patientOrder.patient.uuid, "patient");
            provider = getOpenMRSObject(patientOrder.orderer.uuid, "provider");
        }
        jq("#patient-name-review").text(patient.person.display);
        jq("#patient-identifier").append(displayIdentifier(patient));
    }

    function reviewResult(testId, patientId) {
        jq.get('${ ui.actionLink("getResults") }', {
            patientId: patientId,
            testId: testId
        }, function (response) {
            if (response) {
                var responseData = JSON.parse(response.replace("data=", "\"data\":").replace("order=", "\"order\":").trim());
                getPatientDetails(responseData.order);
                organiseLabTest(responseData.data);
            } else if (!response) {
            }
        });
    }


    jq(function () {
        jq('#date').datepicker("option", "dateFormat", "dd/mm/yy");
    });

</script>
<style>
h2 {
    color: #FFFFFB;
}
</style>

<div class="modal fade" id="review-lab-test-dialog" tabindex="-1" role="dialog"
     aria-labelledby="reviewLabTestModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Review Lab Report for <span id="patient-name-review"></span>&nbsp;&nbsp;<span
                        id="patient-identifier"></span></h2>
            </div>

            <form>
                <div class="modal-body">

                    <div class="card" id="patient-review-report" style="margin-top: 5px; table-layout: fixed;">
                        <table style="width: 100%">
                            <thead style="width: 100%">
                            <th style="width: 25%">Test</th>
                            <th style="width: 25%">Result</th>
                            <th style="width: 25%">Reference Range</th>
                            <th style="width: 20%">Units</th>
                            </thead>
                        </table>

                        <div class="card-body" data-bind="foreach: _items">
                            <div class="row">
                                <div class="col-md-12" data-bind="foreach: sets">
                                    <div class="card" style="table-layout:fixed;">
                                        <div class="card-header">
                                            <div class="form-check">
                                                <input type="checkbox" class="form-check-input  orders-to-approve"
                                                       name="orders-to-approve"
                                                       data-bind="attr : {'value' : data[0].testId,'id': data[0].testId }">
                                                <label class="form-check-label" style="font-weight: bold"
                                                       data-bind="attr : { 'for' : data[0].testId}"><span
                                                        data-bind="text: name"></span></label>
                                            </div>

                                        </div>
                                        <table data-bind="foreach: data" style="width: 100%">
                                            <tr style="width: 100%">
                                                <td data-bind="text: '' + test" style="width: 25%"></td>
                                                <td data-bind="text: value" style="width: 25%"></td>
                                                <td style="width: 25%">
                                                    <div data-bind="if: (lowNormal || hiNormal)">
                                                        <span data-bind="text: 'Normal:&nbsp;&nbsp;' + lowNormal + ' - ' + hiNormal"></span>
                                                    </div>

                                                    <div data-bind="if: (lowCritical || lowCritical)">
                                                        <span data-bind="text: 'Critical:&nbsp;&nbsp;' + lowCritical + ' - ' + hiCritical"></span>
                                                    </div>

                                                    <div data-bind="if: (lowAbsolute || hiAbsolute)">
                                                        <span data-bind="text: 'Absolute:&nbsp;&nbsp;' + lowAbsolute + ' - ' + hiAbsolute"></span>
                                                    </div>
                                                </td>
                                                <td data-bind="text: unit" style="width: 25%"></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="modal-footer">
                    <button type="button" class="cancel" data-dismiss="modal">Cancel</button>
                    <button type="button" class="confirm" id="approve-results">Approve</button>
                </div>
            </form>
        </div>
    </div>
</div>