<script>

    var urlParams = new URLSearchParams(window.location.search);
    var patientUUID = "${patientUUID}";
    var healthCenterName = "${healthCenterName}";

    jq(document).ready(function () {
        getNextAppointemt(urlParams.get("patientId"))
    });

    function getNextAppointemt(patient) {
        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs?patient=" + patientUUID + "&concept=dcac04cf-30ab-102d-86b0-7a5022ba4115&v=custom:(uuid,display,concept:(name:(name),uuid),obsDatetime,location:(uuid,display),value)",
            dataType: "json",
            contentType: "application/json",
            async: false,
            success: function (data) {
                var appointments = data.results;

                jq('#appointment_date_widget').hide();
                jq('#no_appointment_data').show();
                for (var i = 0 in appointments) {
                    if ((new Date(appointments[i].value)) >= (new Date())) {
                        var div = renderNextAppointment(appointments[i]);
                        jq('#appointment_date_widget').append(div);
                        jq('#no_appointment_data').hide();
                        jq('#appointment_date_widget').show();
                    }
                }

            }
        });
    }


    function renderNextAppointment(appointment) {

        var appointment_date = jq.datepicker.formatDate('dd.M.yy', new Date(appointment.value));


        var appointment_location;

        if (appointment.location === null) {
            appointment_location = healthCenterName;
        } else {
            appointment_location = appointment.location.display;
        }

        return '<div class="info-body" style="margin-top:4px"> <div style="display: block; overflow: hidden; padding-right: 5px; padding-bottom: 2px"> <span style="float: left" class="ng-binding"> Date:&nbsp;&nbsp;</span><span style="float: left"><strong class="ng-binding">' + appointment_date + '</strong></span></div><div style="display: block; overflow: hidden; padding-right: 5px; padding-bottom: 2px"><span style="float: left" class="ng-binding">Location:&nbsp;&nbsp;</span><span style="float: left"> <strong class="ng-binding">' + appointment_location + '</strong></span></div></div>';
    }

</script>


<div class="info-section patientsummary">
    <div class="info-header">
        <i class=" icon-user-md"></i>

        <h3>NEXT APPOINTMENT</h3>
    </div>

    <div class="info-body" id="appointment_date_widget">

    </div>

    <div id="no_appointment_data" class="info-body">No Upcoming Appointment</div>
</div>