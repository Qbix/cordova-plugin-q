package com.q.cordova.plugin.network;


import com.q.cordova.plugin.network.models.PingResponse;

import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;

/**
 * Created by adventis on 3/19/16.
 */
public interface NetworkApi {

    @GET("/iphone/daily")
    Call<PingResponse> ping(@Query(value = "udid", encoded=true)  String udid);

}
