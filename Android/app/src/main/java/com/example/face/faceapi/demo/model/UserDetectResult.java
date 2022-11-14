package com.example.face.faceapi.demo.model;


import androidx.annotation.NonNull;

public class UserDetectResult implements Comparable<UserDetectResult>{
    private Double score;
    private String userId;

    public UserDetectResult(String userId, double score) {
        this.score = score;
        this.userId = userId;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    @Override
    public int compareTo(@NonNull UserDetectResult o) {
        return this.score.compareTo(o.getScore());
    }
}
