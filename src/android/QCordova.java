package com.q.cordova.plugin;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;

public class QCordova extends CordovaPlugin {
    private static int Q_CHOOSE_LINK_ACTIVITY_CODE = 1010;
    private static int Q_CHOOSE_IMAGE_ACTIVITY_CODE = 1011;
    private static CallbackContext qChooseLinkCallbackContext;
    private static CallbackContext qChooseImageCallbackContext;
    public static String contentHTML;

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if(action.equals("readQConfigValue")) {
            String key = data.getString(0);
            callbackContext.success(QConfig.getInstance(cordova.getActivity()).getConfigValue(key));
            return true;
        } else if(action.equalsIgnoreCase("openUrlScheme")) {
            Intent intent = cordova.getActivity().getIntent();
            Uri uriData = intent.getData();
            String scheme = uriData.getScheme();
            callbackContext.success(scheme);
            return true;
        } else if(action.equals("info")) {
            JSONObject object = new JSONObject();

            QConfig config = QConfig.getInstance(cordova.getActivity().getApplicationContext());
            object.put("Q.appId", config.getPackageName());
            object.put("Q.udid", config.getUdid());
            callbackContext.success(object);
            return true;
        } else if(action.equals("setSelectMenuShown")) {
            boolean isEnable = data.getBoolean(0);
            QActivity.enableSelectContexMenu = isEnable;
            callbackContext.success();
            return true;
        } else if(action.equals("chooseLink")) {
            String initUrl = data.getString(0);
            qChooseLinkCallbackContext = callbackContext;
            cordova.setActivityResultCallback(this);
            cordova.getActivity().startActivityForResult(QChooseLinkActivity.createIntent(cordova.getContext(), initUrl), Q_CHOOSE_LINK_ACTIVITY_CODE);
            return true;
        } else if(action.equals("chooseImage")) {
            String initUrl = data.getString(0);
            qChooseImageCallbackContext = callbackContext;
            cordova.setActivityResultCallback(this);
            cordova.getActivity().startActivityForResult(QChooseImageActivity.createIntent(cordova.getContext(), initUrl), Q_CHOOSE_IMAGE_ACTIVITY_CODE);
            return true;
        } else if(action.equalsIgnoreCase("changeInnerUrlEvent")) {
            callbackContext.error("Not implemented. This method only uses in Android");
            return true;
        }  else if(action.equalsIgnoreCase("schema")) {
            callbackContext.error("Not implemented. This method only uses in Android");
            return true;
        } else if(action.equalsIgnoreCase("chooseImageEvent")) {
            String imageUrl = data.getString(0);
            cordova.getActivity().startActivity(QChooseImageActivity.createIntentWithImageUrl(cordova.getContext(), imageUrl));
            callbackContext.success("Ok");
            return true;
        }

        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if(requestCode == Q_CHOOSE_LINK_ACTIVITY_CODE && qChooseLinkCallbackContext != null) {
            if(resultCode == RESULT_OK
                    && intent.hasExtra(QCordovaAbstractActivity.URL_KEY)
                    && contentHTML != null) {
                String url = intent.getStringExtra(QCordovaAbstractActivity.URL_KEY);
                String html = contentHTML;
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("link", url);
                    jsonObject.put("html", html);
                    qChooseLinkCallbackContext.success(jsonObject);
                } catch (JSONException e) {
                    qChooseLinkCallbackContext.error("Error creating JSON object to return result");
                }
            } else if(resultCode == RESULT_CANCELED) {
                qChooseLinkCallbackContext.error("Canceled");
            }
            contentHTML = null;
            qChooseLinkCallbackContext = null;
            return;
        } else if(requestCode == Q_CHOOSE_IMAGE_ACTIVITY_CODE && qChooseImageCallbackContext != null) {
            if(resultCode == RESULT_OK
                    && intent.hasExtra(QCordovaAbstractActivity.URL_KEY)
                    && contentHTML != null) {
                String url = intent.getStringExtra(QCordovaAbstractActivity.URL_KEY);
                String html = contentHTML;
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("link", url);
                    jsonObject.put("html", html);
                    qChooseImageCallbackContext.success(jsonObject);
                } catch (JSONException e) {
                    qChooseImageCallbackContext.error("Error creating JSON object to return result");
                }
            } else if(resultCode == RESULT_CANCELED) {
                qChooseImageCallbackContext.error("Canceled");
            }
            contentHTML = null;
            qChooseImageCallbackContext = null;
            return;
        }
        super.onActivityResult(requestCode, resultCode, intent);
    }
}
