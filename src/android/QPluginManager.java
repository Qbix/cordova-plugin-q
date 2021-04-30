package com.q.cordova.plugin;

import android.os.Debug;
import android.util.Log;

import org.apache.cordova.PluginManager;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.PluginEntry;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import java.util.Collection;

public class QPluginManager  extends PluginManager {

    private static final String TAG = "QPluginManager";
    private static final int SLOW_EXEC_WARNING_THRESHOLD = Debug.isDebuggerConnected() ? 60 : 16;
    private final CordovaWebView app;

    public QPluginManager(CordovaWebView cordovaWebView, CordovaInterface cordova, Collection<PluginEntry> pluginEntries) {
        super(cordovaWebView, cordova, pluginEntries);
        app = cordovaWebView;
    }


    @Override
    public void exec(final String service, final String action, final String callbackId, final String rawArgs) {
        String finalService = service;
        String finalAction = action;
        String finalCallbackId = callbackId;
        String finalRawArgs = rawArgs;

        if(QResultEncryptManager.getInstance().isAllowEncryption()) {
            String[] serviceAndKeySplit = service.split(":");
            if (serviceAndKeySplit.length != 2) {
                return;
            }
            String encryptedService = serviceAndKeySplit[0];
            String encryptedKey = serviceAndKeySplit[1];

            String decodedPrivateKey = QResultEncryptManager.getInstance().decodeRSA(encryptedKey);
            String[] decodedPrivateKeySplit = decodedPrivateKey.split(":");
            if (decodedPrivateKeySplit.length != 2) {
                return;
            }

            String aesKey = decodedPrivateKeySplit[0];
            String aesIv = decodedPrivateKeySplit[1];

            finalService = QResultEncryptManager.getInstance().decryptAes(encryptedService, aesKey, aesIv);
            finalAction = QResultEncryptManager.getInstance().decryptAes(action, aesKey, aesIv);
            finalCallbackId = QResultEncryptManager.getInstance().decryptAes(callbackId, aesKey, aesIv);
            finalRawArgs = QResultEncryptManager.getInstance().decryptAes(rawArgs, aesKey, aesIv);

            QResultEncryptManager.getInstance().setEncryptKeyForCallbackId(aesKey, aesIv, finalCallbackId);
        }

        CordovaPlugin plugin = getPlugin(finalService);
        if (plugin == null) {
            Log.d(TAG, "exec() call to unknown plugin: " + finalService);
            PluginResult cr = new PluginResult(PluginResult.Status.CLASS_NOT_FOUND_EXCEPTION);
            app.sendPluginResult(cr, callbackId);
            return;
        }
        CallbackContext callbackContext = new CallbackContext(finalCallbackId, app);
        try {
            long pluginStartTime = System.currentTimeMillis();
            boolean wasValidAction = plugin.execute(finalAction, finalRawArgs, callbackContext);
            long duration = System.currentTimeMillis() - pluginStartTime;

            if (duration > SLOW_EXEC_WARNING_THRESHOLD) {
                Log.w(TAG, "THREAD WARNING: exec() call to " + finalService + "." + finalAction + " blocked the main thread for " + duration + "ms. Plugin should use CordovaInterface.getThreadPool().");
            }
            if (!wasValidAction) {
                PluginResult cr = new PluginResult(PluginResult.Status.INVALID_ACTION);
                callbackContext.sendPluginResult(cr);
            }
        } catch (JSONException e) {
            PluginResult cr = new PluginResult(PluginResult.Status.JSON_EXCEPTION);
            callbackContext.sendPluginResult(cr);
        } catch (Exception e) {
            Log.e(TAG, "Uncaught exception from plugin", e);
            callbackContext.error(e.getMessage());
        }
    }
}

