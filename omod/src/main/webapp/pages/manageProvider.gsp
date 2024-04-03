<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "bootstrap-collapse.js")
    ui.includeJavascript("uicommons", "bootstrap-transition.js")
    ui.includeCss("uicommons", "styleguide/index.styles")
    ui.includeCss("uicommons", "datatables/dataTables_jui.styles")
%>
<script type="text/javascript">
    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {
            label: "${ ui.message("coreapps.app.systemAdministration.label")}",
            link: '/' + OPENMRS_CONTEXT_PATH + '/coreapps/systemadministration/systemAdministration.page'
        }, {label: "Manage Provider"}
    ];

    jq(document).ready(function () {
    });


</script>

<script>
var providerAttributeType=null;
var provider=null;
    if (jQuery) {
        jq(document).ready(function () {
            jq('#editProviderModel').on('show.bs.modal', function (event) {
                providerAttributeType=null;
                provider=null;
                jq("#provideruuid").val("");
                jq("#providerName").html("");
                jq("#attribute_type_fields").html("");


                var button = jq(event.relatedTarget);
                var provideruuid = button.data('providerid');
                var attributesToRender = "";

                jq("#provideruuid").val(provideruuid);
                provider = queryRestData("/ws/rest/v1/provider/" + provideruuid + "?v=full","GET",null);
                providerAttributeType = queryRestData("/ws/rest/v1/providerattributetype?v=custom:(uuid,name,minOccurs,maxOccurs,datatypeClassname,preferredHandlerClassname,handlerConfig)","GET",null)

                jq("#providerName").append(provider.name);

                providerAttributeType.results.forEach(function (attributeType, index) {
                    if (attributeType.datatypeClassname !== null && attributeType.datatypeClassname === "org.openmrs.customdatatype.datatype.BooleanDatatype") {
                        attributesToRender += booleanFieldRender(attributeType, provider.attributes);
                    } else if (attributeType.datatypeClassname !== null && attributeType.datatypeClassname === "org.openmrs.customdatatype.datatype.LocationDatatype" && attributeType.preferredHandlerClassname === "org.openmrs.web.attribute.handler.LocationFieldGenDatatypeHandler") {
                        attributesToRender += locationFieldRender(attributeType, provider.attributes)
                    } else if (attributeType.datatypeClassname !== null && attributeType.datatypeClassname === "org.openmrs.customdatatype.datatype.SpecifiedTextOptionsDatatype" && attributeType.preferredHandlerClassname === "org.openmrs.web.attribute.handler.SpecifiedTextOptionsDropdownHandler" && attributeType.handlerConfig !== null) {
                        attributesToRender += freeTextOptionFieldRender(attributeType, provider.attributes)
                    }
                });

                jq("#attribute_type_fields").append(attributesToRender);
            });
        });

        function booleanFieldRender(attributeType, providerAttributes) {
            var fieldBuilder = ""
            var selectedOption = providerAttributeDefault(attributeType, providerAttributes);
            var checked_true = "";
            var checked_false = "";

            if (selectedOption !== null && selectedOption.value === true) {
                checked_true = "checked";
            } else if (selectedOption !== null && selectedOption.value === false) {
                checked_false = "checked"
            }

            fieldBuilder += '<div class="row provider-row">'
            fieldBuilder += '<div class="col-5">'
            fieldBuilder += '' + attributeType.name + ''
            fieldBuilder += '</div>'
            fieldBuilder += '<div class="col-5" id="' + attributeType.uuid + '">'
            fieldBuilder += '<span class="form-check form-check-inline"> <input class="form-check-input" type="radio" name="' + attributeType.uuid + '" id="' + attributeType.uuid + '_true" value="true"' + checked_true + '> <label class="form-check-label" for="' + attributeType.uuid + '_true">Yes</label> </span>'
            fieldBuilder += '<span class="form-check form-check-inline"> <input class="form-check-input" type="radio" name="' + attributeType.uuid + '" id="' + attributeType.uuid + '_false" value="false"' + checked_false + '> <label class="form-check-label" for="' + attributeType.uuid + '_false">No</label> </span>'
            fieldBuilder += '</div>'
            fieldBuilder += '</div>'
            return fieldBuilder
        }

        function locationFieldRender(attributeType, providerAttributes) {
            var location = queryRestData("/ws/rest/v1/location/629d78e9-93e5-43b0-ad8a-48313fd99117?v=full","GET",null)
            var fieldBuilder = ""
            fieldBuilder += '<div class="row provider-row">'
            fieldBuilder += '<div class="col-5">'
            fieldBuilder += '' + attributeType.name + ''
            fieldBuilder += '</div>'
            fieldBuilder += '<div class="col-5">'
            fieldBuilder += '<select name="' + attributeType.uuid + '" id="' + attributeType.uuid + '">'
            fieldBuilder += '<option value="">Select ' + attributeType.name + '</option>'
            fieldBuilder += '' + buildIndentedSelect(location, providerAttributeDefault(attributeType, providerAttributes)) + ''
            fieldBuilder += '</select>'
            fieldBuilder += '</div>'
            fieldBuilder += '</div>'
            return fieldBuilder
        }

        function providerAttributeDefault(attributeType, providerAttributes) {
            var selectedProviderAttribute = null;
            providerAttributes.forEach((item, index) => {
                if (item.attributeType.uuid === attributeType.uuid) {
                    selectedProviderAttribute = item;
                }
            })

            return selectedProviderAttribute;
        }

        function freeTextOptionFieldRender(attributeType, providerAttributes) {
            var options = attributeType.handlerConfig.split(",")
            var fieldBuilder = ""
            fieldBuilder += '<div class="row provider-row">'
            fieldBuilder += '<div class="col-5">'
            fieldBuilder += '' + attributeType.name + ''
            fieldBuilder += '</div>'
            fieldBuilder += '<div class="col-5">'
            fieldBuilder += '<select name="' + attributeType.uuid + '" id="' + attributeType.uuid + '">'
            fieldBuilder += '' + buildSelectOptions(attributeType, options, providerAttributeDefault(attributeType, providerAttributes)) + ''
            fieldBuilder += '</select>'
            fieldBuilder += '</div>'
            fieldBuilder += '</div>'
            return fieldBuilder
        }

        function buildSelectOptions(attributeType, options, providerAttributes) {
            var fieldBuilder = ""
            fieldBuilder += '<option value="">Select ' + attributeType.name + '</option>'
            options.forEach((item, index) => {
                if(providerAttributes!==null && providerAttributes.value===item){
                    fieldBuilder += '<option value="' + item + '" selected>' + item + '</option>'
                }else {
                    fieldBuilder += '<option value="' + item + '">' + item + '</option>'
                }
            })
            return fieldBuilder
        }

        function buildIndentedSelect(location, defaultProviderAttribute) {
            var fieldBuilder = ""
            if (defaultProviderAttribute != null && defaultProviderAttribute.value.uuid === location.uuid) {
                fieldBuilder += '<option value="' + location.uuid + '" selected>' + location.display + '</option>'
            } else {
                fieldBuilder += '<option value="' + location.uuid + '">' + location.display + '</option>'
            }

            if (location.childLocations && location.childLocations.length > 0) {
                fieldBuilder += '<optgroup label="' + location.display + ' Options">'
                location.childLocations.forEach((item, index) => {
                    if (item.childLocations && item.childLocations.length > 0) {
                        fieldBuilder += buildIndentedSelect(item, defaultProviderAttribute);
                    } else {
                        if (defaultProviderAttribute != null && defaultProviderAttribute.value.uuid === item.uuid) {
                            fieldBuilder += '<option value="' + item.uuid + '" selected>' + item.display + '</option>'
                        } else {
                            fieldBuilder += '<option value="' + item.uuid + '">' + item.display + '</option>'
                        }
                    }
                })
                fieldBuilder += '</optgroup>'
            }
            return fieldBuilder
        }

        function queryRestData(url,method,data) {
            var responseDate = null;
            jq.ajax({
                type: method,
                url: '/' + OPENMRS_CONTEXT_PATH + url,
                dataType: "json",
                contentType: "application/json",
                accept: "application/json",
                async: false,
                data:data,
                success: function (response) {
                    responseDate = response;
                },
                error: function (response) {
                    responseDate=response
                }
            });
            return responseDate;
        }


        function saveProvider() {
            var providerId = jq("#provideruuid").val()
            var providerToUpdate = {
                "uuid": "" + providerId + "",
                "attributes": []
            }

            providerAttributeType.results.forEach((item, index) => {
                var attribute = buildProviderAttribute(item, provider.attributes);
                if (attribute !== null) {
                    providerToUpdate.attributes.push(attribute)
                }
            })

            queryRestData("/ws/rest/v1/provider/"+providerId+"","POST",JSON.stringify(providerToUpdate))
        }

        function buildProviderAttribute(attributeType, providerAttributes) {
            let attribute = null;
            let value = null;
            const defaultAttributeProviderType = providerAttributeDefault(attributeType, providerAttributes);

            if (attributeType.datatypeClassname !== null && attributeType.datatypeClassname === "org.openmrs.customdatatype.datatype.BooleanDatatype") {
                value = JSON.parse(jq("#" + attributeType.uuid + "").find("input[type='radio']:checked").val())

            } else {
                value = jq("#" + attributeType.uuid  + "").val()
            }

            if (value !== null) {
                if (defaultAttributeProviderType != null) {
                    attribute = {
                        "uuid": defaultAttributeProviderType.uuid,
                        "attributeType": {"uuid": attributeType.uuid},
                        "value": value
                    }
                } else {
                    attribute = {
                        "attributeType": {"uuid": attributeType.uuid},
                        "value": value
                    }
                }
            }
            return attribute;
        }
    }
</script>
<style>
.dashboard .que-container {
    display: inline;
    float: left;
    width: 65%;
    margin: 0 1.04167%;
}

.dashboard .alert-container {
    display: inline;
    float: left;
    width: 30%;
    margin: 0 1.04167%;
}

.dashboard .action-section ul {
    background: #63343c;
    color: white;
    padding: 7px;
}

.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

.vertical {
    border-left: 1px solid #c7c5c5;
    height: 79px;
    position: absolute;
    left: 99%;
    top: 11%;
}

#patient-search {
    min-width: 96%;
    color: #363463;
    display: block;
    padding: 5px 10px;
    height: 45px;
    margin-top: 27px;
    background-color: #FFF;
    border: 1px solid #dddddd;
}

.provider-row {
    display: -ms-flexbox;
    display: flex;
    -ms-flex-wrap: wrap;
    flex-wrap: wrap;
    margin-right: -15px;
    margin-left: -15px;
    margin-top: 10px;
    margin-bottom: 10px;
}
</style>

<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h2 style="color: maroon">Manage Provider Attributes</h2>
                    </div>

                    <div class="vertical"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-search-form" onsubmit="return false">
                        <input type="text" id="patient-search"
                               placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                               autocomplete="off"/>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body">
        <div class="info-body">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>NAME</th>
                    <th>ACTION</th>
                </tr>
                </thead>
                <tbody>
                <% if (providers?.size() > 0) {
                    providers?.each { %>
                <tr>
                    <td>${it?.identifier}</td>
                    <td>${it?.name}</td>
                    <td>
                        <i style="font-size: 25px" data-toggle="modal" data-target="#editProviderModel"
                           data-providerid="${it.uuid}" class="icon-edit edit-action"
                           title="Edit"></i>
                    </td>
                    <% }
                    } %>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="editProviderModel" tabindex="-1" role="dialog"
     aria-labelledby="editProviderModelLabel"
     aria-hidden="true">
    <div class="modal-dialog  modal-lg" role="document">

        <form method="post">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editProviderModelLabel">Edit Provider Attributes</h5>

                    <div id="providerName"></div>
                </div>

                <div class="container">
                    <input type="hidden" name="provideruuid" id="provideruuid" value="">

                    <div class="container" id="attribute_type_fields"></div>

                    <div class="modal-footer" id="submitButtonContainer">
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                        <input type="submit" onclick="saveProvider()" class="confirm" value="${ui.message("Save")}">
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

