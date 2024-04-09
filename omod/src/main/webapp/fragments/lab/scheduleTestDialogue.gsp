<script>
    if (jQuery) {
        jq(document).ready(function () {
            jq("#reference-lab-container").addClass('hidden');

            jq("#refer_test").change(function () {
                if (jq("#refer_test").is(":checked")) {
                    jq("#reference-lab-container").removeClass('hidden');
                } else {
                    jq("#reference-lab-container").addClass('hidden');
                }
            });

            jq('#add-order-to-lab-worklist-dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget);
                var orderNumber = button.data('order-number');
                var orderUuid = button.data('orderuuid');
                var order;
                if (orderUuid !== "") {
                    order = getOrderByOrderUuid(orderUuid)
                }
                var patientQueueId = button.data('patientqueueid');
                var unProcessed = button.data('unprocessed-orders');
                var modal = jq(this)
                modal.find("#order_id").val(orderNumber);
                modal.find("#patient-queue-id").val(patientQueueId);
                modal.find("#unprocessed-orders").val(unProcessed);
                if (order && ('accessionNumber' in order) && order.accessionNumber!=null) {
                    modal.find("#sample_id").val(order.accessionNumber);
                    if (order.specimenSource != null) {
                        modal.find("#specimen_source_id").val(order.specimenSource.uuid);
                    } else {
                        modal.find("#specimen_source_id").val("");
                    }

                    if (order.instructions !== null && order.instructions.includes("REFER TO")) {
                        modal.find("#refer_test").prop('checked', true);
                        jq("#reference-lab-container").removeClass('hidden');
                        modal.find("#reference_lab").val(order.instructions.replace("REFER TO","").replace(" ",""));
                    } else {
                        modal.find("#refer_test").prop('checked', false);
                    }
                } else {
                    modal.find("#sample_id").val("");
                    modal.find("#sample_generator").html("");
                    modal.find("#sample_generator").append("<a onclick=\"generateLabNumber('" + orderUuid + "')\"><i class=\" icon-barcode\">Generate Sample Id</i></a>");
                    modal.find("#reference_lab").prop('selectedIndex', 0);
                    modal.find("#specimen_source_id").prop('selectedIndex', 0);
                    modal.find("#refer_test").prop('checked', false);
                }
            });
        });
    }
</script>

<div class="modal fade bd-order-modal-lg" id="add-order-to-lab-worklist-dialog" tabindex="-1" role="dialog"
     aria-labelledby="scheduleOrderModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <form id="addtesttoworklist">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${ui.message("SCHEDULE TEST")}</h3>
                </div>

                <div class="modal-body">

                    <span id="add_to_queue-container">
                        <input type="hidden" id="order_id" name="order_id" value="">
                        <input type="hidden" id="patient-queue-id" name="patient-queue-id" value="">
                        <input type="hidden" id="unprocessed-orders" name="unprocessed-orders" value="">
                    </span>

                    <div class="container">
                        <div class="row">
                            <div class="col-6">
                                <div class="form-group" id="specimen-id-container">
                                    <label for="sample_id">
                                        <span>${ui.message("SPECIMEN ID/SAMPLE ID")}</span>
                                    </label>
                                    <input class="form-control" type="text" id="sample_id" name="sample_id" value="">

                                    <div id="sample_generator"></div>
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group" id="specimen-source-container">
                                    <label for="specimen_source_id">
                                        <span>${ui.message("SAMPLE TYPE")}</span>
                                    </label>
                                    <select class="form-control" name="specimen_source_id" id="specimen_source_id">
                                    </select>
                                    <span class="field-error" style="display: none;"></span>

                                    <div id="error-specimen-source">${ui.message("patientqueueing.select.error")}</div>
                                </div>
                            </div>
                        </div>
                        <br/><br/>

                        <div class="row" style="margin-top: 20px">
                            <div class="col-6">
                                <label for="refer_test">
                                    <span>${ui.message("REFER TEST")}</span>
                                </label>

                                <div class="form-group">
                                    <input type="checkbox" name="refer_test" id="refer_test" value="refer">
                                    <div class="field-error"
                                         style="display: none;">${ui.message("patientqueueing.select.error")}</div>
                                </div>
                            </div>

                            <div class="col-6" id="reference-lab-container">
                                <div class="form-group">
                                    <select class="form-control" name="reference_lab" id="reference_lab">
                                        <option value="">${ui.message("Select Reference Lab")}</option>
                                        <option value="cphl">CPHL</option>
                                        <option value="uvri">UVRI</option>
                                        <option value="uvri">Other health center Lab</option>
                                        <option value="other-systems">Other Lab Systems</option>
                                    </select>

                                    <div class="field-error"
                                         style="display: none;"><${ui.message("patientqueueing.select.error")}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button class="cancel" data-dismiss="modal"
                                id="">${ui.message("patientqueueing.close.label")}</button>
                        <button type="submit" class="confirm"
                                id="submit-schedule">${ui.message("patientqueueing.send.label")}</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>