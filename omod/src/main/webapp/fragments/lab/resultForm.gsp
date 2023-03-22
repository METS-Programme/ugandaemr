<script>
    jq(function () {
        jq('#date').datepicker("option", "dateFormat", "dd/mm/yy");
    });

    var editResultsDialog,
        editResultsForm,
        editResultsParameterOpts = {editResultsParameterOptions: ko.observableArray([])};

    jq(function () {
        ko.applyBindings(editResultsParameterOpts, jq("#edit-result-form")[0]);

        editResultsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#edit-result-form',
            actions: {
                confirm: function () {
                    saveEditResult();
                    editResultsDialog.close();
                    window.location.reload();
                },
                cancel: function () {
                    editResultsDialog.close();
                }
            }
        });

        editResultsForm = jq("#edit-result-form").find("form").on("submit", function (event) {
            event.preventDefault();
            saveEditResult();
        });
    });

    function showEditResultForm(testId) {
        getEditResultTempLate(testId);
        editResultsForm.find("#edit-result-id").val(testId);

    }

    function getEditResultTempLate(testId) {
        jq.getJSON('${ui.actionLink("ugandaemr", "labQueueList", "getResultTemplate")}',
            {"testId": testId}
        ).success(function (editResultsParameterOptions) {
            editResultsParameterOpts.editResultsParameterOptions.removeAll();
            var details = ko.utils.arrayFirst(result.items(), function (item) {
                return item.testId == testId;
            });
            jq.each(editResultsParameterOptions, function (index, editResultsParameterOption) {
                if (editResultsParameterOption.options.length > 0) {
                    editResultsParameterOption.options.splice(0, 0, {"label": "- SELECT RESULT -", "value": ""})
                }
                editResultsParameterOpts.editResultsParameterOptions.push(editResultsParameterOption);
            });

            editResultsDialog.show();

            jq(".col-6").each(function () {
                if (jq(this).html()==="") {
                   jq(this).addClass("hidden");
                } else {
                    jq(this).remove("hidden");
                }
            });
        });
    }

    function saveEditResult() {
        var dataString = editResultsForm.serialize();
        jq.ajax({
            type: "POST",
            url: '${ui.actionLink("ugandaemr", "labQueueList", "saveResult")}',
            data: dataString,
            dataType: "json",
            success: function (data) {
                if (data.status === "success") {
                    jq().toastmessage('showSuccessToast', data.message);
                    editResultsDialog.close();
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

<div id="edit-result-form" title="Results" class="modal fade bd-order-modal-lg" style="">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h3 style="color: #FFFFFF">${ui.message("Edit Results")}</h3>
            </div>

            <div class="modal-body">
                <form>
                    <input type="hidden" name="wrap.testId" id="edit-result-id"/>

                    <div class="row" data-bind="foreach: editResultsParameterOptions">
                        <input type="hidden"
                               data-bind="attr: { 'name' : 'wrap.results[' + \$index() + '].conceptName' }, value: containerId?containerId+'.'+id:id">

                        <div  class="col-6" data-bind="if:type && type.toLowerCase() === 'select'">
                            <p>
                                <span data-bind="if:title && title.toUpperCase() === 'TEST RESULT VALUE'">
                                    <label data-bind="text: container"></label>
                                </span>

                                <span data-bind="if:title && title.toUpperCase() !== 'TEST RESULT VALUE'">
                                    <label data-bind="text: title"></label>
                                </span>

                                <select id="result-option"
                                        data-bind="attr : { 'name' : 'wrap.results[' + \$index() + '].selectedOption' },
								foreach: options" style="width: 100%;">
                                    <option data-bind="attr: { value : value, selected : (\$parent.defaultValue === label) }, text: label"></option>
                                </select>
                            </p>
                        </div>

                        <!--Test for radio or checkbox-->
                        <div class="col-6" data-bind="if:(type && type.toLowerCase() === 'radio') || (type && type.toLowerCase() === 'checkbox')">
                            <p>

                            <div class="dialog-data"></div>
                            <label for="result-text">
                                <input id="result-text" class="result-text"
                                       data-bind="attr : { 'type' : type, 'name' : 'wrap.results[' + \$index() + '].value', value : defaultValue }">
                                <span data-bind="text: title"></span>
                            </label>
                        </p>
                        </div>

                        <!--Other Input Types-->
                        <div  class="col-6" data-bind="if:(type && type.toLowerCase() !== 'select') && (type && type.toLowerCase() !== 'radio') && (type && type.toLowerCase() !== 'checkbox')">
                            <p id="data">
                                <span data-bind="if:title && title.toUpperCase() === 'WRITE COMMENT'">
                                    <label data-bind="text: title + ' (' + container+')'"></label>
                                </span>

                                <span data-bind="if:title && title.toUpperCase() !== 'WRITE COMMENT'">
                                    <label data-bind="text: title"></label>
                                </span>

                                <input class="result-text"
                                       data-bind="attr : { 'type' : type, 'name' : 'wrap.results[' + \$index() + '].value', value : defaultValue }">
                            </p>
                        </div>

                        <div class="col-6" data-bind="if: !type">
                            <p>
                                <label for="result-text" data-bind="text: title"></label>
                                <input class="result-text" type="text"
                                       data-bind="attr : {'name' : 'wrap.results[' + \$index() + '].value', value : defaultValue }">
                            </p>
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <button class="cancel" data-dismiss="modal"
                        id="">${ui.message("patientqueueing.close.label")}</button>
                <span class="button confirm right">Save Results</span>
            </div>
        </div>
    </div>
</div>






