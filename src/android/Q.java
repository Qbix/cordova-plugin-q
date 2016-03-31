package com.q.cordova.plugin;

import android.app.Activity;
import android.content.Context;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.q.cordova.plugin.network.NetworkApi;
import com.q.cordova.plugin.network.NetworkService;
import com.q.cordova.plugin.network.models.PingResponse;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.ExposedJsApi;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Created by adventis on 3/11/16.
 */
public class Q {

    private static Q instance;

    public CordovaActivity getActivity() {
        return activity;
    }

    public void setActivity(CordovaActivity activity) {
        this.activity = activity;
    }
    private CordovaActivity activity;

    public Context getContext() {
        return context;
    }

    public void setContext(Context context) {
        this.context = context;
    }

    private Context context;

    public static Q initWith(CordovaActivity activity) {
        if(instance == null) {
            instance = new Q();
        }
        instance.setContext(activity.getApplicationContext());
        instance.setActivity(activity);
        instance.initialize();


        return instance;
    }

    public static Q getInstance() {
        if(instance == null) {
            RuntimeException exception = new RuntimeException("Q plugin isn\'t inited. Please run static method initWith(Activity activity)");
            throw exception;
        }

        return instance;
    }


    private void initialize() {
        if(Config.getInstance(getContext()).getRemoteMode()) {
            this.getActivity().loadUrl(prepeareQGroupsController());
            //loadUrl(Config.getInstance(this).getLoadUrl());
        } else {
            this.getActivity().loadUrl(getLaunchUrl());
        }

        initSharedCache();

        if(!Config.getInstance(this.getContext()).getUserAgentHeader().isEmpty()) {
            CordovaWebView cordovaWebView = getSystemWebEngine();
            WebSettings settings = ((WebView)cordovaWebView.getEngine().getView()).getSettings();
            settings.setUserAgentString(Config.getInstance(getContext()).getUserAgentHeader());
        }



        sendPingRequest();
    }

    private void sendPingRequest() {
        // Sent request
        final Context applicationContext = this.getContext().getApplicationContext();
        NetworkApi api = new NetworkService(applicationContext).getApi();
        api.ping(Config.getInstance(applicationContext).getUdid()).enqueue(new Callback<PingResponse>() {
            @Override
            public void onResponse(Call<PingResponse> call, Response<PingResponse> response) {
                if (response.isSuccessful()) {
                    if (Config.getInstance(applicationContext).getIsAcceptPingResponse()) {
                        Config.getInstance(applicationContext).acceptPingResponse(response.body());
                    }
                }
            }

            @Override
            public void onFailure(Call<PingResponse> call, Throwable t) {

            }
        });
    }


    // get protected field "launchUrl" of CordovaActivity class using reflection
    private String getLaunchUrl() {
        String launchUrl = null;

        try {
            Class cordovaActivityClass = getActivity().getClass();
            Field launchUrlField = getField(cordovaActivityClass, "launchUrl");
            launchUrlField.setAccessible(true);
            launchUrl = (String)launchUrlField.get(getActivity());
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

        if(launchUrl != null) {
            return launchUrl;
        }

        throw new RuntimeException("Can't find lauchUrl in CordovaActivity");
    }

    // get protected field "appView" of CordovaActivity class using reflection
    private CordovaWebView getSystemWebEngine() {
        CordovaWebView cordovaWebView = null;
        try {
            Class cordovaActivityClass = getActivity().getClass();
            Field appView = getField(cordovaActivityClass, "appView");
            appView.setAccessible(true); //required if field is not normally accessible
            cordovaWebView = (CordovaWebView)appView.get(getActivity());
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

        if(cordovaWebView != null) {
            return cordovaWebView;
        }

        throw new RuntimeException("CordovaWebView can't find or not initialized");
        //return null;
    }

    private static Field getField(Class clazz, String fieldName) throws NoSuchFieldException {
        try {
            return clazz.getDeclaredField(fieldName);
        } catch (NoSuchFieldException e) {
            Class superClass = clazz.getSuperclass();
            if (superClass == null) {
                throw e;
            } else {
                return getField(superClass, fieldName);
            }
        }
    }

    protected void initSharedCache()  {
        Context applicationContext = getActivity().getApplicationContext();
        if(Config.getInstance(applicationContext).getRemoteMode()) {
            QbixWebViewClient qbixWebViewClient = new QbixWebViewClient((SystemWebViewEngine)getSystemWebEngine().getEngine());
            qbixWebViewClient.setIsReturnCahceFilesFromBundle(Config.getInstance(applicationContext).getEnableLoadBundleCache());
            qbixWebViewClient.setPathToBundle(Config.getInstance(applicationContext).getPathToBundle());
            qbixWebViewClient.setRemoteCacheId(Config.getInstance(applicationContext).getRemoteCacheId());

            if(Config.getInstance(getActivity()).getInjectCordovaScripts()) {
                ArrayList<String> filesToInject = new ArrayList<String>();
                filesToInject.add("www/cordova_plugins.js");

                FileSystemHelper fileSystemHelper = new FileSystemHelper();
                try {
                    fileSystemHelper.recursiveSearchByExtension(applicationContext, "www/plugins", "js");
                } catch (IOException e) {
                    e.printStackTrace();
                }
                ArrayList<String> fileNames = fileSystemHelper.getSearchedFiles();
                filesToInject.addAll(fileNames);

                qbixWebViewClient.setListOfJsInjects(filesToInject);
            }

            ((WebView) getSystemWebEngine().getView()).setWebViewClient(qbixWebViewClient);
        }
    }

    public String prepeareQGroupsController() {
        String remoteUrl = Config.getInstance(getActivity()).getLoadUrl();

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

        final TelephonyManager tm = (TelephonyManager) getActivity().getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        //params.put("Q.udid", tm.getDeviceId());
        params.put("Q.udid", "TestUdid");

        params.put("Q.cordova", CordovaWebView.CORDOVA_VERSION);
        if(Config.getInstance(getActivity()).getEnableLoadBundleCache()) {
            params.put("Q.ct", String.valueOf(Config.getInstance(getActivity()).getBundleTimestamp()));
        }

        return params;
    }
}
