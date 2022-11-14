package com.example.face.faceapi.demo.callback;

import com.example.face.faceapi.demo.model.DetectPicture;

import java.util.List;

public interface LivenessCallback {

    void onResult(boolean success, List<DetectPicture> pictures);
}
