//
//  OBFaceCameraView.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/7.
//

/**
 *进行视频流解析并且活体检测的view
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LivenessRemindCode) {
    LivenessRemindCodeNoFaceDetected, //没有检测到人脸
    LivenessRemindCodeTooFar,    //太远
    LivenessRemindCodeLiveEye,   //眨眨眼
    LivenessRemindCodeLiveMouth, //张大嘴
    LivenessRemindCodeTimeout    //超时
};

typedef void(^OBFaceCameraCompletedBlock)(UIImage *faceImage);
typedef void(^OBFaceCameraLivenessRemindBlock)(LivenessRemindCode code);

@interface OBFaceCameraView : UIView

-(void)handleCompletedBlock:(OBFaceCameraCompletedBlock)block;
-(void)handleLivenessRemindBlock:(OBFaceCameraLivenessRemindBlock)block;
-(void)preparCamera;
-(void)startRunning;
-(void)stopRunning;

@end

NS_ASSUME_NONNULL_END
