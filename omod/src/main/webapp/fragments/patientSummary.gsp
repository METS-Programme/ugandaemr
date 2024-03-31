<script>

    var urlParams = new URLSearchParams(window.location.search);
    var patientUUID = "${patientUUID}";
    var healthCenterName = "${healthCenterName}";

    jq(document).ready(function () {
        getLatestBMI(urlParams.get("patientId"))
    });
    function getLatestBMI(patient) {
        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/latestobs?concept=5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,dcbcba2c-30ab-102d-86b0-7a5022ba4115&nLatestObs=1&patient="+patientUUID+"&v=custom:(display,obsDatetime,concept:(uuid,display,datatype:(uuid),names:(name,locale,localePreferred,voided,conceptNameType)),value:(uuid,display,names:(name,locale,localePreferred,voided,conceptNameType)),groupMembers:(value,concept:(display,names:(name,locale,localePreferred,voided,conceptNameType))))",
            dataType: "json",
            contentType: "application/json",
            async: false,
            success: function (data) {
                jq('#patient_cd4')
                var results = data.results;
                var height;
                var weight;
                for (var i = 0 in results) {
                    if (results[i].concept.uuid==="dcbcba2c-30ab-102d-86b0-7a5022ba4115") {
                        jq('#patient_cd4').append(results[i].value+" on "+jq.datepicker.formatDate('dd.M.yy', new Date(results[i].obsDatetime)));
                    }else if(results[i].concept.uuid==="5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"){
                        height=results[i]
                    }else if(results[i].concept.uuid==="5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"){
                        weight=results[i]
                    }
                }
                jq('#patient_bmi').append(renderBMI(height,weight));

            }
        });
    }
    function renderBMI(height,weight) {

        var bmi;

        if(height!==null && weight!==null){
            var computedValue=(weight.value*10000)/(weight.value*height.value)
            bmi=Math.round(computedValue);
        }
        return bmi + "("+height.display +" | " +weight.display+")";
    }

</script>
<div class="info-section patientsummary">
    <div class="info-header">
        <i class=" icon-user-md"></i>

        <h3>${ui.message("ugandaemr.patientdashboard.patientsummary.heading").toUpperCase()}</h3>

    </div>

    <div class="info-body">
        <div>
            <strong>${ui.message("ugandaemr.patientdashboard.person.lastcd4")}:</strong>
            <span id="patient_cd4"></span>
        </div>
        <div>
            <strong>${ui.message("ugandaemr.patientdashboard.person.bmi")}:</strong>
            <span id="patient_bmi"></span>
        </div>
    </div>
</div>