package com.q.cordova.plugin;

import android.content.Context;
import android.content.res.Resources;
import android.util.Log;

import com.q.cordova.plugin.network.models.PingResponse;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Created by adventis on 3/11/16.
 */
public class Config {
    private final String TAG = "ConfigTAG";

    public static final String assetsFolderPath = "file:///android_asset";

    public void setCtx(Context ctx) {
        this.ctx = ctx;
    }

    private Context ctx;
    public static Config instance;
    public static Config getInstance(Context context) {
        if(instance == null) {
            instance = new Config(context);
            instance.setCtx(context);
        }

        return instance;
    }

    private JSONObject properties;

    public String getRemoteCacheId() {
        return getConfigValue("remoteCacheId");
    }
    private String remoteCacheId;


    public Boolean getRemoteMode() {
        String value = getConfigValue("remoteMode");
        if(value.equalsIgnoreCase("true")) {
            return true;
        }

        return false;
    }
    private Boolean remoteMode;

    public String getPathToBundle() {
        return getConfigValue("pathToBundle");
    }
    private String pathToBundle;


    public Boolean getInjectCordovaScripts() {
        String value = getConfigValue("injectCordovaScripts");
        if(value.equalsIgnoreCase("true")) {
            return true;
        }

        return false;
    }
    private Boolean injectCordovaScripts;

    public long getBundleTimestamp() {
        String value = getConfigValue("bundleTimestamp");
        return Long.parseLong(value);
    }
    private long bundleTimestamp;

    public Boolean getEnableLoadBundleCache() {
        String value = getConfigValue("enableLoadBundleCache");
        if(value.equalsIgnoreCase("true")) {
            return true;
        }

        return false;
    }
    private Boolean enableLoadBundleCache;

    public String getPingUrl() {
        return getConfigValue("pingUrl");
    }

    public void setPingUrl(String pingUrl) {
        this.pingUrl = pingUrl;
        this.setConfigValue("pingUrl", pingUrl);
    }

    private String pingUrl;

    public Boolean getIsAcceptPingResponse() {
        String value = getConfigValue("isAcceptPingResponse");
        if(value.equalsIgnoreCase("true")) {
            return true;
        }

        return false;
    }
    private Boolean isAcceptPingResponse;

    public String getLoadUrl() {
        return getConfigValue("loadUrl");
    }

    public void setLoadUrl(String loadUrl) {
        this.loadUrl = loadUrl;
        setConfigValue("loadUrl", loadUrl);
    }

    private String loadUrl;

    public String getLoadBaseUrl() {
        return getConfigValue("loadBaseUrl");
    }
    private String loadBaseUrl;

    public String getOpenUrlScheme() {
        return getConfigValue("openUrlScheme");
    }
    private String openUrlScheme;


    public String getUserAgentHeader() {
        return getConfigValue("userAgentHeader");
    }
    private String userAgentHeader;

    public Config(Context context) {
        Resources resources = context.getResources();

        try {
            InputStream rawResource = context.getResources().getAssets().open("config.json");//resources.openRawResource(R.raw.config);
            byte[] buffer = new byte[rawResource.available()];
            rawResource.read(buffer);
            rawResource.close();

            this.properties = new JSONObject(new String(buffer, "UTF-8"));
        } catch (Resources.NotFoundException e) {
            Log.e(TAG, "Unable to find the config file: " + e.getMessage());
        } catch (IOException e) {
            Log.e(TAG, "Failed to open config file.");
        }  catch (JSONException e) {
            Log.e(TAG, "Failed to parse json data.");
        }
    }

    public String getConfigValue(String name) {
        if(this.properties != null) {
            String value = null;
            try {
                value = properties.getString(name);
                return value;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return null;
    }

    public void setConfigValue(String name, String value) {
        if(this.properties != null) {
            try {
                properties.put(value, name);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public String getUdid() {
        this.udid = android.provider.Settings.System.getString(ctx.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
        return udid;
    }

    private String udid;

    public void acceptPingResponse(PingResponse response) {
        this.setPingUrl(response.pingUrl);
        this.setLoadUrl(response.loadUrl);
    }
}
