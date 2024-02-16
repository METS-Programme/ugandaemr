<script>
    jq(function () {
        jq('#date').datepicker("option", "dateFormat", "dd/mm/yy");
    });

    var editScheduleBulkDialog,
        editScheduleBulkForm,
        editScheduleBulkParameterOpts = {editScheduleBulkParameterOptions: ko.observableArray([])};

    jq(function () {
        ko.applyBindings(editScheduleBulkParameterOpts, jq("#edit-schedule-bulk-form")[0]);

        editScheduleBulkDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#edit-schedule-bulk-form',
            actions: {
                confirm: function () {
                    saveEditBulkOrders();
                    editScheduleBulkDialog.close();
                    window.location.reload();
                },
                cancel: function () {
                    editScheduleBulkDialog.close();
                }
            }
        });

        editScheduleBulkForm = jq("#edit-schedule-bulk-form").find("form").on("submit", function (event) {
            event.preventDefault();
            saveEditBulkOrders();
        });
    });

    function getEditScheduleBulkTempLate(orders) {

        jq("#lab_number_generator").html("");

        jq("#lab_number_generator").append("<a onclick=\"generateLabNumber('" + orders[0].uuid + "')\"><i class=\" icon-barcode\">Generate Lab Number</i></a>");

        editScheduleBulkParameterOpts.editScheduleBulkParameterOptions.removeAll();

        var specimen = getSpecimeSources();

        var referralLabs = {
            "options": [
                {
                    "value": "",
                    "text": "Select Reference Lab"
                },
                {
                    "value": "cphl",
                    "text": "CPHL"
                },
                {
                    "value": "uvri",
                    "text": "UVRI"
                },
                {
                    "value": "uvri",
                    "text": "Other health center Lab"
                },
                {
                    "value": "other-systems",
                    "text": "Other Lab Systems"
                }
            ]
        }

        jq.each(orders, function (index, editScheduleBulkParameterOption) {
            Object.defineProperty(editScheduleBulkParameterOption, "specimenSource", {
                value: specimen,
                writable: false
            })

            Object.defineProperty(editScheduleBulkParameterOption, "referenceLab", {
                value: referralLabs,
                writable: false
            })

            if (editScheduleBulkParameterOption.instructions != null) {
                editScheduleBulkParameterOption.instructions = editScheduleBulkParameterOption.instructions.replace("REFER TO ", "")
            }

            editScheduleBulkParameterOpts.editScheduleBulkParameterOptions.push(editScheduleBulkParameterOption);
        });

        editScheduleBulkDialog.show();
        jq(".col-6").each(function () {
            if (jq(this).html() === "") {
                jq(this).addClass("hidden");
            } else {
                jq(this).remove("hidden");
            }
        });

    }

    function getSpecimeSources() {
        var specimenSourceList = [];
        var specimenSource = "";

        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/systemsetting?q=order.testSpecimenSourcesConceptUuid&v=full",
            dataType: "json",
            contentType: "application/json;",
            async: false,
            success: function (response) {
                if (response) {
                    specimenSource = response.results[0].value;
                }
            }
        }).error(function (data, status, err) {
            jq().toastmessage('showErrorToast', err);
        });


        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/concept/" + specimenSource + "?v=full",
            dataType: "json",
            contentType: "application/json;",
            async: false,
            success: function (response) {
                if (response) {
                    specimenSourceList = response.setMembers;
                }
            }
        }).error(function (data, status, err) {
            jq().toastmessage('showErrorToast', err);
        });

        return specimenSourceList;

    }

    function saveEditBulkOrders() {
        var dataString = editScheduleBulkForm.serialize();
        jq.ajax({
            type: "POST",
            url: '${ui.actionLink("ugandaemr", "labQueueList", "scheduleTestOrderBulk")}',
            data: dataString,
            dataType: "json",
            success: function (data) {
                if (data.status === "success") {
                    jq().toastmessage('showSuccessToast', data.message);
                    editScheduleBulkDialog.close();
                } else {
                    jq().toastmessage('showErrorToast', data.error);
                }
            }
        });
    }

    function Result() {
        self = this;
        self.items = ko.observableArray([]);
    }

    var result = new Result();
</script>
<style>
form .lablex {
    width: 93%;
}

form .lablex span {
    float: left;
    margin: 1px 0px;
}

form .lablex2 span {
    min-width: 50%;
    float: left;
    margin: 1px 0px;
}

form .lablex3 span {
    min-width: 30%;
    float: left;
    margin: 1px 0px;
}

form .lablex4 span {
    min-width: 25%;
    float: left;
    margin: 1px 0px;
}

form .lablex5 span {
    min-width: 20%;
    float: left;
    margin: 1px 0px;
}

form .lablex3 {
}

form .lablex3 span {
    min-width: 70%;
    float: left;
    margin: 1px 0px;
}

form input {
    min-width: 47%;
}

.div-table {
    display: table;
    width: 100%;
    background-color: #fff;
}

.box {
    display: flex;
    flex-wrap: wrap;
}

.box > * {
    flex: 1 1 160px;
}

.dialog {
    width: 100%;
}

.dialog .dialog-content {
    padding: 0px 19px 0 19px;
}

.dialog .dialog-header {
    background: #151414;
}

.modal-dialog {
    max-width: 55%;
    margin: 1.75rem auto;
}
</style>

<div id="edit-schedule-bulk-form" title="Results" class="modal fade bd-order-modal-lg" style="">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h3 style="color: #FFFFFF">${ui.message("Schedule Patient Tests")}</h3>
            </div>

            <div class="modal-body">
                <div class="row">
                    <div class="col-12">
                        <div id="lab_number_generator"></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <form>
                            <table>
                                <thead>
                                <th>Test</th>
                                <th>Lab Number/Specimen Id</th>
                                <th>Specimen Source</th>
                                <th>Referral Lab</th>

                                </thead>
                                <tbody class="container" data-bind="foreach: editScheduleBulkParameterOptions">
                                <td><label data-bind="text: concept.display"></label>
                                    <input type="hidden"
                                           data-bind="attr: { 'name' : 'wrap.testOrderMappers[' + \$index() + '].orderId' }, value: uuid">
                                </td>
                                <td>
                                    <input class="accession-number"
                                           data-bind="attr : { 'type' : 'text', 'name' : 'wrap.testOrderMappers[' + \$index() + '].accessionNumber', value : accessionNumber }">
                                </td>
                                <td>
                                    <select class="specimen-source"
                                            data-bind="attr : { 'name' : 'wrap.testOrderMappers[' + \$index() + '].specimenSourceId'}, options: specimenSource, optionsText: function(item) { return item.name.display}, optionsValue:function(item) { return item.uuid},value: specimenSource.selectedSpecimenSource, optionsCaption: 'Select Specimen Source'">
                                </td>
                                <td>
                                    <select class="instructions"
                                            data-bind="attr : { 'name' : 'wrap.testOrderMappers[' + \$index() + '].instructions'}, options: referenceLab.options, optionsText: function(item) { return item.text}, optionsValue:function(item) { return item.value},value: referenceLab.selectedReferralLab, optionsCaption: 'Select Referral Lab'">
                                </td>
                                </tbody>
                            </table>
                        </form>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button class="cancel" data-dismiss="modal"
                        id="">${ui.message("patientqueueing.close.label")}</button>
                <span class="button confirm right">Save Results</span>
            </div>
        </div>
    </div>
</div>






