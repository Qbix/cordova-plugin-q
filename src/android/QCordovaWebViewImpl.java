package com.q.cordova.plugin;


import android.annotation.SuppressLint;
import android.util.Pair;
import android.view.View;

import org.apache.cordova.CordovaWebViewImpl;
import org.apache.cordova.CordovaWebViewEngine;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPreferences;
import org.apache.cordova.PluginEntry;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginManager;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.NativeToJsMessageQueue;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginManager;
import org.apache.cordova.CoreAndroid;
import org.apache.cordova.ICordovaCookieManager;
import org.apache.cordova.LOG;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.widget.FrameLayout;

import org.apache.cordova.engine.SystemWebViewEngine;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Main class for interacting with a Cordova webview. Manages plugins, events, and a CordovaWebViewEngine.
 * Class uses two-phase initialization. You must call init() before calling any other methods.
 */
public class QCordovaWebViewImpl implements CordovaWebView {

    public static final String TAG = "QCordovaWebViewImpl";

    private PluginManager pluginManager;

    protected final CordovaWebViewEngine engine;
    private CordovaInterface cordova;

    // Flag to track that a loadUrl timeout occurred
    private int loadUrlTimeout = 0;

    private CordovaResourceApi resourceApi;
    private CordovaPreferences preferences;
    private CoreAndroid appPlugin;
    private NativeToJsMessageQueue nativeToJsMessageQueue;
    private EngineClient engineClient = new EngineClient();
    private boolean hasPausedEver;

    // The URL passed to loadUrl(), not necessarily the URL of the current page.
    String loadedUrl;

    /** custom view created by the browser (a video player for example) */
    private View mCustomView;
    private WebChromeClient.CustomViewCallback mCustomViewCallback;

    private Set<Integer> boundKeyCodes = new HashSet<Integer>();

    public static CordovaWebViewEngine createEngine(Context context, CordovaPreferences preferences) {
        String className = preferences.getString("webview", SystemWebViewEngine.class.getCanonicalName());
        try {
            Class<?> webViewClass = Class.forName(className);
            Constructor<?> constructor = webViewClass.getConstructor(Context.class, CordovaPreferences.class);
            return (CordovaWebViewEngine) constructor.newInstance(context, preferences);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create webview. ", e);
        }
    }

    public QCordovaWebViewImpl(CordovaWebViewEngine cordovaWebViewEngine) {
        this.engine = cordovaWebViewEngine;
    }

    // Convenience method for when creating programmatically (not from Config.xml).
    public void init(CordovaInterface cordova) {
        init(cordova, new ArrayList<PluginEntry>(), new CordovaPreferences());
    }

    @SuppressLint("Assert")
    @Override
    public void init(CordovaInterface cordova, List<PluginEntry> pluginEntries, CordovaPreferences preferences) {
        if (this.cordova != null) {
            throw new IllegalStateException();
        }
        this.cordova = cordova;
        this.preferences = preferences;
        pluginManager = new QPluginManager(this, this.cordova, pluginEntries);
        resourceApi = new CordovaResourceApi(engine.getView().getContext(), pluginManager);
        nativeToJsMessageQueue = new QNativeToJsMessageQueue();
        nativeToJsMessageQueue.addBridgeMode(new NativeToJsMessageQueue.NoOpBridgeMode());
        nativeToJsMessageQueue.addBridgeMode(new NativeToJsMessageQueue.LoadUrlBridgeMode(engine, cordova));

        if (preferences.getBoolean("DisallowOverscroll", false)) {
            engine.getView().setOverScrollMode(View.OVER_SCROLL_NEVER);
        }
        engine.init(this, cordova, engineClient, resourceApi, pluginManager, nativeToJsMessageQueue);
        // This isn't enforced by the compiler, so assert here.
        assert engine.getView() instanceof CordovaWebViewEngine.EngineView;

        pluginManager.addService(CoreAndroid.PLUGIN_NAME, "org.apache.cordova.CoreAndroid");
        pluginManager.init();

    }

    @Override
    public boolean isInitialized() {
        return cordova != null;
    }

    @Override
    public void loadUrlIntoView(final String url, boolean recreatePlugins) {
        LOG.d(TAG, ">>> loadUrl(" + url + ")");
        if (url.equals("about:blank") || url.startsWith("javascript:")) {
            engine.loadUrl(url, false);
            return;
        }

        recreatePlugins = recreatePlugins || (loadedUrl == null);

        if (recreatePlugins) {
            // Don't re-initialize on first load.
            if (loadedUrl != null) {
                appPlugin = null;
                pluginManager.init();
            }
            loadedUrl = url;
        }

        // Create a timeout timer for loadUrl
        final int currentLoadUrlTimeout = loadUrlTimeout;
        final int loadUrlTimeoutValue = preferences.getInteger("LoadUrlTimeoutValue", 20000);

        // Timeout error method
        final Runnable loadError = new Runnable() {
            public void run() {
                stopLoading();
                LOG.e(TAG, "CordovaWebView: TIMEOUT ERROR!");

                // Handle other errors by passing them to the webview in JS
                JSONObject data = new JSONObject();
                try {
                    data.put("errorCode", -6);
                    data.put("description", "The connection to the server was unsuccessful.");
                    data.put("url", url);
                } catch (JSONException e) {
                    // Will never happen.
                }
                pluginManager.postMessage("onReceivedError", data);
            }
        };

        // Timeout timer method
        final Runnable timeoutCheck = new Runnable() {
            public void run() {
                try {
                    synchronized (this) {
                        wait(loadUrlTimeoutValue);
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                // If timeout, then stop loading and handle error
                if (loadUrlTimeout == currentLoadUrlTimeout) {
                    cordova.getActivity().runOnUiThread(loadError);
                }
            }
        };

        final boolean _recreatePlugins = recreatePlugins;
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                if (loadUrlTimeoutValue > 0) {
                    cordova.getThreadPool().execute(timeoutCheck);
                }
                engine.loadUrl(url, _recreatePlugins);
            }
        });
    }


    @Override
    public void loadUrl(String url) {
        loadUrlIntoView(url, true);
    }

    @Override
    public void showWebPage(String url, boolean openExternal, boolean clearHistory, Map<String, Object> params) {
        LOG.d(TAG, "showWebPage(%s, %b, %b, HashMap)", url, openExternal, clearHistory);

        // If clearing history
        if (clearHistory) {
            engine.clearHistory();
        }

        // If loading into our webview
        if (!openExternal) {
            // Make sure url is in whitelist
            if (pluginManager.shouldAllowNavigation(url)) {
                // TODO: What about params?
                // Load new URL
                loadUrlIntoView(url, true);
                return;
            } else {
                LOG.w(TAG, "showWebPage: Refusing to load URL into webview since it is not in the <allow-navigation> whitelist. URL=" + url);
                return;
            }
        }
        if (!pluginManager.shouldOpenExternalUrl(url)) {
            LOG.w(TAG, "showWebPage: Refusing to send intent for URL since it is not in the <allow-intent> whitelist. URL=" + url);
            return;
        }
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            // To send an intent without CATEGORY_BROWSER, a custom plugin should be used.
            intent.addCategory(Intent.CATEGORY_BROWSABLE);
            Uri uri = Uri.parse(url);
            // Omitting the MIME type for file: URLs causes "No Activity found to handle Intent".
            // Adding the MIME type to http: URLs causes them to not be handled by the downloader.
            if ("file".equals(uri.getScheme())) {
                intent.setDataAndType(uri, resourceApi.getMimeType(uri));
            } else {
                intent.setData(uri);
            }
            cordova.getActivity().startActivity(intent);
        } catch (android.content.ActivityNotFoundException e) {
            LOG.e(TAG, "Error loading url " + url, e);
        }
    }

    @Override
    @Deprecated
    public void showCustomView(View view, WebChromeClient.CustomViewCallback callback) {
        // This code is adapted from the original Android Browser code, licensed under the Apache License, Version 2.0
        LOG.d(TAG, "showing Custom View");
        // if a view already exists then immediately terminate the new one
        if (mCustomView != null) {
            callback.onCustomViewHidden();
            return;
        }

        // Store the view and its callback for later (to kill it properly)
        mCustomView = view;
        mCustomViewCallback = callback;

        // Add the custom view to its container.
        ViewGroup parent = (ViewGroup) engine.getView().getParent();
        parent.addView(view, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                Gravity.CENTER));

        // Hide the content view.
        engine.getView().setVisibility(View.GONE);

        // Finally show the custom view container.
        parent.setVisibility(View.VISIBLE);
        parent.bringToFront();
    }

    @Override
    @Deprecated
    public void hideCustomView() {
        // This code is adapted from the original Android Browser code, licensed under the Apache License, Version 2.0
        if (mCustomView == null) return;
        LOG.d(TAG, "Hiding Custom View");

        // Hide the custom view.
        mCustomView.setVisibility(View.GONE);

        // Remove the custom view from its container.
        ViewGroup parent = (ViewGroup) engine.getView().getParent();
        parent.removeView(mCustomView);
        mCustomView = null;
        mCustomViewCallback.onCustomViewHidden();

        // Show the content view.
        engine.getView().setVisibility(View.VISIBLE);
    }

    @Override
    @Deprecated
    public boolean isCustomViewShowing() {
        return mCustomView != null;
    }

    @Override
    @Deprecated
    public void sendJavascript(String statement) {
        nativeToJsMessageQueue.addJavaScript(statement);
    }

    @Override
    public void sendPluginResult(PluginResult cr, String callbackId) {
        nativeToJsMessageQueue.addPluginResult(cr, callbackId);
    }

    @Override
    public PluginManager getPluginManager() {
        return pluginManager;
    }
    @Override
    public CordovaPreferences getPreferences() {
        return preferences;
    }
    @Override
    public ICordovaCookieManager getCookieManager() {
        return engine.getCookieManager();
    }
    @Override
    public CordovaResourceApi getResourceApi() {
        return resourceApi;
    }
    @Override
    public CordovaWebViewEngine getEngine() {
        return engine;
    }
    @Override
    public View getView() {
        return engine.getView();
    }
    @Override
    public Context getContext() {
        return engine.getView().getContext();
    }

    private void sendJavascriptEvent(String event) {
        if (appPlugin == null) {
            appPlugin = (CoreAndroid)pluginManager.getPlugin(CoreAndroid.PLUGIN_NAME);
        }

        if (appPlugin == null) {
            LOG.w(TAG, "Unable to fire event without existing plugin");
            return;
        }
        appPlugin.fireJavascriptEvent(event);
    }

    @Override
    public void setButtonPlumbedToJs(int keyCode, boolean override) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_VOLUME_DOWN:
            case KeyEvent.KEYCODE_VOLUME_UP:
            case KeyEvent.KEYCODE_BACK:
            case KeyEvent.KEYCODE_MENU:
                // TODO: Why are search and menu buttons handled separately?
                if (override) {
                    boundKeyCodes.add(keyCode);
                } else {
                    boundKeyCodes.remove(keyCode);
                }
                return;
            default:
                throw new IllegalArgumentException("Unsupported keycode: " + keyCode);
        }
    }

    @Override
    public boolean isButtonPlumbedToJs(int keyCode) {
        return boundKeyCodes.contains(keyCode);
    }

    @Override
    public Object postMessage(String id, Object data) {
        return pluginManager.postMessage(id, data);
    }

    // Engine method proxies:
    @Override
    public String getUrl() {
        return engine.getUrl();
    }

    @Override
    public void stopLoading() {
        // Clear timeout flag
        loadUrlTimeout++;
    }

    @Override
    public boolean canGoBack() {
        return engine.canGoBack();
    }

    @Override
    public void clearCache() {
        engine.clearCache();
    }

    @Override
    @Deprecated
    public void clearCache(boolean b) {
        engine.clearCache();
    }

    @Override
    public void clearHistory() {
        engine.clearHistory();
    }

    @Override
    public boolean backHistory() {
        return engine.goBack();
    }

    /////// LifeCycle methods ///////
    @Override
    public void onNewIntent(Intent intent) {
        if (this.pluginManager != null) {
            this.pluginManager.onNewIntent(intent);
        }
    }
    @Override
    public void handlePause(boolean keepRunning) {
        if (!isInitialized()) {
            return;
        }
        hasPausedEver = true;
        pluginManager.onPause(keepRunning);
        sendJavascriptEvent("pause");

        // If app doesn't want to run in background
        if (!keepRunning) {
            // Pause JavaScript timers. This affects all webviews within the app!
            engine.setPaused(true);
        }
    }
    @Override
    public void handleResume(boolean keepRunning) {
        if (!isInitialized()) {
            return;
        }

        // Resume JavaScript timers. This affects all webviews within the app!
        engine.setPaused(false);
        this.pluginManager.onResume(keepRunning);

        // In order to match the behavior of the other platforms, we only send onResume after an
        // onPause has occurred. The resume event might still be sent if the Activity was killed
        // while waiting for the result of an external Activity once the result is obtained
        if (hasPausedEver) {
            sendJavascriptEvent("resume");
        }
    }
    @Override
    public void handleStart() {
        if (!isInitialized()) {
            return;
        }
        pluginManager.onStart();
    }
    @Override
    public void handleStop() {
        if (!isInitialized()) {
            return;
        }
        pluginManager.onStop();
    }
    @Override
    public void handleDestroy() {
        if (!isInitialized()) {
            return;
        }
        // Cancel pending timeout timer.
        loadUrlTimeout++;

        // Forward to plugins
        this.pluginManager.onDestroy();

        // TODO: about:blank is a bit special (and the default URL for new frames)
        // We should use a blank data: url instead so it's more obvious
        this.loadUrl("about:blank");

        // TODO: Should not destroy webview until after about:blank is done loading.
        engine.destroy();
        hideCustomView();
    }

    protected class EngineClient implements CordovaWebViewEngine.Client {
        @Override
        public void clearLoadTimeoutTimer() {
            loadUrlTimeout++;
        }

        @Override
        public void onPageStarted(String newUrl) {
            LOG.d(TAG, "onPageDidNavigate(" + newUrl + ")");
            boundKeyCodes.clear();
            pluginManager.onReset();
            pluginManager.postMessage("onPageStarted", newUrl);
        }

        @Override
        public void onReceivedError(int errorCode, String description, String failingUrl) {
            clearLoadTimeoutTimer();
            JSONObject data = new JSONObject();
            try {
                data.put("errorCode", errorCode);
                data.put("description", description);
                data.put("url", failingUrl);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            pluginManager.postMessage("onReceivedError", data);
        }

        @Override
        public void onPageFinishedLoading(String url) {
            LOG.d(TAG, "onPageFinished(" + url + ")");

            clearLoadTimeoutTimer();

            // Broadcast message that page has loaded
            pluginManager.postMessage("onPageFinished", url);

            // Make app visible after 2 sec in case there was a JS error and Cordova JS never initialized correctly
            if (engine.getView().getVisibility() != View.VISIBLE) {
                Thread t = new Thread(new Runnable() {
                    public void run() {
                        try {
                            Thread.sleep(2000);
                            cordova.getActivity().runOnUiThread(new Runnable() {
                                public void run() {
                                    pluginManager.postMessage("spinner", "stop");
                                }
                            });
                        } catch (InterruptedException e) {
                        }
                    }
                });
                t.start();
            }

            // Shutdown if blank loaded
            if (url.equals("about:blank")) {
                pluginManager.postMessage("exit", null);
            }
        }

        @Override
        public Boolean onDispatchKeyEvent(KeyEvent event) {
            int keyCode = event.getKeyCode();
            boolean isBackButton = keyCode == KeyEvent.KEYCODE_BACK;
            if (event.getAction() == KeyEvent.ACTION_DOWN) {
                if (isBackButton && mCustomView != null) {
                    return true;
                } else if (boundKeyCodes.contains(keyCode)) {
                    return true;
                } else if (isBackButton) {
                    return engine.canGoBack();
                }
            } else if (event.getAction() == KeyEvent.ACTION_UP) {
                if (isBackButton && mCustomView != null) {
                    hideCustomView();
                    return true;
                } else if (boundKeyCodes.contains(keyCode)) {
                    String eventName = null;
                    switch (keyCode) {
                        case KeyEvent.KEYCODE_VOLUME_DOWN:
                            eventName = "volumedownbutton";
                            break;
                        case KeyEvent.KEYCODE_VOLUME_UP:
                            eventName = "volumeupbutton";
                            break;
                        case KeyEvent.KEYCODE_SEARCH:
                            eventName = "searchbutton";
                            break;
                        case KeyEvent.KEYCODE_MENU:
                            eventName = "menubutton";
                            break;
                        case KeyEvent.KEYCODE_BACK:
                            eventName = "backbutton";
                            break;
                    }
                    if (eventName != null) {
                        sendJavascriptEvent(eventName);
                        return true;
                    }
                } else if (isBackButton) {
                    return engine.goBack();
                }
            }
            return null;
        }

        @Override
        public boolean onNavigationAttempt(String url) {
            // Give plugins the chance to handle the url
            if (pluginManager.onOverrideUrlLoading(url)) {
                return true;
            } else if (pluginManager.shouldAllowNavigation(url)) {
                return false;
            } else if (pluginManager.shouldOpenExternalUrl(url)) {
                showWebPage(url, true, false, null);
                return true;
            }
            LOG.w(TAG, "Blocked (possibly sub-frame) navigation to non-allowed URL: " + url);
            return true;
        }
    }

    public class QNativeToJsMessageQueue extends NativeToJsMessageQueue{
        private static final String LOG_TAG = "JsMessageQueue";

        // Set this to true to force plugin results to be encoding as
        // JS instead of the custom format (useful for benchmarking).
        // Doesn't work for multipart messages.
        private static final boolean FORCE_ENCODE_USING_EVAL = false;

        // Disable sending back native->JS messages during an exec() when the active
        // exec() is asynchronous. Set this to true when running bridge benchmarks.
        static final boolean DISABLE_EXEC_CHAINING = false;

        // Arbitrarily chosen upper limit for how much data to send to JS in one shot.
        // This currently only chops up on message boundaries. It may be useful
        // to allow it to break up messages.
        private int MAX_PAYLOAD_SIZE = 50 * 1024 * 10240;

        /**
         * When true, the active listener is not fired upon enqueue. When set to false,
         * the active listener will be fired if the queue is non-empty.
         */
        private boolean paused;

        /**
         * The list of JavaScript statements to be sent to JavaScript.
         */
        private final LinkedList<QJsMessage> queue = new LinkedList<QJsMessage>();

        /**
         * The array of listeners that can be used to send messages to JS.
         */
        private ArrayList<org.apache.cordova.NativeToJsMessageQueue.BridgeMode> bridgeModes = new ArrayList<org.apache.cordova.NativeToJsMessageQueue.BridgeMode>();

        /**
         * When null, the bridge is disabled. This occurs during page transitions.
         * When disabled, all callbacks are dropped since they are assumed to be
         * relevant to the previous page.
         */
        private org.apache.cordova.NativeToJsMessageQueue.BridgeMode activeBridgeMode;

        public void addBridgeMode(org.apache.cordova.NativeToJsMessageQueue.BridgeMode bridgeMode) {
            bridgeModes.add(bridgeMode);
        }

        public boolean isBridgeEnabled() {
            return activeBridgeMode != null;
        }

        public boolean isEmpty() {
            return queue.isEmpty();
        }

        /**
         * Changes the bridge mode.
         */
        public void setBridgeMode(int value) {
            if (value < -1 || value >= bridgeModes.size()) {
                LOG.d(LOG_TAG, "Invalid NativeToJsBridgeMode: " + value);
            } else {
                org.apache.cordova.NativeToJsMessageQueue.BridgeMode newMode = value < 0 ? null : bridgeModes.get(value);
                if (newMode != activeBridgeMode) {
                    LOG.d(LOG_TAG, "Set native->JS mode to " + (newMode == null ? "null" : newMode.getClass().getSimpleName()));
                    synchronized (this) {
                        activeBridgeMode = newMode;
                        if (newMode != null) {
                            newMode.reset();
                            if (!paused && !queue.isEmpty()) {
                                newMode.onNativeToJsMessageAvailable(this);
                            }
                        }
                    }
                }
            }
        }

        /**
         * Clears all messages and resets to the default bridge mode.
         */
        public void reset() {
            synchronized (this) {
                queue.clear();
                setBridgeMode(-1);
            }
        }

        private int calculatePackedMessageLength(QJsMessage message) {
            int messageLen = message.calculateEncodedLength();
            String messageLenStr = String.valueOf(messageLen);
            return messageLenStr.length() + messageLen + 1;
        }

        private void packMessage(QJsMessage message, StringBuilder sb) {
            int len = message.calculateEncodedLength();
            sb.append(len)
                    .append(' ');
            message.encodeAsMessage(sb);
        }

        /**
         * Combines and returns queued messages combined into a single string.
         * Combines as many messages as possible, while staying under MAX_PAYLOAD_SIZE.
         * Returns null if the queue is empty.
         */
        public String popAndEncode(boolean fromOnlineEvent) {
            synchronized (this) {
                if (activeBridgeMode == null) {
                    return null;
                }
                activeBridgeMode.notifyOfFlush(this, fromOnlineEvent);
                if (queue.isEmpty()) {
                    return null;
                }
                int totalPayloadLen = 0;
                int numMessagesToSend = 0;
                for (QJsMessage message : queue) {
                    int messageSize = calculatePackedMessageLength(message);
                    if (numMessagesToSend > 0 && totalPayloadLen + messageSize > MAX_PAYLOAD_SIZE && MAX_PAYLOAD_SIZE > 0) {
                        break;
                    }
                    totalPayloadLen += messageSize;
                    numMessagesToSend += 1;
                }

//                StringBuilder sb = new StringBuilder(totalPayloadLen);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < numMessagesToSend; ++i) {
                    QJsMessage message = queue.removeFirst();
                    StringBuilder tmp = new StringBuilder();
                    packMessage(message, tmp);

                    Pair<String, String> keys = QResultEncryptManager.getInstance().getEncryptKeyForCallbackId(message.jsPayloadOrCallbackId);

                    String encoded = QResultEncryptManager.getInstance().encryptAes(tmp.toString(), keys.first,keys.second);
                    sb.append(encoded);
//                    sb.append(tmp.toString());
                }

                if (!queue.isEmpty()) {
                    // Attach a char to indicate that there are more messages pending.
                    sb.append('*');
                }
                String ret = sb.toString();

                return ret;
            }
        }

        /**
         * Same as popAndEncode(), except encodes in a form that can be executed as JS.
         */
        public String popAndEncodeAsJs() {
            synchronized (this) {
                int length = queue.size();
                if (length == 0) {
                    return null;
                }
                int totalPayloadLen = 0;
                int numMessagesToSend = 0;
                for (QJsMessage message : queue) {
                    int messageSize = message.calculateEncodedLength() + 50; // overestimate.
                    if (numMessagesToSend > 0 && totalPayloadLen + messageSize > MAX_PAYLOAD_SIZE && MAX_PAYLOAD_SIZE > 0) {
                        break;
                    }
                    totalPayloadLen += messageSize;
                    numMessagesToSend += 1;
                }
                boolean willSendAllMessages = numMessagesToSend == queue.size();
                StringBuilder sb = new StringBuilder(totalPayloadLen + (willSendAllMessages ? 0 : 100));
                // Wrap each statement in a try/finally so that if one throws it does
                // not affect the next.
                for (int i = 0; i < numMessagesToSend; ++i) {
                    QJsMessage message = queue.removeFirst();
                    if (willSendAllMessages && (i + 1 == numMessagesToSend)) {
                        message.encodeAsJsMessage(sb);
                    } else {
                        sb.append("try{");
                        message.encodeAsJsMessage(sb);
                        sb.append("}finally{");
                    }
                }
                if (!willSendAllMessages) {
                    sb.append("window.setTimeout(function(){cordova.require('cordova/plugin/android/polling').pollOnce();},0);");
                }
                for (int i = willSendAllMessages ? 1 : 0; i < numMessagesToSend; ++i) {
                    sb.append('}');
                }
                String ret = sb.toString();
                return ret;
            }
        }

        /**
         * Add a JavaScript statement to the list.
         */
        public void addJavaScript(String statement) {
            enqueueMessage(new QJsMessage(statement));
        }

        /**
         * Add a JavaScript statement to the list.
         */
        public void addPluginResult(PluginResult result, String callbackId) {
            if (callbackId == null) {
                LOG.e(LOG_TAG, "Got plugin result with no callbackId", new Throwable());
                return;
            }
            // Don't send anything if there is no result and there is no need to
            // clear the callbacks.
            boolean noResult = result.getStatus() == PluginResult.Status.NO_RESULT.ordinal();
            boolean keepCallback = result.getKeepCallback();
            if (noResult && keepCallback) {
                return;
            }
            QJsMessage message = new QJsMessage(result, callbackId);
            if (FORCE_ENCODE_USING_EVAL) {
                StringBuilder sb = new StringBuilder(message.calculateEncodedLength() + 50);
                message.encodeAsJsMessage(sb);
                message = new QJsMessage(sb.toString());
            }

            enqueueMessage(message);
        }

        private void enqueueMessage(QJsMessage message) {
            synchronized (this) {
                if (activeBridgeMode == null) {
                    LOG.d(LOG_TAG, "Dropping Native->JS message due to disabled bridge");
                    return;
                }
                queue.add(message);
                if (!paused) {
                    activeBridgeMode.onNativeToJsMessageAvailable(this);
                }
            }
        }

        public void setPaused(boolean value) {
            if (paused && value) {
                // This should never happen. If a use-case for it comes up, we should
                // change pause to be a counter.
                LOG.e(LOG_TAG, "nested call to setPaused detected.", new Throwable());
            }
            paused = value;
            if (!value) {
                synchronized (this) {
                    if (!queue.isEmpty() && activeBridgeMode != null) {
                        activeBridgeMode.onNativeToJsMessageAvailable(this);
                    }
                }
            }
        }
    }

    private static class QJsMessage {
        final String jsPayloadOrCallbackId;
        final PluginResult pluginResult;
        QJsMessage(String js) {
            if (js == null) {
                throw new NullPointerException();
            }
            jsPayloadOrCallbackId = js;
            pluginResult = null;
        }
        QJsMessage(PluginResult pluginResult, String callbackId) {
            if (callbackId == null || pluginResult == null) {
                throw new NullPointerException();
            }
            jsPayloadOrCallbackId = callbackId;
            this.pluginResult = pluginResult;
        }

        static int calculateEncodedLengthHelper(PluginResult pluginResult) {
            switch (pluginResult.getMessageType()) {
                case PluginResult.MESSAGE_TYPE_BOOLEAN: // f or t
                case PluginResult.MESSAGE_TYPE_NULL: // N
                    return 1;
                case PluginResult.MESSAGE_TYPE_NUMBER: // n
                    return 1 + pluginResult.getMessage().length();
                case PluginResult.MESSAGE_TYPE_STRING: // s
                    return 1 + pluginResult.getStrMessage().length();
                case PluginResult.MESSAGE_TYPE_BINARYSTRING:
                    return 1 + pluginResult.getMessage().length();
                case PluginResult.MESSAGE_TYPE_ARRAYBUFFER:
                    return 1 + pluginResult.getMessage().length();
                case PluginResult.MESSAGE_TYPE_MULTIPART:
                    int ret = 1;
                    for (int i = 0; i < pluginResult.getMultipartMessagesSize(); i++) {
                        int length = calculateEncodedLengthHelper(pluginResult.getMultipartMessage(i));
                        int argLength = String.valueOf(length).length();
                        ret += argLength + 1 + length;
                    }
                    return ret;
                case PluginResult.MESSAGE_TYPE_JSON:
                default:
                    return pluginResult.getMessage().length();
            }
        }

        int calculateEncodedLength() {
            if (pluginResult == null) {
                return jsPayloadOrCallbackId.length() + 1;
            }
            int statusLen = String.valueOf(pluginResult.getStatus()).length();
            int ret = 2 + statusLen + 1 + jsPayloadOrCallbackId.length() + 1;
            return ret + calculateEncodedLengthHelper(pluginResult);
        }

        static void encodeAsMessageHelper(StringBuilder sb, PluginResult pluginResult) {
            switch (pluginResult.getMessageType()) {
                case PluginResult.MESSAGE_TYPE_BOOLEAN:
                    sb.append(pluginResult.getMessage().charAt(0)); // t or f.
                    break;
                case PluginResult.MESSAGE_TYPE_NULL: // N
                    sb.append('N');
                    break;
                case PluginResult.MESSAGE_TYPE_NUMBER: // n
                    sb.append('n')
                            .append(pluginResult.getMessage());
                    break;
                case PluginResult.MESSAGE_TYPE_STRING: // s
                    sb.append('s');
                    sb.append(pluginResult.getStrMessage());
                    break;
                case PluginResult.MESSAGE_TYPE_BINARYSTRING: // S
                    sb.append('S');
                    sb.append(pluginResult.getMessage());
                    break;
                case PluginResult.MESSAGE_TYPE_ARRAYBUFFER: // A
                    sb.append('A');
                    sb.append(pluginResult.getMessage());
                    break;
                case PluginResult.MESSAGE_TYPE_MULTIPART:
                    sb.append('M');
                    for (int i = 0; i < pluginResult.getMultipartMessagesSize(); i++) {
                        PluginResult multipartMessage = pluginResult.getMultipartMessage(i);
                        sb.append(String.valueOf(calculateEncodedLengthHelper(multipartMessage)));
                        sb.append(' ');
                        encodeAsMessageHelper(sb, multipartMessage);
                    }
                    break;
                case PluginResult.MESSAGE_TYPE_JSON:
                default:
                    sb.append(pluginResult.getMessage()); // [ or {
            }
        }

        void encodeAsMessage(StringBuilder sb) {
            if (pluginResult == null) {
                sb.append('J')
                        .append(jsPayloadOrCallbackId);
                return;
            }
            int status = pluginResult.getStatus();
            boolean noResult = status == PluginResult.Status.NO_RESULT.ordinal();
            boolean resultOk = status == PluginResult.Status.OK.ordinal();
            boolean keepCallback = pluginResult.getKeepCallback();

            sb.append((noResult || resultOk) ? 'S' : 'F')
                    .append(keepCallback ? '1' : '0')
                    .append(status)
                    .append(' ')
                    .append(jsPayloadOrCallbackId)
                    .append(' ');

            encodeAsMessageHelper(sb, pluginResult);
        }

        void buildJsMessage(StringBuilder sb) {
            switch (pluginResult.getMessageType()) {
                case PluginResult.MESSAGE_TYPE_MULTIPART:
                    int size = pluginResult.getMultipartMessagesSize();
                    for (int i=0; i<size; i++) {
                        PluginResult subresult = pluginResult.getMultipartMessage(i);
                        QJsMessage submessage = new QJsMessage(subresult, jsPayloadOrCallbackId);
                        submessage.buildJsMessage(sb);
                        if (i < (size-1)) {
                            sb.append(",");
                        }
                    }
                    break;
                case PluginResult.MESSAGE_TYPE_BINARYSTRING:
                    sb.append("atob('")
                            .append(pluginResult.getMessage())
                            .append("')");
                    break;
                case PluginResult.MESSAGE_TYPE_ARRAYBUFFER:
                    sb.append("cordova.require('cordova/base64').toArrayBuffer('")
                            .append(pluginResult.getMessage())
                            .append("')");
                    break;
                case PluginResult.MESSAGE_TYPE_NULL:
                    sb.append("null");
                    break;
                default:
                    sb.append(pluginResult.getMessage());
            }
        }

        void encodeAsJsMessage(StringBuilder sb) {
            if (pluginResult == null) {
                sb.append(jsPayloadOrCallbackId);
            } else {
                int status = pluginResult.getStatus();
                boolean success = (status == PluginResult.Status.OK.ordinal()) || (status == PluginResult.Status.NO_RESULT.ordinal());
                sb.append("cordova.callbackFromNative('")
                        .append(jsPayloadOrCallbackId)
                        .append("',")
                        .append(success)
                        .append(",")
                        .append(status)
                        .append(",[");
                buildJsMessage(sb);
                sb.append("],")
                        .append(pluginResult.getKeepCallback())
                        .append(");");
            }
        }
    }
}