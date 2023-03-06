<style>
.lab-button{
    background: none;
    border: none;
    text-align: left;
    min-width: 100%;
}
.accordion>.card .card-header {
    margin-bottom: -0.74px;
}
.card {
    margin-bottom: 0px;
}
.card-header {
    padding: 0px 0px;
    margin-bottom: 0;
    background-color: rgba(0,0,0,.03);
    border-bottom: 0px solid rgba(0,0,0,.125);
}
</style>
<script>
    jq(document).ready(function () {
        getResults();
    });

    function getResults() {
        jq.get('${ ui.actionLink("ugandaemr","displayLabResults","getOrderWithResult") }', {
            patientId: ${patientId}
        }, function (response) {
            if (response.trim() !== "{}") {
                var responseData = JSON.parse(response.replace("ordersList=", "\"ordersList\":").trim());
                displayLabResult(responseData)
            }
        });
    }

    function displayLabResult(labQueueList) {
        jq.each(labQueueList.ordersList, function (index, element) {
            printresult(element.orderId, element.patientId);
        });
    }
</script>

<script>
    var _results = {'_items': ko.observableArray([])};
    var printResults = {'items': ko.observableArray([])};

    jq(document).ready(function () {
        ko.applyBindings(_results, jq("#patient-report")[0]);
    });

    function organize(data) {
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
            testId: testId,
            async: false
        }, function (response) {
            if (response) {
                var responseData = JSON.parse(response.replace("data=", "\"data\":").trim());
                organize(responseData.data);
            } else if (!response) {
            }
        });
    }
</script>

<div class="info-section patientsummary">
    <div class="info-header">
        <i class=" icon-user-md"></i>

        <h3>Lab Results</h3>
    </div>

    <div class="info-body">
        <div class="" id="lab-results">
            <table style="table-layout: fixed; margin-top: 5px;">
                <thead>
                <tr>
                    <th width="50%" style="text-align: left">Test</th>
                    <th width="15%" style="text-align: left">Result</th>
                </tr>
                </thead>
                <tbody></tbody>
            </table>
            <table id="patient-report" style="margin-top: 5px; table-layout: fixed;">
                <tbody data-bind="foreach: _items">
                <tr>
                    <td data-bind="foreach: sets">
                        <div class="accordion" id="accordionExample">
                            <div class="card">
                                <div class="card-header" id="headingOne">
                                    <h5 class="mb-0">
                                        <button class="btn btn-link lab-button" type="button" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                           <span data-bind="text: name">
                                        </button>
                                    </h5>
                                </div>

                                <div id="collapseOne" class="collapse hide" aria-labelledby="headingOne" data-parent="#accordionExample">
                                    <div class="card-body">
                                        <table style="table-layout:fixed;">
                                            <tbody data-bind="foreach: data">
                                            <td width="50%" data-bind="text: '' + test" style="text-align: left"></td>
                                            <td width="15%" data-bind="text: value" style="text-align: left"></td>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

