package com.q.cordova.plugin;

import android.content.Intent;
import android.os.Bundle;
import android.view.ActionMode;
import android.view.Menu;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewEngine;
import org.apache.cordova.CordovaWebViewImpl;

public abstract class QActivity extends CordovaActivity {
    private final int MULTI_TEST_RESULT_CODE = 1;
    private static boolean androidTestMode = false;
    public static boolean enableSelectContexMenu = true;

    public abstract boolean isTestMode();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        // enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        Q instance = Q.getInstance(this, isTestMode());
        if(isTestMode() && !androidTestMode) {
            startMultiChooserActivity();
        } else {
            instance.showQWebView(null);
        }
    }

    private void startMultiChooserActivity() {
        startActivityForResult(new Intent(this, MultiTestChooserActivity.class), MULTI_TEST_RESULT_CODE);
    }

    public static void setAndroidTestMode(boolean androidTestMode) {
        QActivity.androidTestMode = androidTestMode;
    }

    public void init() {
        super.init();
    }

    @Override
    protected CordovaWebView makeWebView() {
        return new QCordovaWebViewImpl(makeWebViewEngine());
    }

    @Override
    protected CordovaWebViewEngine makeWebViewEngine() {
        return QCordovaWebViewImpl.createEngine(this, preferences);
    }

    @Override
    public void onActionModeStarted(ActionMode mode) {
        if(!QActivity.enableSelectContexMenu) {
            Menu menu = mode.getMenu();
            menu.clear();
        }
        super.onActionModeStarted(mode);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if(requestCode == MULTI_TEST_RESULT_CODE && resultCode == RESULT_OK) {
            if(intent != null && intent.getStringExtra(MultiTestChooserActivity.QTESTURL) != null) {
                Q.getInstance(this, isTestMode()).showQTestWebView(intent.getStringExtra(MultiTestChooserActivity.QTESTURL));
            }
        }
    }
}
