package com.q.cordova.plugin;

import android.webkit.WebResourceResponse;
import android.webkit.WebView;

import org.apache.cordova.engine.SystemWebViewClient;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by adventis on 3/11/16.
 */
public class QbixWebViewClient extends SystemWebViewClient {
    public void setIsReturnCahceFilesFromBundle(boolean isReturnCahceFilesFromBundle) {
        this.isReturnCahceFilesFromBundle = isReturnCahceFilesFromBundle;
    }
    private boolean isReturnCahceFilesFromBundle;


    public void setPathToBundle(String pathToBundle) {
        this.pathToBundle = pathToBundle;
    }
    private String pathToBundle;

    public void setRemoteCacheId(String remoteCacheId) {
        this.remoteCacheId = remoteCacheId;
    }
    private String remoteCacheId;


    public void setListOfJsInjects(ArrayList<String> listOfJsInjects) {
        this.listOfJsInjects = listOfJsInjects;
    }

    private ArrayList<String> listOfJsInjects;

    private Map<String, String> availableMimeType = new HashMap<String, String>()
    {
        {
            put("png", "image/png");
            put("jpg", "image/jpeg");
            put("gif", "image/gif");
            put("js", "image/application/x-javascript");
            put("css", "text/css");
        }
    };

    public QbixWebViewClient(SystemWebViewEngine parentEngine) {
        super(parentEngine);
    }

    @Override
    public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
        URL urlParsed= null;
        try {
            urlParsed = new URL(url);
        } catch (MalformedURLException e) {
            e.printStackTrace();
            return super.shouldInterceptRequest(view, url);
        }

        String host = urlParsed.getHost();
        String relativePath = urlParsed.getPath();
        String filePath = null;

        if(host.equalsIgnoreCase(remoteCacheId) && isReturnCahceFilesFromBundle) {
            filePath = handleForGroupsCache(relativePath);
        } else {
            String pathToLocalFile = isFileInListOfInjects(relativePath);
            if(pathToLocalFile == null) {
                return super.shouldInterceptRequest(view, url);
            }
            filePath = pathToLocalFile;
        }

        InputStream is = null;
        try {
            is = view.getContext().getAssets().open(filePath);
            if(is != null && is.available() <= 0)
                return super.shouldInterceptRequest(view, url);
        } catch (IOException e) {
            e.printStackTrace();
            return super.shouldInterceptRequest(view, url);
        }

        WebResourceResponse response = new WebResourceResponse(fileMIMEType(relativePath),  "UTF-8", is);
        return response;
    }

//    -(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
//    {
//        NSURL *requestUrl = [request URL];
//
//        // Get the path for the request
//        NSString *pathString = [requestUrl relativePath];
//        NSString *filePath = nil;
//
//        NSString* host = [requestUrl host];
//        if([host isEqualToString:[self remoteCacheId]] && [self isReturnCahceFilesFromBundle]) {
//        filePath = [self handleForGroupsCache:pathString];
//    } else {
//        NSString* pathToLocalFile = [self isFileInListOfInjects:[requestUrl relativePath]];
//        if(pathToLocalFile == nil) {
//            return [super cachedResponseForRequest:request];
//        }
//
//        filePath = pathToLocalFile;
//    }
//
//        // Load the data
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        if(data == nil) return [super cachedResponseForRequest:request];
//
//        // Create the cacheable response
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:[self fileMIMEType: pathString] expectedContentLength:[data length] textEncodingName:nil];
//        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
//
//        return cachedResponse;
//    }

    private String fileMIMEType(String path)
    {
        String filename = getFileNameFromPath(path);
        if(filename == null)
            return null;

        List<String> pathParts = Arrays.asList(filename.split("."));
        if(pathParts != null && !pathParts.isEmpty()) {
            return availableMimeType.get(pathParts.get(pathParts.size()-1));
        }

        return null;
    }

    private String isFileInListOfInjects(String fileToSearch) {
        if(listOfJsInjects == null || fileToSearch == null) {
            return null;
        }

        String fileName = getFileNameFromPath(fileToSearch);

        for(String file: listOfJsInjects) {
            if(fileName.equalsIgnoreCase(getFileNameFromPath(file))) {
                return file;
            }
        }

        return null;

    }

    private String getFileNameFromPath(String path) {
        List<String> pathParts = Arrays.asList(path.split("/"));
        if(pathParts != null && !pathParts.isEmpty()) {
            return pathParts.get(pathParts.size()-1);
        }

        return null;
    }

    private String handleForGroupsCache(String pathString) {
        String filePathTemp = pathToBundle+pathString;

        return filePathTemp;
    }
}


//    -(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
//    {
//        NSURL *requestUrl = [request URL];
//
//        // Get the path for the request
//        NSString *pathString = [requestUrl relativePath];
//        NSString *filePath = nil;
//
//        NSString* host = [requestUrl host];
//        if([host isEqualToString:[self remoteCacheId]] && [self isReturnCahceFilesFromBundle]) {
//        filePath = [self handleForGroupsCache:pathString];
//    } else {
//        NSString* pathToLocalFile = [self isFileInListOfInjects:[requestUrl relativePath]];
//        if(pathToLocalFile == nil) {
//            return [super cachedResponseForRequest:request];
//        }
//
//        filePath = pathToLocalFile;
//    }
//
//        // Load the data
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        if(data == nil) return [super cachedResponseForRequest:request];
//
//        // Create the cacheable response
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:[self fileMIMEType: pathString] expectedContentLength:[data length] textEncodingName:nil];
//        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
//
//        return cachedResponse;
//    }
//
//    -(NSString*) handleForGroupsCache:(NSString*) pathString {
//        NSString *filePath = [NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], [self pathToBundle], pathString];
//        NSAssert(filePath, @"File %@ didn't exist", filePath);
//
//        return filePath;
//    }
//


//}
