<script>
    var patientQueueId = "";
    var provider = "${config?.provider?.uuid}";
    var currentLocationUUID = "${config?.currentLocation?.uuid}";

    var serverResponse;
    if (jQuery) {
        jq(document).ready(function () {
            jq("input[id=patientQueueId").val(patientQueueId);
            jq("input[id=provider").val(provider);
            jq.ajax({
                type: "GET",
                url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/location?v=full&tag=c0e1d1d8-c97d-4869-ba16-68d351d3d5f5",
                dataType: "json",
                async: false,
                success: function (data) {
                    serverResponse = data.results;
                    pickQueueRoomOption(serverResponse, currentLocationUUID);
                }
            });
        });
    }

    function getCurrentDateTime() {
        jq.ajax({
            type: "GET",
            url: "${ ui.actionLink("getCurrentDateTime") }",
            async: false,
            success: function (data) {
                var responseData = JSON.parse(data.replace("currentDateTime=", "\"currentDateTime\":").trim());
                currentDateTime = responseData.currentDateTime;

            },
            error: function (response) {
                console.log(response);
            }
        });
    }

    function pickPatient() {
        var queueRoomToPost = null;
        var providerToPost = null;
        var datePicked = "";
        var queueRoom = jq("#queue_room_location").val();
        patientQueueId = jq("#patientQueueId").val();


        if (provider !== null || provider !== "") {
            providerToPost = "{\"uuid\":\"" + provider + "\"}";
        }

        if (queueRoomToPost !== null || queueRoom !== "") {
            queueRoomToPost = "{\"uuid\":\"" + queueRoom + "\"}";
        }

        jq.ajax({
            type: "GET",
            url: "${ ui.actionLink("getCurrentDateTime") }",
            async: false,
            success: function (data) {
                var responseData = JSON.parse(data.replace("currentDateTime=", "\"currentDateTime\":").trim());
                datePicked = responseData.currentDateTime;

            },
            error: function (response) {
                console.log(response);
            }
        });


        var dataToPost = "{\"status\": \"PICKED\", \"datePicked\": \"" + datePicked + "\", \"queueRoom\":" + queueRoomToPost + ",\"provider\":" + providerToPost + "}";
        jq.ajax({
            type: "POST",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/patientqueue/" + patientQueueId + "",
            dataType: "json",
            contentType: "application/json;",
            data: dataToPost,
            async: false,
            success: function (data) {
                serverResponse = data.results;
                navigateToURL(jq("#goToURL").val())

            },
            error: function (response) {
                console.log(response);
            }
        });

    }

    function navigateToURL(url) {
        window.location.href = url;
    }


    function pickQueueRoomOption(queueRooms, currentLocationUUID) {
        var queueRoomOptions = [];
        var sel = document.getElementById('queue_room_location');
        for (var i = 0 in queueRooms) {
            if (queueRooms[i].parentLocation.uuid === currentLocationUUID) {
                var opt = document.createElement('option');
                opt.appendChild(document.createTextNode(queueRooms[i].name));
                opt.value = queueRooms[i].uuid;
                sel.appendChild(opt);
                queueRoomOptions.push(queueRooms[i].uuid)
            }
        }

        if (queueRoomOptions.length > 0) {
            document.getElementById('queue_room_location-container').style.display = "block";
        } else {
            document.getElementById('queue_room_location-container').style.display = "none";
        }
    }
</script>

<div class="modal fade bd-order-modal-lg" id="pick_patient_queue_dialog" tabindex="-1" role="dialog"
     aria-labelledby="pickPatientQueueModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                Select Patient <span id="checkin_patient_names"></span><i class="icon-check medium"></i>
            </div>

            <div class="modal-body">
                <div class="container">
                    <div class="row">
                        <div class="col-11">
                            <div class="form-group" id="queue_room_location-container">
                                <label for="queue_room_location">${ui.message("patientqueueing.room.name")}</label>
                                <select class="form-control" id="queue_room_location">
                                    <option value="">${ui.message("patientqueueing.room.select.name")}</option>
                                </select>
                                <input type="hidden" name="provider" id="provider" value="">
                                <input type="hidden" name="patientQueueId" id="patientQueueId" value="">
                                <input type="hidden" name="goToURL" id="goToURL" value="">
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer form">
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel</button>
                        <button type="submit" onclick="pickPatient()" class="confirm" id="pick">Pick Patient</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>