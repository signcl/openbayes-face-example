package com.example.face.faceapi.demo.callback;

import java.io.File;

public interface NativeFaceDetectCallback {

    void onDetected(int faceCount);

    void onRecordDone(File file);
}
