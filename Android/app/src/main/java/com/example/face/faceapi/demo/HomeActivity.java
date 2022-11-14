package com.example.face.faceapi.demo;

import static com.example.face.faceapi.demo.callback.Action.LOGIN;
import static com.example.face.faceapi.demo.callback.Action.REGISTER;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.example.face.faceapi.demo.camera.CameraActivity;
import com.example.face.faceapi.demo.model.UserDetectResult;

public class HomeActivity extends AppCompatActivity implements View.OnClickListener {

    private ActivityResultLauncher<Intent> launcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        findViewById(R.id.face_register).setOnClickListener(this);
        findViewById(R.id.face_login).setOnClickListener(this);
        launcher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        Intent data = result.getData();
                        String action = data.getStringExtra("action");
                        switch (action) {
                            case LOGIN:
                                if (result.getResultCode() == Activity.RESULT_OK) {
                                    String userId = data.getStringExtra("userId");
                                    double score = data.getDoubleExtra("score", 0);
                                    this.onLoginSuccess(new UserDetectResult(userId, score));
                                }
                                break;
                            case REGISTER:
                                if (result.getResultCode() == Activity.RESULT_OK) {
                                    this.onRegistrationSuccess();
                                }
                                break;
                        }
                        String userId = data.getStringExtra("userId");
                        double score = data.getDoubleExtra("score", 0);
                        this.onLoginSuccess(new UserDetectResult(userId, score));
                    }
                });
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.face_register:
                registerUser("test");
                break;
            case R.id.face_login:
                loginUser();
                break;
        }
    }

    private void registerUser(String userId) {
        Intent intent = new Intent(this, CameraActivity.class);
        intent.putExtra("action", REGISTER);
        intent.putExtra("userId", userId);
        launcher.launch(intent);
    }

    private void loginUser() {
        Intent intent = new Intent(this, CameraActivity.class);
        intent.putExtra("action", LOGIN);
        launcher.launch(intent);
    }

    public void onLoginSuccess(UserDetectResult result) {
        Log.d("Test", "User login successfully as " + result.getUserId());
        Toast.makeText(this, "登录用户id 为" + result.getUserId(), Toast.LENGTH_LONG).show();
    }

    public void onRegistrationSuccess() {
        Log.d("Test", "User registration success");
        Toast.makeText(this, "成功绑定用户面部识别", Toast.LENGTH_LONG).show();
    }
}