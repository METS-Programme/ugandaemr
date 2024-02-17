<%
    ui.includeFragment("appui", "standardEmrIncludes")
    ui.includeCss("referenceapplication", "login.css")
    ui.includeCss("appui", "bootstrap.min.css")
    ui.includeCss("appui", "bootstrap.min.js")
%>
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

        printDiv("printSection");
    }

    function organizePatient(order) {
        jq("#patient-name").text("");
        jq("#patient-dob").text("");
        jq("#patient-gender").text("");
        jq("#patient-identifier").text("");
        jq("#requester").text("");
        jq("#request-date").text("");
        jq("#review-date").text("");


        var patientOrder = getOpenMRSObject(order, "order");
        var patient = null;
        var provider = null;
        if (patientOrder !== null) {
            patient = getOpenMRSObject(patientOrder.patient.uuid, "patient");
            provider = getOpenMRSObject(patientOrder.orderer.uuid, "provider");
        }

        jq("#patient-name").text(patient.person.display);
        jq("#patient-dob").text(formatDateFromString(patient.person.birthdate));
        jq("#patient-gender").text(patient.person.gender);
        jq("#patient-identifier").append(displayIdentifier(patient));

        jq("#requester").text(provider.person.display);
        jq("#request-date").text(formatDateFromString(patientOrder.dateActivated));

        jq("#review-date").text(formatDateFromString(new Date()));

    }

    function displayIdentifier(patient) {
        var identifiers = "";
        if (patient && patient.identifiers && patient.identifiers.length > 0) {
            patient.identifiers.forEach(function (identifier) {
                if (identifier.identifierType.uuid == "877169c4-92c6-4cc9-bf45-1ab95faea242" || identifier.identifierType.uuid == "e1731641-30ab-102d-86b0-7a5022ba4115") {
                    identifiers += "<span style='font-weight: bold'>" + identifier.identifierType.display + "  </span> : <span> " + identifier.identifier + "</span><br/>";
                }
            });
            return identifiers;
        }
    }

    function printresult(testId, patientId) {
        jq.get('${ ui.actionLink("getResults") }', {
            patientId: patientId,
            testId: testId
        }, function (response) {
            if (response) {
                organizePatient(JSON.parse(response.order));
                organize(JSON.parse(response.data));
            } else if (!response) {
            }
        });
    }

    function getOpenMRSObject(uuid, object) {
        var openmrsobject = null;
        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/" + object + "/" + uuid + "?v=full",
            dataType: "json",
            contentType: "application/json;",
            async: false,
            success: function (response) {
                if (response) {
                    openmrsobject = response;
                }
            }
        });

        return openmrsobject
    }

    function printDiv(divIdToPrint) {
        var printContent = document.getElementById(divIdToPrint).innerHTML;
        var originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
    }

    jq(function () {
        jq('#date').datepicker("option", "dateFormat", "dd/mm/yy");
    });

</script>
<style>
.print-only {
    display: none;
}

.logoimage-print {
    height: 50px;
    width: 50px;
    background: whitesmoke;
    padding: 5px;
    border-radius: 80%;
}

.healthcentrename-print {
    font-size: 25px;
}

.patient_name_print {
    font-size: 25px;
    font-weight: 400;
    line-height: 1.4;
    letter-spacing: 0;
    margin-right: 0.25rem;
}

.patient-other-identifier {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: baseline;
}

.patient-other-details {
    font-size: 1rem;
    font-weight: 400;
    line-height: 1.375;
    letter-spacing: 0;
    color: #525252;
    margin-top: 0.375rem;
}
</style>

<div id="printSection" class="print-only">
    <div class="row">
        <div class="col-sm-3">
            <div class="row">
                <div class="headerimage col-sm-12">
                    <div class="row">
                        <table style="border: none">
                            <tr style="border-color: transparent; border-width: 0">
                                <td style="border-color: transparent; border-width: 0; width: 27%">
                                    <img src="${ui.resourceLink("ugandaemr", "images/moh_logo_without_word.png")}"
                                         width="50" height="50" class="logoimage-print"/>
                                </td>
                                <td style="border-color: transparent; border-width: 0">
                                    <div class="row">
                                        <span class="facility-code">Code: 1115558</span>
                                    </div>

                                    <div class="row">
                                        <span class="facility-code">District: Kampala</span>
                                    </div>
                                </td>
                            </tr>
                            <tr style="border-color: transparent; border-width: 0">
                                <td colspan="2" style="border-color: transparent; border-width: 0;">
                                    <div class="healthcentrename-print">${healthCenter}</div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-sm-5">
            <div class="row">
                <div class="headerimage col-sm-12">
                    <div class="row">
                        <span class="patient_name_print" id="patient-name"
                              style="font-size: 25px; font-weight: bolder; line-height:  1.4; letter-spacing:  0; margin-right: 0.25rem;"></span>&nbsp; &nbsp; &nbsp;
                        <span class="patient-other-details"
                              style="font-size:  1rem; font-weight:  400; line-height:  1.375; letter-spacing:  0; color: #525252; margin-top: 0.375rem;">
                            <span id="patient-gender"></span> ·<span id="patient-dob"></span>
                        </span>
                    </div>

                    <div class="row">
                        <div class="patient-other-identifier"
                             style="display: flex; flex-direction: row; justify-content: space-between; align-items: baseline;">
                            <span class="-esm-patient-banner__patient-banner__identifierTag___DGuqK"
                                  id="patient-identifier">
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-sm-4">
            <div class="row">
                <div class="headerimage col-sm-12">
                    <div class="row">
                        <div style="font-size:  1rem; font-weight:  400; line-height:  1.375; letter-spacing:  0; color: #525252; margin-top: 0.375rem;">
                            <span style="font-weight: bolder">Requested By:</span> <span id="requester"></span>
                        </div>
                    </div>

                    <div class="row">
                        <div style="font-size:  1rem; font-weight:  400; line-height:  1.375; letter-spacing:  0; color: #525252; margin-top: 0.375rem;">
                            <span style="font-weight: bolder">Date Requested:</span> <span id="request-date"></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card" id="patient-report" style="margin-top: 5px; table-layout: fixed;">
        <table style="width: 100%">
            <thead style="width: 100%">
            <th style="width: 25%">Test</th>
            <th style="width: 25%">Result</th>
            <th style="width: 25%">Reference Range</th>
            <th style="width: 25%">Units</th>
            </thead>
        </table>

        <div class="card-body" data-bind="foreach: _items">
            <div class="row">
                <div class="col-md-12" data-bind="foreach: sets">
                    <div class="card" style="table-layout:fixed;">
                        <div class="card-header">
                            <label data-bind="text: name" style="text-align: left; font-weight: bold"></label>
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

    <div class="provider-information">
        <div class="row">
            <div class="col-sm-4" style="font-weight: bold">Results Reviewed/Authorized by:</div>
            <div class="col-sm-6" id="reviewer-name">${currentProvider?.person?.personName?.fullName}</div>
        </div>
        <br/><br/>
        <div class="row">
            <div class="col-sm-4" style="font-weight: bold">Sign: ..........................................</div>
            <div class="col-sm-1" style="font-weight: bold">Date: </div><div class="col-sm-3" id="review-date"></div>
        </div>

    </div>
</div>