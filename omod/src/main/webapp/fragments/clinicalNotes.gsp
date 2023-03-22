<%
    ui.includeJavascript("ugandaemr", "js/ugandaemr.js")
%>
<style>
    .clinical-button{
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
    if (jQuery) {
        jq(document).ready(function () {
            displayClinicalNotes()
        });
    }

    function getClinicalNotes(conceptUUID) {
        var clinicalNotes = {}
        jq.ajax({
            type: "GET",
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs?v=full&patient=" + patientUUID + "&concept=" + conceptUUID + "",
            dataType: "json",
            contentType: "application/json",
            async: false,
            success: function (data) {
                clinicalNotes = data.results;
            }
        });
        return clinicalNotes
    }

    function displayClinicalNotes() {
        var otherClinicalNotes = getClinicalNotes("159395AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        var tbCLinicalNotes= getClinicalNotes("6965a8c4-7be5-47ee-a872-e158bd9545b1");
        if(tbCLinicalNotes.length>0){
            otherClinicalNotes.push(tbCLinicalNotes);
        }

        var content = "";
        jq.each(otherClinicalNotes, function (index, element) {
            var encounterProvider ="";

            if(element.encounter.encounterProviders.length>0){
                encounterProvider=" -  "+element.encounter.encounterProviders[0].display
            }
            var openCardHeader = "<div class=\"card\"><div class=\"card-header\" id=\"heading_" + index + "\"><button class=\"btn-link clinical-button\" data-toggle=\"collapse\" data-target=\"#collapse" + index + "\" aria-expanded=\"true\" aria-controls=\"collaps" + index + "\">";
            var header = element.encounter.encounterType.display+" - "+jq.datepicker.formatDate('dd.M.yy', new Date(element.obsDatetime))+encounterProvider
            var closeCardHeader = "</button></div>"
            var openCardBody = "<div id=\"collapse" + index + "\" class=\"collapse hide\" aria-labelledby=\"heading" + index + "\" data-parent=\"#clinical_summaries\"><div class=\"card-body\">";
            var clinicalNotes = element.value;
            var closeCardBody = "</div> </div> </div>"
            content += openCardHeader + header + closeCardHeader + openCardBody + clinicalNotes + closeCardBody;
        })
        jq("#clinical_summaries").html("");
        jq("#clinical_summaries").html(content);
    }
</script>


<div class="info-section patientsummary">
    <div class="info-header">
        <i class=" icon-user-md"></i>

        <h3>Patient Clinical Notes</h3>
    </div>

    <div class="info-body">

        <div class="accordion" id="clinical_summaries">

        </div>
    </div>
</div>