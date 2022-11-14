package com.example.face.faceapi.demo.model;

public class DetectPicture {
    private String faceId;
    private String basedImage;

    public DetectPicture(String faceId, String pic) {
        this.faceId = faceId;
        this.basedImage = pic;
    }

    public String getFaceId() {
        return faceId;
    }

    public String getBasedImage() {
        return basedImage;
    }
}
