//
//  OBFaceLivenessViewController.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

/**
 *用来活体检测的视图控制器
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OBFaceLivenessCompletedBlock)(UIImage *faceImage);

@interface OBFaceLivenessViewController : UIViewController

/**
 *活体检测成功后返回人像UIImage
 */
-(void)handleCompletedBlock:(OBFaceLivenessCompletedBlock)block;

@end

NS_ASSUME_NONNULL_END
