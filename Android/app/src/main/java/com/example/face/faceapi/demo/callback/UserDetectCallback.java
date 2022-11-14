package com.example.face.faceapi.demo.callback;

import com.example.face.faceapi.demo.model.UserDetectResult;

public interface UserDetectCallback {

    void onUserDetected(UserDetectResult result);
}
