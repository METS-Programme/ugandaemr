<div class="modal fade bd-order-modal-lg" id="reject-order-dialog" tabindex="-1" role="dialog"
     aria-labelledby="scheduleOrderModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h3>${ui.message("REJECT TEST")}</h3>
            </div>

            <div class="modal-body">

                <span id="add_to_queue-container">
                    <input type="hidden" id="reject_order_id" name="reject_order_id" value="">
                </span>

                <div class="container">
                    <div class="row">
                        <div class="col-6">
                            <div class="form-group">
                                <label for="order_reject_comment"><span>${ui.message("Reason for Rejecting Order")}</span>
                                </label>
                                <textarea id="order_reject_comment" name="order_reject_comment" rows="5" cols="60"></textarea>
                            </div>
                        </div>
                    </div>
                    <br/><br/>
                </div>

                <div class="modal-footer">
                    <button class="cancel" data-dismiss="modal"
                            id="">${ui.message("patientqueueing.close.label")}</button>
                    <button type="submit" class="confirm"
                            id="submit-order-reject">${ui.message("patientqueueing.send.label")}</button>
                </div>
            </div>
        </div>
    </div>
</div>