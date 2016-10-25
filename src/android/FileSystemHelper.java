package com.q.cordova.plugin;

import android.content.Context;
import android.widget.ArrayAdapter;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

/**
 * Created by adventis on 3/11/16.
 */
public class FileSystemHelper {
    public ArrayList<String> getSearchedFiles() {
        return searchedFiles;
    }

    ArrayList<String> searchedFiles;

    public FileSystemHelper() {
        this.searchedFiles = new ArrayList<String>();
    }

    public void recursiveSearchByExtension(Context ctx, String searchDirectory, String searchExtension) throws IOException {
        if (searchDirectory != null) {
            String[] files = ctx.getAssets().list(searchDirectory);
            if(files != null) {
                for (int i = 0; i < files.length; i++) {
                    if(ctx.getAssets().list(searchDirectory + "/" + files[i]).length > 0) {
                        recursiveSearchByExtension(ctx, searchDirectory + "/" + files[i], searchExtension);
                    }

                    if(files[i].contains("."+searchExtension)) {
                        this.searchedFiles.add(searchDirectory + "/" + files[i]);
                    }
                }
            }
        }
    }
}
