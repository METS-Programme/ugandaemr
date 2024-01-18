<script>
    jq(document).ready(function () {
        getResults();
    });

    function getResults() {
        jq.get('${ ui.actionLink("ugandaemr","displayResultListOnEncounter","getOrderWithResultForEncounter") }', {
            encounterId: ${encounterId}
        }, function (response) {
            if (response.trim() !== "{}") {
                var responseData = JSON.parse(response.replace("ordersList=", "\"ordersList\":").replace("order=", "\"order\":").trim());
                displayLabResult(responseData)
            }
        });
    }

    function displayLabResult(labQueueList) {
        printresult(labQueueList.ordersList[0].orderId, labQueueList.ordersList[0].patientId);
    }
</script>

<script>
    var _results = {'_items': ko.observableArray([])};
    var printResults = {'items': ko.observableArray([])};

    jq(document).ready(function () {
        ko.applyBindings(_results, jq("#patient-report")[0]);
    });

    function organize(data) {
        data.filter(function (d) {
            if(["Numeric", "Coded", "Text","N/A"].includes(d["set"])){
                return d["set"]=d["test"];
            }
        })
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
                _obj['data'] = wanted;
                obj['sets'].push(_obj);
            });
            final.push(obj);
        });

        console.log(final);
        final.forEach(function (o) {
            _results._items.push(o);
        });
    }

    function printresult(testId, patientId) {
        jq.get('${ ui.actionLink("ugandaemr","printResults","getResults") }', {
            patientId: patientId,
            testId: testId
        }, function (response) {
            if (response) {
                var responseData = JSON.parse(response.replace("data=", "\"data\":").replace("order=", "\"order\":").trim());
                organize(responseData.data);
            } else if (!response) {
            }
        });
    }
</script>
<section sectionTag="section" id="lab-results-tab" headerTag="h1">
    <div class="card" id="patient-report" style="margin-top: 5px; table-layout: fixed;">
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
                                <label class="form-check-label" style="font-weight: bold" data-bind="attr : { 'for' : data[0].testId}"><span data-bind="text: name"></span></label>
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
</section>

