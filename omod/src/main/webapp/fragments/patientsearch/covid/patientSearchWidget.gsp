<%
    config.require("afterSelectedUrl")
    def breadcrumbOverride = config.breadcrumbOverride ?: ""
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeCss("ugandaemrfingerprint", "patientsearch/patientSearchWidget.css")
    ui.includeCss("ugandaemrfingerprint", "patientsearch/fontcustom_findpatient_fingerprint.css")
    ui.includeJavascript("uicommons", "datatables/jquery.dataTables.min.js")
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/patientSearchWidget.js")
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/patientFingerPrintSearch.js")
    ui.includeJavascript("uicommons", "moment-with-locales.min.js")
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/sockjs-0.3.4.js")
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/stomp.js")
    ui.includeJavascript("patientqueueing", "patientqueue.js")
%>
<style type="text/css">
img {
    width: 100px;
    height: auto;
}


.vertical {
    border-left: 1px solid #c7c5c5;
    height: 70px;
    position: absolute;
    left: 106%;
    top: 0%;
}

.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

body {
    background: #f9f9f9;
}

#body-wrapper {
    margin-top: 10px;
    padding: 10px;
    background-color: #ffffff00;
    -moz-border-radius: 5px;
    -webkit-border-radius: 5px;
    -o-border-radius: 5px;
    -ms-border-radius: 5px;
    -khtml-border-radius: 5px;
    border-radius: 5px;
}

#patient-search {
    min-width: 95%;
    color: #363463;
    display: block;
    padding: 5px 10px;
    height: 40px;
    margin-top: 15px;
    background-color: #FFF;
    border: 1px solid #dddddd;
}

#images img {
    border-radius: 50px;
    width: 30%
}

</style>
<script type="text/javascript">
    var myVar;
    var stompClient = null;
    var listableAttributeTypes = [];
    var patientTransferInData;
    var patientTransferInObs;
    <% listingAttributeTypeNames.each { %>
    listableAttributeTypes.push('${ ui.encodeHtml(it) }');
    <% } %>
    var lastViewedPatients = [];

    function handlePatientRowSelection() {
        this.handle = function (row) {
            var uuid = row.uuid;
            location.href = '/' + OPENMRS_CONTEXT_PATH + emr.applyContextModel('${ ui.escapeJs(config.afterSelectedUrl) }', {
                patientId: uuid,
                breadcrumbOverride: '${ ui.escapeJs(breadcrumbOverride) }'
            });
        }
    }

    var handlePatientRowSelection = new handlePatientRowSelection();
    var addPatientToQueueLink = "<a  data-toggle=\"modal\" data-target=\"#add_patient_to_queue_dialog\" data-patientid=\"patientIdPlaceHolder\" data-patientnames=\"patientNamsePlaceHolder\"><i style=\"font-size: 25px;\" data-target=\"#add_patient_to_queue_dialog\" class=\"icon-share\" title=\"Check In\"></i></a>";
    var patientDashboardURL = "<i style=\"font-size: 25px;\" class=\"icon-file-alt\" title=\"Goto Patient Dashboard\" onclick=\" location.href = '/" + OPENMRS_CONTEXT_PATH + "/coreapps/clinicianfacing/patient.page?patientId=patientIdPlaceHolder'\"></i>";
    var editPatientLink = "<i style=\"font-size: 25px;\" class=\"icon-edit\" title=\"Edit Demographics\" onclick=\"location.href = '/" + OPENMRS_CONTEXT_PATH + "/registrationapp/editSection.page?patientId=patientIdPlaceHolder&sectionId=demographics&appId=aijar.registrationapp.registerPatient&returnUrl=/" + OPENMRS_CONTEXT_PATH + "/ugandaemr/findpatient/findPatient.page?app=fingerprint.findPatient'\"></i>";
    var patientSearchWidget = null;

    jq(function () {
        var widgetConfig = {
            initialPatients: lastViewedPatients,
            doInitialSearch: ${ doInitialSearch ? "\"" + ui.escapeJs(doInitialSearch) + "\"" : "null" },
            minSearchCharacters: ${ minSearchCharacters ?: 3 },
            afterSelectedUrl: '${ ui.escapeJs(config.afterSelectedUrl) }',
            breadcrumbOverride: '${ ui.escapeJs(breadcrumbOverride) }',
            searchDelayShort: ${ searchDelayShort },
            searchDelayLong: ${ searchDelayLong },
            searchOnline: ${searchOnline},
            onlinesearchString: "${simpleNationalIdString.replace('"', '\\"')}",
            onlineSearchURL: "${connectionProtocol+onlineIpAddress+queryURL}",
            handleRowSelection: ${ config.rowSelectionHandler ?: "handlePatientRowSelection" },
            dateFormat: '${ dateFormatJS }',
            locale: '${ locale }',
            defaultLocale: '${ defaultLocale }',
            attributeTypes: listableAttributeTypes,
            messages: {
                info: '${ ui.message("coreapps.search.info") }',
                first: '${ ui.message("coreapps.search.first") }',
                previous: '${ ui.message("coreapps.search.previous") }',
                next: '${ ui.message("coreapps.search.next") }',
                last: '${ ui.message("coreapps.search.last") }',
                noMatchesFound: '${ ui.message("coreapps.search.noMatchesFound") }',
                noData: '${ ui.message("coreapps.search.noData") }',
                recent: '${ ui.message("coreapps.search.label.recent") }',
                onlyInMpi: '${ ui.message("coreapps.search.label.onlyInMpi") }',
                searchError: '${ ui.message("coreapps.search.error") }',
                actionColHeader: 'Action',
                patientDashboardURL: patientDashboardURL,
                addPatientToQueueLink: addPatientToQueueLink,
                editPatientLink: editPatientLink,
                identifierColHeader: '${ ui.message("coreapps.search.identifier") }',
                nameColHeader: '${ ui.message("coreapps.search.name") }',
                genderColHeader: '${ ui.message("coreapps.gender") }',
                ageColHeader: '${ ui.message("coreapps.age") }',
                birthdateColHeader: '${ ui.message("coreapps.birthdate") }',
                ageInMonths: '${ ui.message("coreapps.age.months") }',
                ageInDays: '${ ui.message("coreapps.age.days") }'
            }
        };

        patientSearchWidget = new PatientSearchWidget(widgetConfig);
    });

    var socket = new SockJS('${fingerSocketPrintIpAddress}/search');
    stompClient = Stomp.over(socket);
    stompClient.connect({}, function (frame) {
        stompClient.subscribe('/topic/showResult', function (calResult) {
            showResult(JSON.parse(calResult.body));
        });
    });


    function search() {
        document.getElementById('calResponse').innerHTML = "";
        document.getElementById('images').innerHTML = "";
        stompClient.send("/calcApp/search", {});
    }

    function showResult(message) {
        var response = document.getElementById('calResponse');
        var imageDiv = document.getElementById('images');
        if (message.type === "image") {
            var imageTag = document.createElement('img');
            imageTag.src = "data:image/png;base64," + message.result;
            imageDiv.appendChild(imageTag);
        } else if (message.type === "local" && message.patient !== "") {
            patientSearchWidget.searchByFingerPrint(message.patient);
        } 
        /* else if (message.type === "online" && message.patient !== "" && ${searchOnline} === true) {
            window.location = "/" + OPENMRS_CONTEXT_PATH + "/ugandaemr/patientInOtherFacility.page?patientId=" + message.patient;
        } 
        */else if (message.type === null && (message.patient === null || message.patient === "") && ${searchOnline} === true) {
            var message;
            message = '{"result":"Patient Not Found at Central Server"}';
            showResult(JSON.parse(message));
            jq().toastmessage('showErrorToast', "Patient Not Found");
        } else {
            response.innerHTML = message.result;
        }
    }

    function myFunction() {
        document.getElementById("loader").className = "load";
        myVar = setTimeout(showPage, 5000);
    }

    function showPage() {
        document.getElementById("loader").style.display = "none";
        document.getElementById("myDiv").style.display = "block";
    }

    jq(document).ready(function () {
        jq('#add_patient_to_queue_dialog').on('show.bs.modal', function (event) {
            var button = jq(event.relatedTarget);
            var patientId = button.data('patientid');
            var patientNames = button.data('patientnames');
            var modal = jq(this)
            modal.find("#patient_id").val(patientId);
            modal.find("#checkin_patient_names").val(patientNames);
        });

        jq("#checkin").click(function () {
            jq.get('${ ui.actionLink("ugandaemr","checkIn","post") }', {
                patientId: jq("#patient_id").val().trim().toLowerCase(),
                locationId: jq("#location_id").val().trim().toLowerCase(),
                locationFromId: jq("#location_from_id").val().trim().toLowerCase(),
                patientStatus: jq("#patient_status").val().trim().toLowerCase(),
                visitComment: jq("#visit_comment").val().trim().toLowerCase()
            }, function (response) {
                var responseData = JSON.parse(response.replace("patientTriageQueue=", "\"patientTriageQueue\":").trim())
                printTriageRecord("printSection", responseData);
                jq("#add_patient_to_queue_dialog").modal('hide');
                if (!response) {
                    ${ ui.message("coreapps.none ") }
                }
            });
        });
    });
</script>

<script>
    function searchOnLine(identifier) {
        jq("#loading-model").modal("show");
        jq.post("https://apitest.cphluganda.org/diagnostic_report",
                    {
                        token: "FfRAgkkGTN0wHLkV4bXqszwyZgrq3UAE",
                        patient_id: identifier

                    },
                     function(data) {
                            //console.log(data);
                        var patientInfo = data[0];

                        if (data.length > 0) {
                            displayData(data);
                            patientTransferInData = data;
                        }
                        else {
                            jq("#loading-model").modal("hide");
                            alert("Patient NOT Found");
                        }
                    });



    }

    jQuery(document).ready(function (jq) {
        jq("#transferIn").click(function () {
            jq.post('${ ui.actionLink("ugandaemr","transferInCovidPatient","processCovidPatient") }', {
                patientDataFromRDS: JSON.stringify(patientTransferInData[0])
            }
            , function (response) {
                var patientEncounterInfo = JSON.parse(response.replace("patientCaseInvesitigationEncounter=", "\"patientCaseInvesitigationEncounter\":").trim());
                location.href = '/openmrs/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId='+patientEncounterInfo.patientCaseInvesitigationEncounter.patientId+'&encounterId='+patientEncounterInfo.patientCaseInvesitigationEncounter.encounterId;
            });
        });
    });

    function displayData(response) {
        jq("#patient_found").removeClass('hidden');
        jq("patient_found").show();
        //var patientNames = "" + patient.name[0].family + " " + response.data.patient.names[0].middleName + " " + response.data.patient.names[0].givenName;
        var patientInfo = response[0]
        var patient = patientInfo.contained[3];
        var careGiver = patient.contact[0];
        var dateOfBirth = "";
        if(patient.birthDate !== "") {
           dateOfBirth = formatDate(new Date(patient.birthDate));

        }else{
        // show age text field
        //hide date-of-birth-container
        }

        var patientNames      = "" + patient.name[0].text
        //patientNames        = patientNames.replace("null", "");
        var labContainer      = response[0].contained[0];
        var facilityContainer = response[0].contained[4];
        var testContainer     = response[0].contained[1];
        var testDate = "";
        if(testContainer.effectiveDateTime !== "") {
           testDate = formatDate(new Date(testContainer.effectiveDateTime));
        }
        var symptomsContainer  = response[0].contained[7];

        var dateOnSet = "";
        if(symptomsContainer.component[0].valueDateTime !== "") {
           dateOnSet = formatDate(new Date(symptomsContainer.component[0].valueDateTime));
        }

        jq("#patientNames").html(patientNames);
        //jq("#patientId").html(response.data.patient.uuid);
        jq("#birthDate").html(dateOfBirth + "");
        jq("#gender").html(patient.gender);
        jq("#labName").html(labContainer.name);
        jq("#sampleFacilityName").html(facilityContainer.name);
        jq("#testType").html(testContainer.code.text);
        jq("#testDate").html(testDate);
        jq("#testResult").html(testContainer.valueCodeableConcept.text);
        jq("#patientSymptomatic").html(symptomsContainer.valueBoolean);
        jq("#dateOnSet").html(dateOnSet);
        jq("#careGiverName").html(careGiver.name.text);
        jq("#careGiverPhone").html(careGiver.telecom[0].value);
        jq('#mostRecentEncounterModel').modal('show');
        jq("#loading-model").modal("hide");
    }

    function patientClinicInfo(response) {
        if (response.patientData != "") {
            if (response.patientData.obsLastEncounterPageList != null) {
                showContainer("#art_latest_encounter_header");
                jq().toastmessage('showSuccessToast', "Last Patient Encounter Loaded Successful");
                var contentToAppend = "";
                contentToAppend += "<div id=\"tabs-2\" style=\"background: #B6D6E6;\" class=\"encounter-summary-container\">";
                contentToAppend += "<table>";
                var encounterTypeName = "";
                for (x in response.patientData.obsLastEncounterPageList) {
                    encounterTypeName = response.patientData.obsLastEncounterPageList[0].encounterTypeName;
                    contentToAppend += "<tr><td>" + response.patientData.obsLastEncounterPageList[x].conceptName + "</td><td>" + response.patientData.obsLastEncounterPageList[x].answerSummary + "</td></tr>";
                }
                contentToAppend += "</table>";
                contentToAppend += "</div>";
                jq("#tabs").append(contentToAppend);
                jq("#encounterType").append(encounterTypeName);

            } else {
                var contentToAppend = "";
                contentToAppend += "<div id=\"tabs-2\" style=\"background: #B6D6E6;\" class=\"encounter-summary-container\">";
                contentToAppend += "</div>";
                jq("#tabs").append(contentToAppend);
            }
        }
    }

    function formatDate(date) {
        var monthNames = [
            "January", "February", "March",
            "April", "May", "June", "July",
            "August", "September", "October",
            "November", "December"
        ];

        var day = date.getDate();
        var monthIndex = date.getMonth();
        var year = date.getFullYear();

        return day + ' ' + monthNames[monthIndex] + ' ' + year;
    }
</script>

<script>
    jq(document).ready(function () {
        jq("#advanced-search").click(function () {
            
            var covidPatientId = jq("#covid-patient-id").val();

            if (covidPatientId !== "") {
                searchOnLine(covidPatientId);

            } 
        });
    });

    function generateUIC(givenName, middleName, surName, ageMonths, ageYears, dateOfBirth, country, gender) {
        var familyNameCode = "";
        var givenNameCode = "";
        var middleNameCode = "";
        var countryCode = "";
        var genderCode = "";
        var dob = dateOfBirth;

        var monthCode;

        if (dob == null) {
            return null;
        }


        var year = dob.getFullYear().toString().substring(2, 4);


        if (dob.getMonth() <= 8) {
            monthCode = "0" + (dob.getMonth() + 1);
        } else {
            monthCode = "" + (dob.getMonth() + 1);
        }

        if (gender === ("F")) {
            genderCode = "2";
        } else {
            genderCode = "1";
        }

        if (country !== null && country !== "") {
            countryCode = country.substring(0, 1);
        } else {
            countryCode = "X";
        }

        if (surName !== "" && surName !== null) {
            var firstLetter = replaceLettersWithNumber(surName.substring(0, 1));
            var secondLetter = replaceLettersWithNumber(surName.substring(1, 2));
            var thirdLetter = replaceLettersWithNumber(surName.substring(2, 3));
            familyNameCode = firstLetter + secondLetter + thirdLetter;
        } else {
            familyNameCode = "X";
        }

        if (givenName !== "" && givenName !== null) {
            var firstLetter1 = replaceLettersWithNumber(givenName.substring(0, 1));
            var secondLetter1 = replaceLettersWithNumber(givenName.substring(1, 2));
            var thirdLetter1 = replaceLettersWithNumber(givenName.substring(2, 3));
            givenNameCode = firstLetter1 + secondLetter1 + thirdLetter1;
        } else {
            givenNameCode = "X";
        }

        if (middleName !== "" && middleName !== null) {
            middleNameCode = replaceLettersWithNumber(middleName.substring(0, 1));
        } else {
            middleNameCode = "X";
        }

        return countryCode + "-" + monthCode + year + "-" + genderCode + "-" + givenNameCode + familyNameCode + middleNameCode;
    }


    function replaceLettersWithNumber(letter) {
        var numberToReturn = "X";

        switch (letter.toUpperCase()) {
            case "A":
                numberToReturn = "01";
                break;
            case "B":
                numberToReturn = "02";
                break;
            case "C":
                numberToReturn = "03";
                break;
            case "D":
                numberToReturn = "04";
                break;
            case "E":
                numberToReturn = "05";
                break;
            case "F":
                numberToReturn = "06";
                break;
            case "G":
                numberToReturn = "07";
                break;
            case "H":
                numberToReturn = "08";
                break;
            case "I":
                numberToReturn = "09";
                break;
            case "J":
                numberToReturn = "10";
                break;
            case "K":
                numberToReturn = "11";
                break;
            case "L":
                numberToReturn = "12";
                break;
            case "M":
                numberToReturn = "13";
                break;
            case "N":
                numberToReturn = "14";
                break;
            case "O":
                numberToReturn = "15";
                break;
            case "P":
                numberToReturn = "16";
                break;
            case "Q":
                numberToReturn = "17";
                break;
            case "R":
                numberToReturn = "18";
                break;
            case "S":
                numberToReturn = "19";
                break;
            case "T":
                numberToReturn = "20";
                break;
            case "U":
                numberToReturn = "21";
                break;
            case "V":
                numberToReturn = "22";
                break;
            case "W":
                numberToReturn = "23";
                break;
            case "X":
                numberToReturn = "24";
                break;
            case "Y":
                numberToReturn = "25";
                break;
            case "Z":
                numberToReturn = "26";
                break;

            default:
                numberToReturn = "X";
        }
        return numberToReturn;
    }
</script>

<div class="card">
    <div class="card-body">
        <div class="row">
            <div class="col col-lg-1">
                <div>
                    <div class="left">
                        <label style="color: maroon">Fingerprint</label>
                    </div>

                    <div class="center" style="margin-left: 22px;">
                        <i id="patient-search-finger-print-button" onclick="search();"
                           class="fas medium fa-fingerprint"></i>
                    </div>

                    <div class="vertical"></div>
                </div>
            </div>

            <div class="col col-lg-8" style="vertical-align: middle;">
                <form method="get" id="patient-search-form" onsubmit="return false">
                    <input type="text" id="patient-search"
                           placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                           autocomplete="off" <% if (doInitialSearch) { %>value="${doInitialSearch}" <% } %>/>
                    <i id="patient-search-clear-button" class="small icon-remove-sign"></i>
                </form>
            </div>

            <div class="col col-lg-1">
                <div id="patient-search-finger-print" style="display:none;">
                    <div id="calculationDiv">
                        <p id="calResponse"></p>

                        <div id="images"></div>
                    </div>
                </div>
            </div>

            <div class="col col-lg-2 right">
                <div class="center">
                    <% if (registrationAppLink ?: false) { %>
                    <span style="width: 40%;text-align:center;margin-left: 52px;"><a
                            id="patient-search-register-patient" href="/${contextPath}/${registrationAppLink}"><i
                                class="icon-plus-sign medium"></i><br/></a></span>
                    <span style="width:100%; text-align:center">Create New Patient</span>
                    <% } %>
                </div>
            </div>
        </div>

        <p>
            <a data-toggle="collapse" style="width: 10px" href="#collapseExample" role="button" aria-expanded="false"
               aria-controls="collapseExample">
                Advanced Search
            </a>
        </p>

        <div class="collapse" id="collapseExample">
            <div class="card card-body">
                <div class="row">
                    <div class="col-3">
                        <input type="text" id="covid-patient-id" placeholder="Patient Id" value="" autocomplete="off"/>
                    </div>
                    <div class="col-3">
                        <input type="submit" value="Search" class="submit" id="advanced-search" autocomplete="off"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<div id="patient-search-results"></div>

<div class="modal fade" id="mostRecentEncounterModel" tabindex="-1" role="dialog"
     aria-labelledby="mostRecentEncounterModelLabel"
     aria-hidden="false">
    <div class="modal-dialog  modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mostRecentEncounterModelLabel" style="color : #ffffff" >Patient Information From RDS</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <div class="">
                    <h5>Patient Information</h5>
                    <div>
                        <strong>Patient Names:</strong> <span style="" id="patientNames"></span>
                    </div>

                    <div>
                        <strong>Sex:</strong> <span id="gender"></span>
                    </div>

                    <div id="date-of-birth-container">
                        <strong>Date of Birth:</strong> <span id="birthDate"></span>
                    </div>
                    <div id="patient-age" class = "hidden">
                        <label for="example">Enter Patient Age</label>
                        <input type="text" id="age">
                    </div>
                    <div>
                        <strong>Sample Collection Facility:</strong> <span id="sampleFacilityName"></span>
                    </div>

                    <div>
                        <strong>Testing Lab:</strong> <span id="labName"></span>
                    </div>
                </div>

                <h5>Testing</h5>

                <div>
                    <strong>Test Type:</strong> <span id="testType"></span>
                </div>
                <div>
                    <strong>Test Date:</strong> <span id="testDate"></span>
                </div>

                <h5>Symptoms</h5>

                <div>
                    <strong>Patient Symptomatic:</strong> <span id="patientSymptomatic"></span>
                </div>
                <div>
                    <strong>Date on Set of First Symptom:</strong> <span id="dateOnSet"></span>
                </div>

                <h5>Care Giver</h5>

                <div>
                    <strong>Care Giver Name:</strong> <span id="careGiverName"></span>
                </div>
                <div>
                    <strong>Care Giver Phone no:</strong> <span id="careGiverPhone"></span>
                </div>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="submit" class="confirm" id="transferIn">${ui.message("Transfer In")}</button>
            </div>
        </div>
    </div>
</div>
${ui.includeFragment("ugandaemr", "checkIn")}
<div class="modal fade" id="loading-model" tabindex="-1" role="dialog"
     aria-labelledby="loadingModelLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content" style="align-items: center;background: none; border: none">
            <div class="spinner-border big active crazy text-primary" role="status"
                 style="width: 100px; height: 100px;">
                <span class="sr-only">Searching Online</span>
            </div>
        </div>
    </div>
</div>

