package org.openmrs.module.ugandaemr.api.queuemapper;

import java.io.Serializable;

public class Identifier implements Serializable {
    String identifier;
    String identifierTypeName;
    String identifierTypeUuid;

    String identifierLocationUuid;

    public Identifier(String identifier, String identifierTypeName, String identifierTypeUuid) {
        this.identifier = identifier;
        this.identifierTypeName = identifierTypeName;
        this.identifierTypeUuid = identifierTypeUuid;
    }

    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(String identifier) {
        this.identifier = identifier;
    }

    public String getIdentifierTypeName() {
        return identifierTypeName;
    }

    public void setIdentifierTypeName(String identifierTypeName) {
        this.identifierTypeName = identifierTypeName;
    }

    public String getIdentifierTypeUuid() {
        return identifierTypeUuid;
    }

    public void setIdentifierTypeUuid(String identifierTypeUuid) {
        this.identifierTypeUuid = identifierTypeUuid;
    }


    public String getIdentifierLocationUuid() {
        return identifierLocationUuid;
    }

    public void setIdentifierLocationUuid(String identifierLocationUuid) {
        this.identifierLocationUuid = identifierLocationUuid;
    }
}
