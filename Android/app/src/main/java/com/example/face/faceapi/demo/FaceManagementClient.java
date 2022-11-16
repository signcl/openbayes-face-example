package com.example.face.faceapi.demo;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.example.face.faceapi.demo.callback.LivenessCallback;
import com.example.face.faceapi.demo.callback.RegisterCallback;
import com.example.face.faceapi.demo.callback.UserDetectCallback;
import com.example.face.faceapi.demo.model.DetectPicture;
import com.example.face.faceapi.demo.model.UserDetectResult;
import com.squareup.okhttp.Callback;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class FaceManagementClient {

    private String appId;
    private String host;
    private String v3Host;

    private OkHttpClient client = new OkHttpClient();
    private static MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    public FaceManagementClient(Context context) {
        try {
            ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            host = ai.metaData.get("server_host") + "/face-api/";
            v3Host = host + "/v3/face";
            appId = ai.metaData.getString("app_id");
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

    }

    public void register(String image, String userId, RegisterCallback callback) {
        JSONObject object = new JSONObject();
        try {
            object.put("image", image);
            object.put("image_type", "BASE64");
            object.put("user_id", userId);
            object.put("group_id", "normal_user");
            String json = object.toString();
            RequestBody requestBody = RequestBody.create(JSON, json);
            Request request = new Request.Builder()
                    .url(v3Host + "/add?appId=" + appId)
                    .method("POST", requestBody)
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Request request, IOException e) {
                    callback.onResponse(false);
                }

                @Override
                public void onResponse(Response response) throws IOException {
                    try {
                        String body = response.body().string();
                        Log.e("shit",body);
                        JSONObject json = new JSONObject(body);
                        JSONObject result = json.getJSONObject("result");
                        if ("SUCCESS".equals(json.getString("error_msg")) && result.has("face_token") && result.has("location")) {
                            callback.onResponse(true);
                        } else {
                            callback.onResponse(false);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callback.onResponse(false);
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void login(String imageBase, final UserDetectCallback callback) {
        JSONObject object = new JSONObject();
        try {
            object.put("image", imageBase);
            object.put("image_type", "BASE64");
            object.put("group_id_list", "normal_user");
            object.put("match_threshold", 90);
            String json = object.toString();
            RequestBody requestBody = RequestBody.create(JSON, json);
            Request request = new Request.Builder()
                    .url(v3Host + "/identify?appId=" + appId)
                    .method("POST", requestBody)
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Request request, IOException e) {
                    callback.onUserDetected(null);
                }

                @Override
                public void onResponse(Response response) throws IOException {
                    try {
                        String body = response.body().string();
                        JSONObject json = new JSONObject(body);
                        final JSONArray userList = json.getJSONObject("result").getJSONArray("user_list");
                        if (userList.length() > 0) {
                            List<UserDetectResult> result = new LinkedList<>();
                            for (int index = 0; index < userList.length(); index++) {
                                JSONObject u = (JSONObject) userList.get(index);
                                String id = u.getString("user_id");
                                Double score = u.getDouble("score");
                                result.add(new UserDetectResult(id, score));
                            }
                            Collections.sort(result);
                            callback.onUserDetected(result.get(0));
                        } else {
                            callback.onUserDetected(null);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void liveness(String videoBase64, LivenessCallback callback) {
        JSONObject object = new JSONObject();
        try {
            object.put("video_base64", videoBase64);
            String json = object.toString();
            RequestBody requestBody = RequestBody.create(JSON, json);
            Request request = new Request.Builder()
                    .url(host + "/face/liveness?appId=" + appId)
                    .method("POST", requestBody)
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Request request, IOException e) {
                    callback.onResult(false, Collections.emptyList());
                }

                @Override
                public void onResponse(Response response) throws IOException {
                    try {
                        String body = response.body().string();
                        JSONObject json = new JSONObject(body);
                        final JSONObject result = json.getJSONObject("result");
                        if (result.has("score")) {
                            double score = result.getDouble("score");
                            double threshold = result.getJSONObject("thresholds").getDouble("frr_1e-2");
                            if (score > threshold) {
                                JSONArray picList = result.getJSONArray("pic_list");
                                List<DetectPicture> pictures = new LinkedList<>();
                                for (int index = 0; index < picList.length(); index++) {
                                    JSONObject po = (JSONObject) picList.get(0);
                                    String faceId = po.getString("face_id");
                                    String pic = po.getString("pic");
                                    pictures.add(new DetectPicture(faceId, pic));
                                }
                                callback.onResult(true, pictures);
                            } else {
                                callback.onResult(false, Collections.emptyList());
                            }
                        } else {
                            callback.onResult(false, Collections.emptyList());
                        }

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
