//
//  OBFaceSuccessViewController.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

/**
 *活体检测通过后，进行人脸比对来确认人脸库是否包含此用户
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBFaceSuccessViewController : UIViewController

/**
 *活体检测通过后，返回的人像图
 */
@property (nonatomic, strong) UIImage *successImage;

/**
 *用来判断点击”登录“或者”注册“按钮的标识
 */
@property (nonatomic, assign) BOOL clickedLogin;

@end

NS_ASSUME_NONNULL_END
