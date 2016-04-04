package com.q.cordova.plugin.network;

import android.content.Context;

import com.q.cordova.plugin.QConfig;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * Created by adventis on 3/19/16.
 */
public class NetworkService {
    private String END_POINT;

    public NetworkApi getApi() {
        return api;
    }

    private NetworkApi api;

    public NetworkService(Context ctx) {
        END_POINT = QConfig.getInstance(ctx).getPingUrl();
        Retrofit service = new Retrofit.Builder()
                .baseUrl(END_POINT)
                .addConverterFactory(GsonConverterFactory.create())
                //.addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .build();


        api = service.create(NetworkApi.class);
    }
}
