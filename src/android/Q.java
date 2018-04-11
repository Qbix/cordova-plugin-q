package com.q.cordova.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.q.cordova.plugin.network.NetworkApi;
import com.q.cordova.plugin.network.NetworkService;
import com.q.cordova.plugin.network.models.PingResponse;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

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

    public Boolean getTestMode() {
        return testMode;
    }

    private Boolean testMode;

    public void setTestMode(Boolean testMode) {
        this.testMode = testMode;
    }

    public static Q initWith(CordovaActivity activity) {
        if(instance == null) {
            instance = new Q();
        }
        instance.setContext(activity.getApplicationContext());
        instance.setActivity(activity);
        instance.initialize();

        // if(activity.getIntent().getAction()!=null && activity.getIntent().getAction().equalsIgnoreCase(Intent.ACTION_VIEW)) {
        //     if(activity.getIntent().getData()!=null) {
        //         instance.handleOpenUrl(activity.getIntent().getData());
        //     }
        // }


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
        initSharedCache();
        setTestMode(false);

        if(!QConfig.getInstance(this.getContext()).getUserAgentSuffix().isEmpty()) {
            WebSettings settings = getSystemWebSettings();
            settings.setUserAgentString(TextUtils.concat(settings.getUserAgentString(), "", QConfig.getInstance(getContext()).getUserAgentSuffix()).toString());
        }

        sendPingRequest();
    }

    public void onResume() {
        if(getTestMode()) {
            WebSettings settings = getSystemWebSettings();

            settings.setAppCacheEnabled(false);
            settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        }
    }

    public void showQWebView() {
        this.getActivity().loadUrl(prepeareQGroupsController(null));
    }

    public void showQTestWebView(String url) {
        setTestMode(true);
        this.getActivity().loadUrl(prepeareQGroupsController(url));
    }

    private void sendPingRequest() {
        // Sent request
        final Context applicationContext = this.getContext().getApplicationContext();
        NetworkApi api = new NetworkService(applicationContext).getApi();
        api.ping(QConfig.getInstance(applicationContext).getUdid()).enqueue(new Callback<PingResponse>() {
            @Override
            public void onResponse(Call<PingResponse> call, Response<PingResponse> response) {
                if (response.isSuccessful()) {
                    //QConfig.getInstance(applicationContext).acceptPingResponse(response.body());
                }
            }

            @Override
            public void onFailure(Call<PingResponse> call, Throwable t) {

            }
        });
    }

    // private void handleOpenUrl(Uri data) {
    //     QConfig config = QConfig.getInstance(getContext());
    //     if(config.getOpenUrlScheme().equalsIgnoreCase(data.getScheme())) {

    //         String customParams = "";
    //         Map<String, String> additionalParams = getAdditionalParamsForUrl();
    //         for (Map.Entry<String,String> entry : additionalParams.entrySet()) {
    //             customParams += (entry.getKey()+"="+entry.getValue()+"&");
    //         }

    //         String urlStr = String.format("%s%s?%s%s#%s", config.getBaseUrl(), data.getPath(), customParams, data.getQuery(), data.getFragment());

    //         String fragment = data.getFragment();
    //         if(fragment.equalsIgnoreCase("newWindow")) {
    //             //Open in additional webview
    //         } else {
    //             //Open in main webview
    //         }
    //     }
    // }


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

    private WebSettings getSystemWebSettings() {
        CordovaWebView cordovaWebView = getSystemWebEngine();
        return ((WebView)cordovaWebView.getEngine().getView()).getSettings();
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

            QbixWebViewClient qbixWebViewClient = new QbixWebViewClient((SystemWebViewEngine)getSystemWebEngine().getEngine());
            qbixWebViewClient.setIsReturnCahceFilesFromBundle(QConfig.getInstance(applicationContext).getEnableLoadBundleCache());
            qbixWebViewClient.setPathToBundle(QConfig.getInstance(applicationContext).getPathToBundle());
            qbixWebViewClient.setRemoteCacheId(QConfig.getInstance(applicationContext).getRemoteCacheId());

            // Cordova plugins inject by separate plugin
            // if(QConfig.getInstance(getActivity()).getInjectCordovaScripts()) {
            //     ArrayList<String> filesToInject = new ArrayList<String>();
            //     filesToInject.add("www/cordova.js");
            //     filesToInject.add("www/cordova_plugins.js");

            //     FileSystemHelper fileSystemHelper = new FileSystemHelper();
            //     try {
            //         fileSystemHelper.recursiveSearchByExtension(applicationContext, "www/plugins", "js");
            //     } catch (IOException e) {
            //         e.printStackTrace();
            //     }
            //     ArrayList<String> fileNames = fileSystemHelper.getSearchedFiles();
            //     filesToInject.addAll(fileNames);

            //     qbixWebViewClient.setListOfJsInjects(filesToInject);
            // }

            ((WebView) getSystemWebEngine().getView()).setWebViewClient(qbixWebViewClient);
    }

    public String prepeareQGroupsController(String remoteUrl) {
        if(remoteUrl == null)
            remoteUrl = QConfig.getInstance(getActivity()).getUrl();

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

        QConfig config = QConfig.getInstance(getContext());
        params.put("Q.udid", config.getUdid());
        params.put("Q.appId", config.getPackageName());

        params.put("Q.cordova", CordovaWebView.CORDOVA_VERSION);
        if(QConfig.getInstance(getActivity()).getEnableLoadBundleCache()) {
            params.put("Q.ct", String.valueOf(QConfig.getInstance(getActivity()).getBundleTimestamp()));
        }

        return params;
    }
}
