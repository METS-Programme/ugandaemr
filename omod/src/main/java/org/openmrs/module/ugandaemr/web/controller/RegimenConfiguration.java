package org.openmrs.module.ugandaemr.web.controller;

public class RegimenConfiguration {
    private ClassLoader classLoader;
    private String moduleId;
    private String definitionsPath;

    // Constructors, getters, and setters

    public RegimenConfiguration(ClassLoader classLoader, String moduleId, String definitionsPath) {
        this.classLoader = classLoader;
        this.moduleId = moduleId;
        this.definitionsPath = definitionsPath;
    }

    public ClassLoader getClassLoader() {
        return classLoader;
    }

    public void setClassLoader(ClassLoader classLoader) {
        this.classLoader = classLoader;
    }

    public String getModuleId() {
        return moduleId;
    }

    public void setModuleId(String moduleId) {
        this.moduleId = moduleId;
    }

    public String getDefinitionsPath() {
        return definitionsPath;
    }

    public void setDefinitionsPath(String definitionsPath) {
        this.definitionsPath = definitionsPath;
    }
}