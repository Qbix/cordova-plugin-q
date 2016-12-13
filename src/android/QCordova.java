package com.q.cordova.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

public class QCordova extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if(action.equals("readQConfigValue")) {
            String key = data.getString(0);
            callbackContext.success(QConfig.getInstance(cordova.getActivity()).getConfigValue(key));
            return true;
        }

        return false;
    }
}
