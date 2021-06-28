/* deceased Patient patient data entry functionality */
jq('#checkbox-autogenerate-identifier').click(function () {
    if (jq('#checkbox-deceased').is(':checked')) {
        NavigatorController.getFieldById('deceased-status').show();
    }
    else {
        NavigatorController.getFieldById('deceased-status').hide();
    }
});

/* Remove the ability to edit the different patient identifiers by removing the link  */
jq(document).ready(function () {
    // Remove identifiers without data
    jq("div.identifiers br").remove(); // remove all breaks
    jq("div.identifiers div:contains('Add')").remove(); // remove all identifiers without values
    jq("div.identifiers div").addClass("pr-2");
    // remove the link to enable editing of the patient identifier
    jq(".editPatientIdentifier").each(function () {
        jq(this).attr('href', '').css({'cursor': 'pointer', 'pointer-events': 'none'}); // remove the href attribute so
        // that the link is not clickable
        jq(this).unbind("click"); // remove the click event enabling the editing of the patient identifier
        jq(this).removeClass('editPatientIdentifier'); // also remove the class in case this script is loaded before the
        // onclick is added
    });

    // change the first em to the text National ID
    jq('em:contains("Patient ID")').text("National ID");

    /* Add validation rule for Uganda phone numbers, once applied to an element will validate the format and show a message
     */
    jQuery.validator.addMethod("ugphone", function (phone_number, element) {
        phone_number = phone_number.replace(/\(|\)|\s+|-/g, "");
        return this.optional(element) || phone_number.length == 10 &&
            phone_number.match(/^[0-9]{1,10}$/);
    }, "Please specify a valid mobile number without any spaces like 0712345678");

    jQuery.validator.addMethod("nationalid", function (nationalid, element) {
        nationalid = nationalid.replace(/\(|\)|\s+|-/g, "");
        return this.optional(element) || nationalid.match(/^$|^[A-Z][FM]\d{5}([A-Z0-9]){7}$/);
    }, "Enter a valid National ID example CF12345678ABCD");


    /* Validation of NIN on patient registration page */
    jQuery("#registration").validate({
        rules: {
            confirm_nationalid: {
                equalTo: "nationalid"
            }
        },
        messages: {
            confirm_nationalid: {
                equalTo: "Please confirm the National ID you have entered"
            }
        }
    });

    /* Reconfigure the toast message to stay for 15 seconds instead of the default 3 seconds */
    jq().toastmessage({stayTime: 15000});
});


/**
 * Difference in Dates in months
 * @param dt2
 * @param dt1
 * @returns {number}
 */
function diff_months(dt2, dt1) {
    var diff = (dt2.getTime() - dt1.getTime()) / 1000;
    diff /= (60 * 60 * 24 * 7 * 4);
    return Math.abs(Math.round(diff));
}

/**
 * Changes a field date in the format yy-mm-dd to dd/mm/yy which is easier to read
 * @param dateValue
 */
function changeFieldDateToJavascriptDate(dateValue) {
    return jq.datepicker.formatDate('dd/mm/yy', jq.datepicker.parseDate('yy-mm-dd', dateValue));
}

/**
 * Format a date for display on the screen
 *
 * TODO: Replace this with a function from OpenMRS JS Library
 * @param date
 * @returns {*}
 */
function formatDateForDisplay(date) {
    return jq.datepicker.formatDate('dd/mm/yy', date);
}


/**
 *
 * @param prime What to test
 * @param factor What to be tested
 * @param alternative_factor this is used when factorRequired is true and factor is expected to be null
 * @param message_to_throw
 * @param condition for example greater_than,less_than,equal_to,greater_or_equal,less_or_equal,not_equal
 * @param factorRequired this
 * @returns {boolean}
 */
function dateValidator(prime, factor, alternative_factor, message_to_throw, alternative_message_to_throw, condition, factorRequired) {
    var evaluationResult = true;

    getField(prime + '.error').html("").hide;

    if (getValue(factor + '.value') === '' && getValue(prime + '.value') !== '' && factorRequired === true) {
        getField(factor + '.error').html("Can Not Be Null").show;
        evaluationResult = false;
        jq().toastmessage('showErrorToast', "Date Can Not Be Null ");
    }
    else if (getValue(factor + '.value') === '' && getValue(alternative_factor + '.value') === '' && getValue(prime + '.value') !== '' && factorRequired == false) {
        getField(alternative_factor + '.error').html("Can Not Be Null").show();
        evaluationResult = false;
        jq().toastmessage('showErrorToast', "Date Can Not Be Null ");
    }

    if (getValue(factor + '.value') === '' && getValue(alternative_factor + '.value') !== "" && factorRequired === false) {
        factor = alternative_factor;
        message_to_throw = alternative_message_to_throw;
    }

    if (getValue(prime + '.value') !== '' && getValue(factor + '.value') !== '') {
        <!-- has a value -->

        switch (condition) {
            case "greater_than":
                if (getValue(prime + '.value') > getValue(factor + '.value')) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
            case "less_than":
                if (getValue(prime + '.value') < getValue(factor + '.value')) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
            case "equal_to":
                if (!(getValue(prime + '.value') === getValue(factor + '.value'))) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
            case "greater_or_equal":
                if (getValue(prime + '.value') >= getValue(factor + '.value')) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
            case "less_or_equal":
                if (getValue(prime + '.value') <= getValue(factor + '.value')) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
            case "not_equal":
                if (getValue(prime + '.value') !== getValue(factor + '.value')) {
                    getField(prime + '.error').html(message_to_throw).show();
                    evaluationResult = false;
                    jq().toastmessage('showErrorToast', message_to_throw);
                }
                break;
        }

    }
    return evaluationResult;
}


/**
 *
 * @param prime What to test
 * @param factor What to be tested
 * @param alternative_factor this is used when factorRequired is true and factor is expected to be null
 * @param message_to_throw
 * @param condition for example greater_than,less_than,equal_to,greater_or_equal,less_or_equal,not_equal
 * @param factorRequired this
 * @returns {boolean}
 */
function validateRequiredField(prime, factor, message_to_throw, input_type) {
    var evaluationResult = true;
    var selected_value = null;
    getField(prime + '.error').html("").hide;

    if (input_type === "select") {
        selected_value = jq("#" + factor).find(":selected").text().trim().toLowerCase();
        if (selected_value !== '' && getValue(prime + '.value') === '') {
            getField(prime + '.error').html(message_to_throw).show;
            jq('#' + prime).find("span").removeAttr("style");
            evaluationResult = false;
            jq().toastmessage('showErrorToast', message_to_throw);
        }
    }
    else if (input_type === "hidden") {
        selected_value = jq("#" + factor).find("input:hidden").val();
        if (selected_value !== '' && getValue(prime + '.value') === '') {
            getField(prime + '.error').html(message_to_throw).show;
            jq('#' + prime).find("span").removeAttr("style");
            evaluationResult = false;
            jq().toastmessage('showErrorToast', message_to_throw);
        }
    }
    else if (input_type === "check_box") {
        selected_value = jq("#" + factor).find(":checkbox:first");
        if (selected_value.prop('checked') && getValue(prime + '.value') === '') {
            getField(prime + '.error').html(message_to_throw).show;
            jq('#' + prime).find("span").removeAttr("style");
            evaluationResult = false;
            jq().toastmessage('showErrorToast', message_to_throw);
        }
    }
    else if (input_type === "text") {
        selected_value = selected_value = jq("#" + factor).find("input:text").val();
        if (selected_value !== "" && getValue(prime + '.value') === '') {
            getField(prime + '.error').html(message_to_throw).show;
            jq('#' + prime).find("span").removeAttr("style");
            evaluationResult = false;
            jq().toastmessage('showErrorToast', message_to_throw);
        }
    }
    return evaluationResult;
}


/*
 * Hide the container, and disable all elements in it
 *
 * @param the Id of the container
 */
function hideContainer(container) {
    jq(container).addClass('hidden');
    jq(container + ' :input').attr('disabled', true);
    jq(container + ' :input').prop('checked', false);
}

/*
 * Show the container, and enable all elements in it
 *
 * @param the Id of the container
 */
function showContainer(container) {
    jq(container).removeClass('hidden');
    jq(container + ' :input').attr('disabled', false);
    jq(container + ' :input').prop('checked', false);
}


function enableContainer(container) {
    jq(container).find("input").attr("disabled", false);
    jq(container).find('select').attr("disabled", false);
}

/*
 * Show the container, and enable all elements in it
 *
 * @param the Id of the container
 */
function disableContainer(container) {
    jq(container).find("input").attr("disabled", true);
    jq(container).find('select').attr("disabled", true);
}


/*
 *This is a helper object that contains functions to perform basic functions on a form field
 *
 *@param: selector string or JQuery object
 */
var fieldHelper = {
    $jqObj: function () {
        return {};
    },
    disable: function (args) {
        if (args instanceof jQuery) {
            this.$jqObj = args;
        } else if (typeof args === 'string') {
            this.$jqObj = jq(args);
        }

        this.$jqObj.attr('disabled', true).fadeTo(250, 0.25);

    },
    enable: function (args) {
        if (args instanceof jQuery) {
            this.$jqObj = args;
        } else if (typeof args === 'string') {
            this.$jqObj = jq(args);
        }

        this.$jqObj.removeAttr('disabled').fadeTo(250, 1);
    },
    makeReadonly: function (args) {
        if (args instanceof jQuery) {
            this.$jqObj = args;
        } else if (typeof args === 'string') {
            this.$jqObj = jq(args);
        }

        this.$jqObj.attr('readonly', true).fadeTo(250, 0.25);
    },
    removeReadonly: function (args) {
        if (args instanceof jQuery) {
            this.$jqObj = args;
        } else if (typeof args === 'string') {
            this.$jqObj = jq(args);
        }

        this.$jqObj.removeAttr('readonly').fadeTo(250, 1)
    },
    clear: function (args) {
        if (args instanceof jQuery) {
        	this.$jqObj = args;
        } else if (typeof args === 'string') {
        	this.$jqObj = jq(args);
        }
        if (this.$jqObj.is('input[type=text], select')) {
        	this.$jqObj.val('');
        } else if (this.$jqObj.is('input[type="radio"], input[type="checkbox"]')) {
        	this.$jqObj.removeAttr('checked');
        }

    },
    clearAllFields: function (args) {
        if (args instanceof jQuery) {
        	this.$jqObj = args;
        } else if (typeof args === 'string') {
        	this.$jqObj = jq(args);
        }

        this.$jqObj.find('input[type="text"], select').val('').change();

        this.$jqObj.find('input[type="radio"], input[type="checkbox"]').removeAttr('checked');
    },
    customizeDateTimePickerWidget: function(args) {
        //Remove the colon(:) in the date time picker
        if (args instanceof jQuery) {
	        this.$jqObj = args;
        } else if (typeof args === 'string') {
	        this.$jqObj = jq(args);
        }

        this.$jqObj.contents().filter(function() {
	      return this.nodeType === 3;
	    }).remove();


	    // Insert label for time just before the timepicker field
	    var $timeLabel = jq('<label/>').html('Time');
	    $('.hfe-hours').before($timeLabel);
    }
};

function blockEncounterOnSameDateEncounter(encounterDate, instruction) {

    if (!(instruction == 'block' || instruction == 'warn'))
        return;

    var date = jq(encounterDate).val();
    var formId = jq('[name=htmlFormId]').val();
    var patientId = jq('[name=personId]').val();

    if (jq('[name=encounterId]').val() == null) {
        jq.get(
            getContextPath() + '/module/ugandaemr/lastEnteredForm.form',
            {formId: formId, patientId: patientId, date: date, dateFormat: 'yyyy-MM-dd'},
            function (responseText) {

                if (responseText == "true") {
                    if (instruction == "warn") {

                        // get the localized warning message and display it
                        jq.get(getContextPath() + "/module/htmlformentry/localizedMessage.form",
                            {messageCode: "htmlformentry.error.warnMultipleEncounterOnDate"},
                            function (responseText) {
                                jq().toastmessage('showWarningToast', responseText);
                            }
                        );

                    } else if (instruction == "block") {

                        // get the localized blocking message and display it
                        jq.get(getContextPath() + "/module/htmlformentry/localizedMessage.form",
                            {messageCode: "htmlformentry.error.blockMultipleEncounterOnDate"},
                            function (responseText) {
                                jq().toastmessage('showWarningToast', responseText);
                                var parameters = window.location.search.split("&", 2);
                                var url = window.location.origin + "/" + OPENMRS_CONTEXT_PATH + "/" + "coreapps/patientdashboard/patientDashboard.page" + parameters[0] + "&" + parameters[1] + "&";
                                setTimeout(function () {
                                    window.location.href = url;
                                }, 2000);

                            }
                        );

                        //clear the date and continue entering the form
                        jq(encounterDate).val('');
                    }
                } else {
                    //make sure everything is enabled
                }
            }
        );
    }
}

// Disable inputs and add grey background on them
function disable_fields(elementId) {

    var element = jq("#" + elementId);

    /* clear the input fields */
    element.find("input[type='text']").val('');
    element.find("input[type$='checkbox']").prop("checked", false);
    element.find("input[type='radio']").prop("checked", false);

    /* disable input fields */
    element.find("input").attr("disabled", true);
    element.find('select').attr("disabled", true);

    /* fade out the fields that are disabled */
    element.addClass("html-form-entry-disabled-field");
}

// Enable inputs and remove grey background from them*/
function enable_fields(elementId) {

    var element = jq("#" + elementId);
    element.find("input").attr("disabled", false);
    element.find('select').attr("disabled", false);
    element.removeClass("html-form-entry-disabled-field");
}

function enable_disable_fm(selected_option) {

    var class_name = jq(selected_option).attr("class");

    var length = class_name.length;

    var class_id = parseInt(class_name.substring(length - 1, length));

    var row_id = class_id;

    var disable = true;
    var disable1 = true;

    var row_1 = '[class^="FamilyMember"][class*="Children1"]';
    var row_2 = '[class^="FamilyMember"][class*="Children2"]';
    var row_3 = '[class^="FamilyMember"][class*="Children3"]';
    var row_4 = '[class^="FamilyMember"][class*="Children4"]';
    var row_5 = '[class^="FamilyMember"][class*="Children5"]';

    var xx = row_1;
    var selected_value = jq(selected_option).find(":selected").text();


    if (selected_value == "P") {
        disable = false;
    } else if (selected_value == "Y") {
        disable1 = false;
    }

    switch (row_id) {
        case 1:
            xx = row_1;
            break;
        case 2:
            xx = row_2;
            break;
        case 3:
            xx = row_3;
            break;
        case 4:
            xx = row_4;
            break;
        case 5:
            xx = row_5;
            break;
    }


    jq(xx).each(function () {
        var group = jq(this);
        if (class_name.indexOf('Children') == -1) {
            /* group.find('select').prop("selectedIndex", 0);*/
            group.find('select').attr("disabled", disable);
            if (disable) {
                /* fade out the fields that are disabled*/
                group.find("select").fadeTo(250, 0.25);
            } else {
                /* remove the fade on the fields*/
                group.find("select").fadeTo(250, 1);
            }
        }
        if (class_name.indexOf('GrandChildren') == -1) {
            /* group.find("input").attr("value", "");*/
            group.find("input").attr("disabled", disable1);

            if (disable1) {
                /* fade out the fields that are disabled*/
                group.find("input").fadeTo(250, 0.25);
            } else {
                /* remove the fade on the fields*/
                group.find("input").fadeTo(250, 1);
            }
        }

    });

}

function enable_disable(field, class_name_prefix, conditions, input_type) {

    var class_name = jq(field).attr("class");

    var length = class_name.length;

    var class_id = parseInt(class_name.substring(length - 1, length));
    var childClass = "Child" + class_id;

    var disable = true;
    var requires = true;

    var row = '[class^="' + class_name_prefix + '"][class*="' + childClass + '"]';

    var selected_value = null;

    if (input_type == "select") {
        selected_value = jq(field).find(":selected").text().trim().toLowerCase();
    } else if (input_type == "hidden") {
        selected_value = jq(field).find("input[type=hidden]").val().trim().toLowerCase();
    }


    if (eval(conditions)) {
        disable = false;
    }


    jq(row).each(function () {
        var group = jq(this);

        if (class_name.indexOf('Child') == -1) {
            /*group.find("input").attr("value", ""); */
            /* group.find('select').prop("selectedIndex", 0);*/
            group.find("input").attr("disabled", disable);
            group.find('select').attr("disabled", disable);

            if (disable) {
                /* fade out the fields that are disabled */
                group.find("input").fadeTo(250, 0.25);
                group.find("select").fadeTo(250, 0.25);
            } else {
                /* remove the fade on the fields */
                group.find("input").fadeTo(250, 1);
                group.find("select").fadeTo(250, 1);
            }
        }
    });

    jq(".checkboxGroup").each(function () {
        var group = jq(this);
        var uncheckAll = function () {
            group.find("input[type$='checkbox']").attr("checked", false);
            group.find("input[type$='checkbox']").change();
        }

        var uncheckRadioAndAll = function () {
            group.find("#checkboxAll,#checkboxRadio").find("input[type$='checkbox']").attr("checked", false);
            group.find("#checkboxAll,#checkboxRadio").find("input[type$='checkbox']").change();
        }


        group.find("#checkboxAll").find("input").click(
            function () {
                var flip;
                var checked = jq(this).siblings(":checkbox:first").attr("checked");
                if (jq(this).attr("name") == jq(this).parents("#checkboxAll:first").find(":checkbox:first").attr("name")) {
                    checked = jq(this).attr("checked");
                    flip = checked;
                } else {
                    flip = !checked;
                }
                if (jq.attr("type") == "text") if (flip == false) flip = !filp;
                /* this is so the user doesn't go to check thecheckbox, then uncheck it when they hit the input.uncheckAll();*/
                jq(this).parents("#checkboxAll:first").find(":checkbox").attr("checked", flip);
                jq(this).parents("#checkboxAll:first").find(":checkbox").change();
            }
        );


        group.find("#checkboxRadio").find("input[type$='checkbox']").click(function () {
            uncheckAll();
            jq(this).siblings("input[type$='checkbox']").attr("checked", false);
            jq(this).attr("checked", true);
            jq(this).change();
        });

        group.find("#checkboxCheckbox").click(
            function () {
                uncheckRadioAndAll();
            }
        );
    });
}

/* Determine MUAC color code from muac score and age */
function getMUACCodeFromMUACScoreByAge(age, muacScoreFieldId, muacCodeFieldId) {

    jq("#" + muacScoreFieldId).find("input[type$='text']").change(function () {

        var muacScore = jq(this).val().trim();

        if (muacScore == " " || muacScore == 0) {
            jq("#" + muacCodeFieldId).find("select").val(" ").attr("selected", "selected")
            return false;
        }

        if (age < 5) {

            if (muacScore < 11.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if (muacScore >= 11.5 && muacScore < 12.5) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if (muacScore >= 12.5) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }
        }

        if (age >= 5 && age < 10) {

            if (muacScore < 13.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if (muacScore >= 13.5 && muacScore < 14.5) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if (muacScore >= 14.5) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }

        }

        if (age >= 10 && age < 18) {

            if (muacScore < 16.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if (muacScore >= 16.5 && muacScore < 19) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if (muacScore >= 19) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }

        }

        if (age >= 18) {

            if (muacScore < 19) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if (muacScore >= 19 && muacScore < 22) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if (muacScore >= 22) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }
        }

        jq("#" + muacCodeFieldId).change(function () {
            jq("#" + muacScoreFieldId).find("input[type$='text']").val("");
        })
    });
}

/* Get period between two dates */
function periodBetweenDates(firstDate, secondDate) {
    var period = (secondDate.getTime() - firstDate.getTime()) / 1000;
    period /= (60 * 60 * 24 * 7 * 4);
    return Math.abs(Math.round(period));
}

//Disable encounter date field.
function disableEncounterDate() {
    $encounterDateField = jq('#encounterDate').find('input[type="text"]');
    $encounterDateField.addClass('disabled');
    $encounterDateField.attr('disabled', 'disabled');
}

//Get Waiting Time For Patient In Queue
function getWaitingTime(queueDate, completedDate) {
    var diff = null;

    if (completedDate != null) {
        diff = Math.abs(new Date(completedDate) - new Date(queueDate));
    } else {
        diff = Math.abs(new Date() - new Date(queueDate));
    }

    var seconds = Math.floor(diff / 1000); //ignore any left over units smaller than a second
    var minutes = Math.floor(seconds / 60);
    var waitingTime = "";
    seconds = seconds % 60;
    var hours = Math.floor(minutes / 60);
    minutes = minutes % 60;

    if (hours > 0 || minutes > 60) {
        waitingTime = "<span style='background-color: red; color: white; width: 100%; text-align: center;'>" + hours + ":" + minutes + ":" + seconds + "</span>";
    } else {
        waitingTime = "<span style='background-color:green; color: white; width: 100%; text-align: center;'>" + hours + ":" + minutes + ":" + seconds + "</span>";
    }
    return waitingTime;
}

function disable_enable_on_edit_mode(field_id) {
    if (getValue(field_id + '.value') === "") {
        disable_fields(field_id);
    } else {
        enable_fields(field_id);
    }
}

//Returns the Current TB Program is it is valid or redirects the user to the patients dashboard when there is no program or when the program does not meet the criteria
function getCurrentTBProgramOrBlockEncounter(patientUUID, visitDate, serverResponse, tbInfectionTypeConceptUUID, messageNotInTbProgram, messageWrongTBInfection) {

    var currentProgram = null;
    var previousPrograms = null;
    var tbProgramUUID = "9dc21a72-0971-11e7-8037-507b9dc4c741";

    for (var i = 0; i < serverResponse.length; i++) {
        var obj = serverResponse[i];
        if (obj.program.uuid === tbProgramUUID && obj.dateCompleted === null && ((new Date(visitDate)) >= (new Date(obj.dateEnrolled)))) {
            currentProgram = obj;
        } else if (obj.program.uuid === tbProgramUUID && obj.dateCompleted !== "" && ((new Date(visitDate))
            <= (new Date(obj.dateCompleted))) && ((new Date(visitDate)) >= (new Date(obj.dateEnrolled)))) {
            previousPrograms = obj;
        }
    }

    if (currentProgram === null && previousPrograms !== null) {
        currentProgram = previousPrograms;
    }

    //Block encounter if there is no active program which ended before visit date//

    if (currentProgram === null) {
        alert(messageNotInTbProgram);
        location.href = window.location.protocol + "//" + window.location.host +
            '/' + OPENMRS_CONTEXT_PATH + '/coreapps/clinicianfacing/patient.page?patientId=' + patientUUID;
    } else if (currentProgram !== null) {
        var tbInfectionType = [];
        for (var x = 0; x < currentProgram.states.length; x++) {
            var obj = currentProgram.states[x];
            if (obj.state.concept.uuid === tbInfectionTypeConceptUUID) {
                tbInfectionType.push(obj);
            }
        }

        if (tbInfectionType.length < 1) {
            alert(messageWrongTBInfection);
            location.href = window.location.protocol + "//" + window.location.host +
                '/' + OPENMRS_CONTEXT_PATH + '/coreapps/clinicianfacing/patient.page?patientId=' + patientUUID;
        } else {
            return currentProgram;
        }
    }
}

function getCurrentTBProgram(patientUUID, visitDate, serverResponse) {

    var currentProgram = null;
    var previousPrograms = null;
    var tbProgramUUID = "9dc21a72-0971-11e7-8037-507b9dc4c741";

    for (var i = 0; i < serverResponse.length; i++) {
        var obj = serverResponse[i];
        if (obj.program.uuid === tbProgramUUID && obj.dateCompleted === null && ((new Date(visitDate)) >= (new Date(obj.dateEnrolled)))) {
            currentProgram = obj;
        } else if (obj.program.uuid === tbProgramUUID && obj.dateCompleted !== "" && ((new Date(visitDate))
            <= (new Date(obj.dateCompleted))) && ((new Date(visitDate)) >= (new Date(obj.dateEnrolled)))) {
            previousPrograms = obj;
        }
    }

    if (currentProgram === null && previousPrograms !== null) {
        currentProgram = previousPrograms;
    }

    //Block encounter if there is no active program which ended before visit date//

    return currentProgram;
}


function getCurrentWorkflowState(visitDate, currentProgram, stateConceptUUID) {
    var currentProgramState = null;

    if (currentProgram !== null) {

        for (var x = 0; x < currentProgram.states.length; x++) {
            var obj = currentProgram.states[x];
            if (obj.state.concept.uuid === stateConceptUUID && (obj.endDate === null || (obj.endDate !== null && (new Date(visitDate)) <= (new Date(obj.endDate)))) && ((new Date(visitDate)) >= (new Date(obj.startDate)))) {
                currentProgramState = obj;
            }
        }
    }
    return currentProgramState;
}


function getLatestEncounterFromEncounterList(encounterList) {
    var latestEncounter = null;
    for (var i = 0; i < encounterList.length; i++) {
        var encounter = encounterList[i];
        if (latestEncounter === null) {
            latestEncounter = encounter;
        } else if ((new Date(latestEncounter.encounterDatetime)) < (new Date(encounter.encounterDatetime))) {
            latestEncounter = encounter;
        }
    }
    return latestEncounter
}

/**
 *
 * function returns the name of the Encounter type Uuid passed
 * @param encounterType Uuid
 * @returns {string} Naame of Encounters
 */
function getEncounterTypeName(encounterType) {
    var encounterTypeName="";
    jq.ajax({
        type: "GET",
        url: '/' + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encountertype/"+encounterType+"?v=custom:(name)",
        dataType: "json",
        contentType: "application/json;",
        async: false,
        success: function (data) {
            encounterTypeName = data.name;
        }
    });
    return encounterTypeName;
}
