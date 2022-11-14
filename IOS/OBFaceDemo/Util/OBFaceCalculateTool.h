//
//  OBFaceCalculateTool.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

/**
 *功能：用来计算手机显示区域
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBFaceCalculateTool : NSObject

+ (CGFloat)safeTopMargin;

+ (CGFloat)safeBottomMargin;

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

@end

NS_ASSUME_NONNULL_END
