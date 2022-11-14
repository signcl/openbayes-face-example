//
//  OBFaceToastView.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

/**
 *功能：用来弹出提示框
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBFaceToastView : UIView

+ (void)showToast:(UIView *)superview text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
