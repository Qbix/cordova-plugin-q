package com.q.cordova.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class QCordova extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if(action.equals("readQConfigValue")) {
            String key = data.getString(0);
            callbackContext.success(QConfig.getInstance(cordova.getActivity()).getConfigValue(key));
            return true;
        } else if(action.equals("info")) {
            JSONObject object = new JSONObject();

            QConfig config = QConfig.getInstance(cordova.getActivity().getApplicationContext());
            object.put("Q.appId", config.getPackageName());
            object.put("Q.udid", config.getUdid());
            callbackContext.success(object);
            return true;
        }

        return false;
    }
}
