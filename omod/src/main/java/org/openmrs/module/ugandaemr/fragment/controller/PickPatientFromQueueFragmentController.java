package org.openmrs.module.ugandaemr.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.ui.framework.SimpleObject;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class PickPatientFromQueueFragmentController {

    protected final Log log = LogFactory.getLog(getClass());

    public PickPatientFromQueueFragmentController() {
    }

    public void controller() {

    }

    public SimpleObject getCurrentDateTime() {
        SimpleObject simpleObject = new SimpleObject();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        String dateStr = sdf.format(new Date());
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            simpleObject.put("currentDateTime", objectMapper.writeValueAsString(dateStr));
        } catch (IOException e) {
           log.error(e);
        }
        return simpleObject;
    }
}
