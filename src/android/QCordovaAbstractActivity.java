package com.q.cordova.plugin;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import org.apache.cordova.Config;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaInterfaceImpl;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaPreferences;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewImpl;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.ExecutorService;

public abstract class QCordovaAbstractActivity extends Activity implements CordovaInterface {
    public static String URL_KEY = "URL_KEY";
    protected static String INIT_URL_KEY = "INIT_URL_KEY";
    protected CordovaInterfaceImpl cordovaInterface;
    protected CordovaPreferences preferences;
    protected CordovaWebView cordovaWebView;
    protected String initUrl;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        cordovaInterface = makeCordovaInterface();
        if (savedInstanceState != null) {
            cordovaInterface.restoreInstanceState(savedInstanceState);
        }
        Config.init(this);
        this.preferences = Config.getPreferences();
        cordovaWebView = new CordovaWebViewImpl(CordovaWebViewImpl.createEngine(this, preferences));
        cordovaWebView.init(this,  Config.getPluginEntries(),  preferences);
    }

    void setWebView(ViewGroup view) {
//        cordovaWebView.getView().setId(100);
        cordovaWebView.getView().setLayoutParams(new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        view.addView(cordovaWebView.getView());
    }

    protected CordovaInterfaceImpl makeCordovaInterface() {
        return new CordovaInterfaceImpl(this) {
            @Override
            public Object onMessage(String id, Object data) {
                // Plumb this to CordovaActivity.onMessage for backwards compatibility
                return QCordovaAbstractActivity.this.onMessage(id, data);
            }
        };
    }

    @Override
    public void startActivityForResult(CordovaPlugin command, Intent intent, int requestCode) {
        cordovaInterface.startActivityForResult(command, intent, requestCode);
        super.startActivityForResult(intent, requestCode, null);
    }

    @Override
    public void setActivityResultCallback(CordovaPlugin plugin) {
        cordovaInterface.setActivityResultCallback(plugin);
    }

    @Override
    public Activity getActivity() {
        return cordovaInterface.getActivity();
    }

    @Override
    public Context getContext() {
        return cordovaInterface.getContext();
    }

    @Override
    public Object onMessage(String id, Object data) {
        if ("onReceivedError".equals(id)) {
            JSONObject d = (JSONObject) data;
            try {
                this.onReceivedError(d.getInt("errorCode"), d.getString("description"), d.getString("url"));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else if ("exit".equals(id)) {
            finish();
        }
        return null;
    }

    public void onReceivedError(final int errorCode, final String description, final String failingUrl) {
        final QCordovaAbstractActivity me = this;

        // If errorUrl specified, then load it
        final String errorUrl = preferences.getString("errorUrl", null);
        if ((errorUrl != null) && (!failingUrl.equals(errorUrl)) && (cordovaWebView != null)) {
            // Load URL on UI thread
            me.runOnUiThread(new Runnable() {
                public void run() {
                    me.cordovaWebView.showWebPage(errorUrl, false, true, null);
                }
            });
        }
        // If not, then display error dialog
        else {
            final boolean exit = !(errorCode == WebViewClient.ERROR_HOST_LOOKUP);
            me.runOnUiThread(new Runnable() {
                public void run() {
                    if (exit) {
                        me.cordovaWebView.getView().setVisibility(View.GONE);
                        me.displayError("Application Error", description + " (" + failingUrl + ")", "OK", exit);
                    }
                }
            });
        }
    }

    public void displayError(final String title, final String message, final String button, final boolean exit) {
        final QCordovaAbstractActivity me = this;
        me.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    AlertDialog.Builder dlg = new AlertDialog.Builder(me);
                    dlg.setMessage(message);
                    dlg.setTitle(title);
                    dlg.setCancelable(false);
                    dlg.setPositiveButton(button,
                            new AlertDialog.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                    if (exit) {
                                        finish();
                                    }
                                }
                            });
                    dlg.create();
                    dlg.show();
                } catch (Exception e) {
                    finish();
                }
            }
        });
    }

    @Override
    public ExecutorService getThreadPool() {
        return cordovaInterface.getThreadPool();
    }

    @Override
    public void requestPermission(CordovaPlugin plugin, int requestCode, String permission) {
        cordovaInterface.requestPermission(plugin, requestCode, permission);
    }

    @Override
    public void requestPermissions(CordovaPlugin plugin, int requestCode, String[] permissions) {
        cordovaInterface.requestPermissions(plugin, requestCode, permissions);
    }

    @Override
    public boolean hasPermission(String permission) {
        return cordovaInterface.hasPermission(permission);
    }
}
