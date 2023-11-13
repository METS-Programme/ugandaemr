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

#patientId {
    width: 100%;
}

h5 {
    color: #FFF;
}
.btn-secondary {
    color: #5b0505;
    background-color: #4f0c0c;
    border-color: #950606;
}

</style>
<script type="text/javascript">
    var myVar;
    var stompClient = null;
    var listableAttributeTypes = [];
    var patientTransferInData;
    var patientToRegister;
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
    var editPatientLink = "<i style=\"font-size: 25px;\" class=\"icon-edit\" title=\"Edit Demographics\" onclick=\"location.href = '/" + OPENMRS_CONTEXT_PATH + "/registrationapp/registrationSummary.page?patientId=patientIdPlaceHolder&sectionId=demographics&appId=ugandaemr.registrationapp.registerPatient&returnUrl=/" + OPENMRS_CONTEXT_PATH + "/ugandaemr/findpatient/findPatient.page?app=ugandaemr.findPatient'\"></i>";
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
        } else if (message.type === "online" && message.patient !== "" && ${searchOnline} === true) {
            window.location = "/" + OPENMRS_CONTEXT_PATH + "/ugandaemrfingerprint/patientInOtherFacility.page?patientId=" + message.patient;
        } else if (message.type === null && (message.patient === null || message.patient === "") && ${searchOnline} === true) {
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

    function getSearchConfigs(uuid) {
        var searchConfigs;
        jQuery.ajax({
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/syncfhirprofile/" + uuid + "?v=full",
            dataType: 'json',
            headers: {
                'Content-Type': 'application/json',
            },
            type: 'GET',
            async: false
        }).success(function (data) {
            searchConfigs = data;
        })

        return searchConfigs;
    }

    function checkProfileEnabled(uuid) {
        var profileEnabled;
        jQuery.ajax({
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/syncfhirprofile/" + uuid + "?v=full",
            dataType: 'json',
            headers: {
                'Content-Type': 'application/json',
            },
            type: 'GET',
            async: false
        }).success(function (data) {
            var profile = data;
            profileEnabled = profile.profileEnabled;
        })
        return profileEnabled;
    }

    function generateSearchParams(id) {
        var data = {};
        jq("#" + id).find("input").each(function () {
            var inputtag = jq(this);
            var id = inputtag.attr("id");
            var value = inputtag.val();

            switch (id) {
                case 'patientId':
                    id = "identifier"
                    break;
                case 'sur-name':
                    id = "family"
                    break;
                case 'middle-name':
                    id = "name"
                    break;
                case 'given-name':
                    id = "name"
                    break;
                default:
                    break;
            }
            if (value !== "" && value !== null && id !== "advanced-search" && id !== "advanced-search-fshr") {
                data[id] = value;
            }
        });
        return new URLSearchParams(data).toString();
    }

    function searchOnLineFhirServer(identifier, searchConfigs, searchParams) {
        var query = "?"
        var searchObject = "Patient";

        if (searchConfigs.url.indexOf(searchObject) <= -1) {
            query = "/" + searchObject + query
        }

        if (identifier !== null && identifier !== "") {
            query = query + "identifier=" + identifier;
        } else {
            query = query + searchParams;
            query = query.replace("%s", searchParams);
        }

        var url = searchConfigs.url + query;
        var settings = null;

        if (searchConfigs.urlUserName !== null && searchConfigs.urlUserName !== "") {
            settings = {
                "url": url,
                "method": "GET",
                "timeout": 0,
                "async": false,
                "headers": {
                    'Authorization': "Basic " + btoa(searchConfigs.urlUserName + ":" + searchConfigs.urlPassword),
                },
            };
        } else {
            settings = {
                "url": url,
                "method": "GET",
                "timeout": 0,
                "async": false,
            };
        }
        jQuery.ajax(settings).done(function (data) {
            if (data.hasOwnProperty('resourceType') && data.resourceType === "Bundle" && data.total > 0) {
                patientTransferInData = data;
                displayFhirData(data);
            } else {
                jq("#loading-model").modal('hide');
                jq().toastmessage('showNoticeToast', "No Record found");
            }
        }).error(function (data, status, err) {
            jq("#loading-model").modal("hide");
            jq().toastmessage('showErrorToast', data);
        });
    }

    function transferPatientIn(position) {
        patientToRegister = null;
        patientToRegister = formatFHIRResults(patientTransferInData, position);
        var patientData = patientTransferInData.entry[position].resource
        jq("#patient_found").removeClass('hidden');
        jq("patient_found").show();
        var patientNames = "" + patientData.name[0].family + " " + patientData.name[0].given[0];
        patientNames = patientNames.replace("null", "");
        jq("#patientNamesToRegister").html(patientNames);
        jq("#patientIdToRegister").html(patientData.id);
        if (patientData.managingOrganization) {
            jq("#facilityNameToRegister").html("At " + patientData.managingOrganization.display);
            jq("#facilityIdToRegister").html(patientData.managingOrganization.identifier.value);
        }
        var dateOfBirth = formatDate(new Date(patientData.birthDate));
        jq("#dateOfBirthToRegister").html(" " + dateOfBirth + "");
        jq("#genderToRegister").html(" " + patientData.gender);
        jq('#confirmRegistrationModel').modal('show');
    }

    function confirmRegistration() {
        var url = '/' + OPENMRS_CONTEXT_PATH + "/ws/fhir2/R4/Patient";
        jQuery.ajax({
            url: url,
            type: 'POST',
            async: false,
            contentType: "application/json",
            data: JSON.stringify(patientToRegister)
        }).success(function (response) {
            var responseStatus = response;
            transferPatientIn = true;
            jq().toastmessage('showSuccessToast', "Patient Created Successfully");
            jq('#mostRecentEncounterModel').modal('hide').data('bs.modal', null);
            jq('#confirmRegistrationModel').modal('hide').data('bs.modal', null);
        }).error(function (data, status, err) {
            jq.each(JSON.parse(data.responseText).issue, function (index, element) {
                jq().toastmessage('showErrorToast', element.diagnostics);
            });
            jq("#loading-model").modal("hide");
        });
    }


    function formatFHIRResults(resources, position) {
        var patientSystemIndentifier = JSON.parse("{\"use\":\"official\",\"type\":{\"coding\":[{\"system\":\"UgandaEMR\",\"code\":\"05a29f94-c0ed-11e2-94be-8c13b969e334\"}],\"text\":\"OpenMRS ID\"},\"system\":\"UgandaEMR\",\"value\":\"\",\"id\":\"\"}");
        var patientResource = resources.entry[position].resource;
        var identifiersToKeep = [];

        jQuery.ajax({
            url: '/' + OPENMRS_CONTEXT_PATH + "/ws/module/idgen/generateIdentifier.form?source=1",
            dataType: 'json',
            headers: {
                'Content-Type': 'application/json',
            },
            type: 'GET',
            async: false
        }).success(function (data) {
            patientSystemIndentifier.value = data.identifiers[0];
            patientSystemIndentifier.id = patientResource.id;
        })

        identifiersToKeep.push(patientSystemIndentifier);

        //Delete logical ID from another facility

        // Check if patient has National ID and keep it if found

        patientResource.identifier.forEach(function (identifier, index) {
            patientResource.identifier[index].id = uuidv4();
        });

        if (patientResource.hasOwnProperty("identifier")) {
            jq.each(patientResource.identifier, function (index, element) {
                if (element.type.coding[0].code === "f0c16a6d-dc5f-4118-a803-616d0075d282" || element.type.coding[0].code === "e1731641-30ab-102d-86b0-7a5022ba4115") {
                    identifiersToKeep.push(element)
                }
            });
        }

        patientResource.address.forEach(function (address, index) {
            patientResource.address[index].id = uuidv4();
        });

        patientResource.name.forEach(function (name, index) {
            patientResource.name[index].id = uuidv4();
        });

        // Delete any logical ID in property telecom
        if (patientResource.hasOwnProperty("meta")) {
            delete patientResource['meta'];
        }

        if (patientResource.hasOwnProperty("link")) {
            delete patientResource['link'];
        }

        if (patientResource.hasOwnProperty("text")) {
            delete patientResource['text'];
        }

        var numberOfIdentifiers = patientResource.identifier.length

        patientResource.identifier.splice(0, numberOfIdentifiers);
        patientResource.identifier = identifiersToKeep;

        return patientResource;
    }


    function displayData(response) {
        jq("#patient_found").removeClass('hidden');
        jq("patient_found").show();
        var patientNames = "" + response.data.patient.names[0].familyName + " " + response.data.patient.names[0].middleName + " " + response.data.patient.names[0].givenName;
        patientNames = patientNames.replace("null", "");
        jq("#patientNames").html(patientNames);
        jq("#patientId").html(response.data.patient.uuid);
        jq("#age").html(response.data.patient.age);
        jq("#facilityName").html(" " + response.data.patient.patientFacility.name);
        jq("#facilityNameHeader").html("At " + response.data.patient.patientFacility.name);
        jq("#facilityId").html(response.data.patient.patientFacility.uuid);
        var dateOfBirth = formatDate(new Date(response.data.patient.birthdate));
        jq("#dateOfBirth").html(dateOfBirth + "");
        jq("#gender").html(response.data.patient.gender);
    }

    function displayFhirData(response) {
        populateDisplayTable(response);
        jq("#patient_found").removeClass('hidden');
        jq("patient_found").show();
        jq('#mostRecentEncounterModel').modal('show');
    }

    function displayFhirRecords(response) {
        populateDisplayTable(response);
        jq("#patient_found").removeClass('hidden');
        jq("patient_found").show();

        jq("#loading-model").modal("hide");
        jq('#mostRecentEncounterModel').modal('show');
    }

    function uuidv4() {
        return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
            (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
    }

    function populateDisplayTable(response) {
        var prDiv = document.getElementById("pr");
        prDiv.innerHTML = "";
        var tableDiv = document.createElement("table");
        var patientHeaderRow = document.createElement("tr");
        var patientNameHeader = document.createElement("th");
        patientNameHeader.innerHTML = "Patient Name";
        var patientDOBHeader = document.createElement("th");
        patientDOBHeader.innerHTML = "Birth Date";
        var patientGenderHeader = document.createElement("th");
        patientGenderHeader.innerHTML = "Sex";
        var patientTelecomHeader = document.createElement("th");
        patientTelecomHeader.innerHTML = "Phone Number";
        var patientActionHeader = document.createElement("th");
        patientActionHeader.innerHTML = "Action";

        patientHeaderRow.append(patientNameHeader);
        patientHeaderRow.append(patientDOBHeader);
        patientHeaderRow.append(patientGenderHeader);
        patientHeaderRow.append(patientTelecomHeader);
        patientHeaderRow.append(patientActionHeader);

        tableDiv.appendChild(patientHeaderRow);

        response.entry.forEach(function (entity, index) {
                var patient = entity.resource;
                var trElement = document.createElement("tr");
                var tdPatientName = document.createElement("td");
                tdPatientName.innerHTML = patient.name[0].family + " " + patient.name[0].given[0];
                var tdPatientDOB = document.createElement("td");
                tdPatientDOB.innerHTML = formatDate(new Date(patient.birthDate))
                var tdPatientGender = document.createElement("td");
                tdPatientGender.innerHTML = patient.gender;
                var tdPatientTelecom = document.createElement("td");
                var tdPatientAction = document.createElement("td");
                if (patient.hasOwnProperty("telecom")) {
                    patient.telecom.forEach(function (telecom, index) {
                        tdPatientTelecom.innerHTML = tdPatientTelecom.innerHTML + " " + telecom.value
                    });
                }

                var transferInButton = document.createElement("button");


                transferInButton.innerHTML = " Register "

                transferInButton.setAttribute("id", "transfer-" + index);
                transferInButton.setAttribute("class", "icon-random confirm");
                transferInButton.setAttribute("onclick", "transferPatientIn(" + index + ")");
                transferInButton.setAttribute("onclick", "transferPatientIn(" + index + ")");

                tdPatientAction.append(transferInButton);

                trElement.append(tdPatientName);
                trElement.append(tdPatientDOB);
                trElement.append(tdPatientGender);
                trElement.append(tdPatientTelecom);
                trElement.append(tdPatientAction);
                tableDiv.append(trElement);
            }
        )
        ;
        prDiv.appendChild(tableDiv);
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

    jq(document).ready(function () {
        jq('#fshr').hide();
        jq('#nhcr').hide();
        if (checkProfileEnabled("84242661-aadf-42e4-9431-bf8afefb4433")) {
            // show the client registry search link
            jq('#nhcr').show();
        }
        if (checkProfileEnabled("0b7eb397-4488-4a88-9967-a054b3c26d6f")) {
            // show the facility shr search link
            jq('#fshr').show();
        }
        jq("#advanced-search").click(function () {
            var surName = jq("#sur-name").val();
            var middleName = jq("#middle-name").val();
            var givenName = jq("#given-name").val();
            var patientId = jq("#patientId").val();
            var searchConfigs = getSearchConfigs("84242661-aadf-42e4-9431-bf8afefb4433");
            var searchParams = generateSearchParams("search-client-registry");
            var birthDate = null;

            if (jq("#birthdate").val() !== null && jq("#birthdate").val() !== "") {
                birthDate = new Date(jq("#birthdate").val());
            }

            var country = jq("#address-country").val();
            var gender = jq("#search-gender").val();

            var uic = "";

            if (patientId === "") {
                //uic = generateUIC(givenName, middleName, surName, null, null, birthDate, country, gender);
            }

            if (patientId !== "" && uic === "") {
                patientSearchWidget.searchByIdentifiers(patientId);
            } else {
                patientSearchWidget.searchByIdentifiers(uic);
            }

            if (patientSearchWidget.getCountAfterSearch() === 0 && patientId !== "") {
                searchOnLineFhirServer(patientId, searchConfigs, searchParams);
            } else if (patientSearchWidget.getCountAfterSearch() === 0 && patientId === "" && uic !== "") {
                searchOnLineFhirServer(uic, searchConfigs, searchParams);
            }
        });

        jq("#advanced-search-fshr").click(function () {
            var surName = jq("#sur-name").val();
            var middleName = jq("#middle-name").val();
            var givenName = jq("#given-name").val();
            var patientId = jq("#patientId").val();
            var searchConfigs = getSearchConfigs("0b7eb397-4488-4a88-9967-a054b3c26d6f");
            var searchParams = generateSearchParams("search-fhsr");
            var birthDate = null;

            if (jq("#birthdate").val() !== null && jq("#birthdate").val() !== "") {
                birthDate = new Date(jq("#birthdate").val());
            }

            var country = jq("#address-country").val();
            var gender = jq("#search-gender").val();

            var uic = "";

            if (patientId === "") {
                uic = generateUIC(givenName, middleName, surName, null, null, birthDate, country, gender);
            }

            if (patientId !== "" && uic === "") {
                patientSearchWidget.searchByIdentifiers(patientId);
            } else {
                patientSearchWidget.searchByIdentifiers(uic);
            }

            if (patientSearchWidget.getCountAfterSearch() === 0 && patientId !== "") {
                searchOnLineFhirServer(patientId, searchConfigs, searchParams);
            } else if (patientSearchWidget.getCountAfterSearch() === 0 && patientId === "" && uic !== "") {
                searchOnLineFhirServer(null, searchConfigs, searchParams);
            }
        });
    });


    function generateUIC(givenName, middleName, surName, ageMonths, ageYears, dateOfBirth, country, gender) {
        var familyNameCode = "";
        var givenNameCode = "";
        var middleNameCode = "";
        var countryCode = "";
        var genderCode = "";
        var birthdate = dateOfBirth;

        var monthCode;

        if (birthdate == null) {
            return null;
        }

        var year = birthdate.getFullYear().toString().substring(2, 4);


        if (birthdate.getMonth() <= 8) {
            monthCode = "0" + (birthdate.getMonth() + 1);
        } else {
            monthCode = "" + (birthdate.getMonth() + 1);
        }

        if (gender === ("F")) {
            genderCode = "2";
        } else {
            genderCode = "1";
        }

        if (country !== null && country !== "") {
            countryCode = country.substring(0, 2).toUpperCase();
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

        <div class="row">
            <div id="nhcr" class="col-7">
                <a data-toggle="collapse" style="width: 10px" href="#collapseExample" role="button"
                   aria-expanded="false"
                   aria-controls="collapseExample">
                    Search NHCR (National Health Client Registry)
                </a>
            </div>

            <di id="fshr" class="col-5" style="text-align: right">
                <a data-toggle="collapse" style="width: 10px;" href="#collapseFHSR" role="button" aria-expanded="false"
                   aria-controls="collapseExample">
                    Search FSHR (Facility Intergration Service)
                </a>
        </div>
    </div>

    <div class="collapse" id="collapseExample">
        <div class="card card-body" id="search-client-registry">
            <div class="row">
                <div class="col-8">
                    <input type="text" id="patientId" placeholder="Patient Unique Identifier" value=""
                           autocomplete="off"/>
                </div>

                <div class="col-4">
                    <input type="submit" value="Search" class="submit" id="advanced-search" autocomplete="off"/>
                </div>
            </div>
        </div>
    </div>

    <div class="collapse" id="collapseFHSR">
        <div class="card card-body" id="search-fhsr">
            <div class="row">
                <div class="col-3">
                    <input type="text" id="sur-name" placeholder="First Name/Surname" autocomplete="off"/>
                </div>

                <div class="col-3">
                    <input type="text" id="given-name" placeholder="Given Name" autocomplete="off"/>
                </div>

                <div class="col-3">
                    <input type="text" id="middle-name" placeholder="Middle Name" autocomplete="off"/>
                </div>

                <div class="col-3">
                    <input type="text" id="patientId" placeholder="Patient Id" value="" autocomplete="off"/>
                </div>
            </div>

            <div class="row">
                <div class="col-3">
                    <select id="search-gender">
                        <option value="">Select Gender</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                    </select>
                </div>

                <div class="col-3">
                    <input type="date" id="birthdate" placeholder="Date Of Birth" autocomplete="off"/>
                </div>

                <div class="col-3">
                    <input type="text" id="telecom" placeholder="Phone Number" autocomplete="off"/>
                </div>
            </div>

            <div class="row">
                <div class="col-3">
                    <input type="text" id="address-country" placeholder="Country" autocomplete="off"/>
                </div>

                <div class="col-3">
                    <input type="submit" value="Search" class="submit" id="advanced-search-fshr" autocomplete="off"/>
                </div>
            </div>

        </div>
    </div>
</div>
</div>


<div id="patient-search-results"></div>

<div class="modal fade" id="mostRecentEncounterModel" tabindex="-1" role="dialog"
     aria-labelledby="mostRecentEncounterModelLabel"
     aria-hidden="true">
    <div class="modal-dialog  modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mostRecentEncounterModelLabel">Potential Matches of Patients Found</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <div id="pr">

                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmRegistrationModel" tabindex="-1" role="dialog"
     aria-labelledby="confirmRegistrationModelLabel"
     aria-hidden="true">
    <div class="modal-dialog  modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"
                    id="confirmRegistrationModelLabel">Are You Sure you want to register this Patient <span
                        id="patientIdNumber"></span></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <div class="">
                    <div>
                        <strong>Patient Names:</strong> <span style="" id="patientNamesToRegister"></span>
                    </div>

                    <div>
                        <strong>Sex:</strong><span id="genderToRegister"></span>
                    </div>

                    <div>
                        <strong>Date of Birth:</strong><span id="dateOfBirthToRegister"></span>
                    </div>

                    <div>
                        <strong>Facility Name:</strong><span id="facilityNameToRegister"></span>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="submit" class="confirm" onclick="confirmRegistration()"
                        id="confirmRegistration">${ui.message("Register Patient")}</button>
            </div>
        </div>
    </div>
</div>

${ui.includeFragment("ugandaemr", "checkIn")}
<div class="modal fade hide" id="loading-model" tabindex="-1" role="dialog"
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


<div id="patient-search-results"></div>