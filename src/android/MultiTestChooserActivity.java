package com.q.cordova.plugin;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by adventis on 11/13/16.
 */

public class MultiTestChooserActivity extends Activity {
    public final static String QTESTURL = "QTESTURL";

    EditText inputEditText;
    ListView urlHistoryListView;
    ArrayAdapter<String> urlHistoryListAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.multi_test_chooser_activity);
        init();
    }

    @Override
    protected void onResume() {
        super.onResume();
        inputEditText.clearFocus();
        urlHistoryListView.requestFocus();
    }

    private void init() {
        inputEditText = (EditText) findViewById(R.id.inputEditText);
        inputEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int actionId, KeyEvent keyEvent) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH ||
                        actionId == EditorInfo.IME_ACTION_DONE ||
                        keyEvent.getAction() == KeyEvent.ACTION_DOWN &&
                                keyEvent.getKeyCode() == KeyEvent.KEYCODE_ENTER) {
                        onInputFinished();
                        return true; // consume.
                }
                return false; // pass on to other listeners.
            }
        });
        urlHistoryListView = (ListView) findViewById(R.id.urlHistoryListView);
        urlHistoryListAdapter = new ArrayAdapter<String>(getBaseContext(), android.R.layout.simple_list_item_1, getBookmarksList());
        urlHistoryListView.setAdapter(urlHistoryListAdapter);
        urlHistoryListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                loadQCordovaApp((String)adapterView.getItemAtPosition(i));
            }
        });
    }

    private void onInputFinished() {
        String query = inputEditText.getText().toString();
        URL url = getNSURLFromString(query);
        if(url != null) {
            loadQCordovaApp(url.toString());
        } else {
            loadQCordovaApp("http://qbixstaging.com/"+ Uri.encode(query));
        }
    }

    private void loadQCordovaApp(String url) {
        startActivity((new Intent(this, MainActivity.class)).putExtra(QTESTURL, url));
        addNewBookmark(url);
    }

    private URL getNSURLFromString(String rawUrl) {
        try {
            URL url = new URL(rawUrl);
            if(url !=null && url.getProtocol() !=null && url.getHost() != null) {
                return url;
            }

            return null;
        } catch (Exception e) {
            return null;
        }
    }

    private ArrayList<String> getBookmarksList() {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        Set<String> bookmarks = preferences.getStringSet("bookmarks", null);
        if(bookmarks == null) {
            return new ArrayList<String>();
        }

        ArrayList<String> arrayList = new ArrayList<String>();
        for (String str : bookmarks) {
            if (str != null)
                arrayList.add(str);
        }

        return arrayList;
    }

    private void addNewBookmark(String newBookmark) {
        ArrayList<String> tmpBookmarksList = getBookmarksList();

        Boolean isDuplicate = false;
        for(int i=0; i < tmpBookmarksList.size(); i++) {
            if(tmpBookmarksList.get(i).equalsIgnoreCase(newBookmark)) {
                isDuplicate = true;
                break;
            }
        }
        if(!isDuplicate) {
            tmpBookmarksList.add(newBookmark);
        }

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = preferences.edit();
        Set<String> bookmarksSet = new HashSet<String>();
        for(String url: tmpBookmarksList)
            bookmarksSet.add(url);

        editor.putStringSet("bookmarks",bookmarksSet);
        editor.apply();
    }
}