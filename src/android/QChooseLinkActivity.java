package com.q.cordova.plugin;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.webkit.ValueCallback;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.qbix.yang2020.R;

import org.apache.cordova.engine.SystemWebView;

public class QChooseLinkActivity extends QCordovaAbstractActivity {
    private Button closeBtn;
    private Button chooseBtn;
    private EditText urlEditText;
    private SystemWebView webView;

    public static Intent createIntent(Context context, String initUrl) {
        Intent intent = new Intent(context, QChooseLinkActivity.class);
        intent.putExtra(INIT_URL_KEY, initUrl);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        getActionBar().hide();
        setContentView(R.layout.q_choose_link_activity);
        setWebView(findViewById(R.id.webview_container));
        init();
    }

    @Override
    public Object onMessage(String id, Object data) {
        if ("onPageStarted".equalsIgnoreCase(id)) {
            urlEditText.post(new Runnable() {
                @Override
                public void run() {
                    urlEditText.setText((String)data);
                }
            });
        }
        return super.onMessage(id, data);

    }

    private void init() {
        webView = (SystemWebView) cordovaWebView.getEngine().getView();

        urlEditText = findViewById(R.id.url_editext);
        urlEditText.setOnEditorActionListener(
                new EditText.OnEditorActionListener() {
                    @Override
                    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                        if (actionId == EditorInfo.IME_ACTION_SEARCH ||
                                actionId == EditorInfo.IME_ACTION_DONE ||
                                event != null &&
                                        event.getAction() == KeyEvent.ACTION_DOWN &&
                                        event.getKeyCode() == KeyEvent.KEYCODE_ENTER) {
                            if (event == null || !event.isShiftPressed()) {
                                loadUrl(urlEditText.getText().toString());
                                return true; // consume.
                            }
                        }
                        return false; // pass on to other listeners.
                    }
                }
        );
        closeBtn = findViewById(R.id.close_btn);
        closeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setResult(RESULT_CANCELED);
                finish();
            }
        });
        chooseBtn = findViewById(R.id.choose_btn);
        chooseBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent data = new Intent();
                data.putExtra(URL_KEY, webView.getUrl());
                webView.evaluateJavascript(
                        "(function() { return ('<html>'+document.getElementsByTagName('html')[0].innerHTML+'</html>'); })();",
                        new ValueCallback<String>() {
                            @Override
                            public void onReceiveValue(String html) {
                                html = html.replace("\\u003C", "<");
                                if(html.charAt(0)=='\"') {
                                    html = html.substring(1);
                                }
                                if(html.charAt(html.length()-1)=='\"') {
                                    html = html.substring(0, html.length()-2);
                                }
                                QCordova.contentHTML = html;

                                setResult(RESULT_OK, data);
                                finish();
                            }
                        });
            }
        });

        this.initUrl = getIntent().getStringExtra(INIT_URL_KEY);
        urlEditText.setText(this.initUrl);

        loadUrl(this.initUrl);
    }

    private void loadUrl(String url) {
        cordovaWebView.loadUrl(url);
    }
}
