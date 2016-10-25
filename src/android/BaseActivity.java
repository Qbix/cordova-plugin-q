package com.q.cordova.plugin;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.webkit.WebView;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by adventis on 3/11/16.
 */
public class BaseActivity extends CordovaActivity {


    protected SystemWebViewEngine getSystemWebEngine() {
        return (SystemWebViewEngine) this.appView.getEngine();
    }

    protected void initSharedCache()  {
            QbixWebViewClient qbixWebViewClient = new QbixWebViewClient(getSystemWebEngine());
            qbixWebViewClient.setIsReturnCahceFilesFromBundle(QConfig.getInstance(this).getEnableLoadBundleCache());
            qbixWebViewClient.setPathToBundle(QConfig.getInstance(this).getPathToBundle());
            qbixWebViewClient.setRemoteCacheId(QConfig.getInstance(this).getRemoteCacheId());

            if(QConfig.getInstance(this).getInjectCordovaScripts()) {
                ArrayList<String> filesToInject = new ArrayList<String>();
                filesToInject.add("www/cordova_plugins.js");

                FileSystemHelper fileSystemHelper = new FileSystemHelper();
                try {
                    fileSystemHelper.recursiveSearchByExtension(getApplicationContext(), "www/plugins", "js");
                } catch (IOException e) {
                    e.printStackTrace();
                }
                ArrayList<String> fileNames = fileSystemHelper.getSearchedFiles();
                filesToInject.addAll(fileNames);

                qbixWebViewClient.setListOfJsInjects(filesToInject);
            }

            ((WebView) getSystemWebEngine().getView()).setWebViewClient(qbixWebViewClient);
    }

    public String prepeareQGroupsController() {
        String remoteUrl = QConfig.getInstance(this).getUrl();

        Map<String, String> additionalParams = getAdditionalParamsForUrl();
        if(additionalParams == null)
            return remoteUrl;


        String paramsString = "";

        for (Map.Entry<String,String> entry : additionalParams.entrySet()) {
            paramsString += (entry.getKey()+"="+entry.getValue()+"&");
        }

        if(!remoteUrl.contains("?")) {
            remoteUrl += "?";
        }

        remoteUrl += paramsString;

        return remoteUrl;
    }

    private Map<String, String> getAdditionalParamsForUrl() {
        Map<String, String> params = new HashMap<String, String>();

        final TelephonyManager tm = (TelephonyManager) getBaseContext().getSystemService(Context.TELEPHONY_SERVICE);
        //params.put("Q.udid", tm.getDeviceId());
        params.put("Q.udid", "TestUdid");

        params.put("Q.cordova", CordovaWebView.CORDOVA_VERSION);
        if(QConfig.getInstance(this).getEnableLoadBundleCache()) {
            params.put("Q.ct", String.valueOf(QConfig.getInstance(this).getBundleTimestamp()));
        }

        return params;
    }
}
