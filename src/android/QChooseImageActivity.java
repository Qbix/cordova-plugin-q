package com.q.cordova.plugin;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import <packaged>.R;

import org.apache.cordova.engine.SystemWebView;

public class QChooseImageActivity extends QCordovaAbstractActivity {
    protected static String IMAGE_URL_KEY = "IMAGE_URL_KEY";
    private Button closeBtn;
    private SystemWebView webView;
    private String jsToInject;


    public static Intent createIntent(Context context, String initUrl) {
        Intent intent = new Intent(context, QChooseImageActivity.class);
        intent.putExtra(INIT_URL_KEY, initUrl);
        return intent;
    }

    public static Intent createIntentWithImageUrl(Context context, String imageUrl) {
        Intent intent = new Intent(context, QChooseImageActivity.class);
        intent.putExtra(IMAGE_URL_KEY, imageUrl);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        getActionBar().hide();
        setContentView(R.layout.q_choose_image_activity);
        setWebView(findViewById(R.id.webview_container));
        jsToInject = "(function() {setInterval(function() {" +
                "var top = 0;" +
                "var imgs = document.getElementsByTagName('img');" +
                "for (var i = 0, l = imgs.length; i < l; ++i) {" +
                "var img = imgs[i];" +
                "var found = null;" +
                "var p = img;" +
                "while (p = p.parentNode) {" +
                "if (p.tagName && p.tagName.toUpperCase() === 'A') {" +
                "found = p;" +
                "break;" +
                "}" +
                "}" +
                "if (found) {" +
                "continue;" +
                "}" +
                "if (!img._addedEventHandlers) {" +
                "img._addedEventHandlers = true;" +
                "img.addEventListener('touchstart', _handleTouchStart);" +
                "img.addEventListener('touchend', _handleTouchEnd);" +
                "}" +
                "function _handleTouchStart(e) {" +
                "console.log('handleTouchStart');" +
                "top = document.body.scrollTop;" +
                "}" +
                "function _handleTouchEnd(e) {" +
                "console.log('_handleTouchEnd');" +
                "if (Math.abs(top - document.body.scrollTop) > 10) return;" +
                "var src = e.target.getAttribute('src');" +
                "console.log(src);" +
                "_android_bridge.chooseImageEvent(src);" +
                "}" +
                "}}, 300);})();";
        init();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (intent.hasExtra(IMAGE_URL_KEY)) {
            Intent data = new Intent();
            data.putExtra(URL_KEY, intent.getStringExtra(IMAGE_URL_KEY));
            webView.evaluateJavascript(
                    "(function() { return ('<html>'+document.getElementsByTagName('html')[0].innerHTML+'</html>'); })();",
                    new ValueCallback<String>() {
                        @Override
                        public void onReceiveValue(String html) {
                            html = html.replace("\\u003C", "<");
                            if (html.charAt(0) == '\"') {
                                html = html.substring(1);
                            }
                            if (html.charAt(html.length() - 1) == '\"') {
                                html = html.substring(0, html.length() - 2);
                            }
                            QCordova.contentHTML = html;

                            setResult(RESULT_OK, data);
                            finish();
                        }
                    });
        }
    }

    private void init() {
        webView = (SystemWebView) cordovaWebView.getEngine().getView();
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.addJavascriptInterface(new QChooseImageActivity.WebAppInterface(this), "_android_bridge");

        closeBtn = findViewById(R.id.close_btn);
        closeBtn.setOnClickListener(view -> {
            setResult(RESULT_CANCELED);
            finish();
        });

        findViewById(R.id.alert_btn).setOnClickListener(view -> {
            webView.loadUrl("javascript:alert('Hello world')");
        });

        this.initUrl = getIntent().getStringExtra(INIT_URL_KEY);
        loadUrl(this.initUrl);
    }

    @Override
    public Object onMessage(String id, Object data) {
        if ("onPageFinished".equalsIgnoreCase(id)) {
            webView.loadUrl("javascript:"+jsToInject);
        }
        return super.onMessage(id, data);

    }


    private void loadUrl(String url) {
        cordovaWebView.loadUrl(url);
    }

    public class WebAppInterface {
        Context mContext;

        /** Instantiate the interface and set the context */
        WebAppInterface(Context c) {
            mContext = c;
        }

        /** Show a toast from the web page */
        @JavascriptInterface
        public void chooseImageEvent(String imageURL) {
            mContext.startActivity(QChooseImageActivity.createIntentWithImageUrl(mContext, imageURL));
        }
    }
}
