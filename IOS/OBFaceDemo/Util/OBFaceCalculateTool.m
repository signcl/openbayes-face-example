//
//  OBFaceCalculateTool.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

#import "OBFaceCalculateTool.h"

@implementation OBFaceCalculateTool

+ (UIEdgeInsets)safeMargin {
    // 只算一次，把各个状态的值记录下来
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets (^getEdge)(void) = ^(){
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window) window = [UIWindow new];
            return window.safeAreaInsets;
        };
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
            static UIEdgeInsets _portraitEdge;
            static dispatch_once_t _portraitOnceToken;
            dispatch_once(&_portraitOnceToken, ^{
                _portraitEdge = getEdge();
            });
            return _portraitEdge;
        }
        else if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown) {
            static UIEdgeInsets _portraitUpsideDownEdge;
            static dispatch_once_t _portraitUpsideDownOnceToken;
            dispatch_once(&_portraitUpsideDownOnceToken, ^{
                _portraitUpsideDownEdge = getEdge();
            });
            return _portraitUpsideDownEdge;
        }
        else if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            static UIEdgeInsets _landscapeEdge;
            static dispatch_once_t _landscapeOnceToken;
            dispatch_once(&_landscapeOnceToken, ^{
                _landscapeEdge = getEdge();
            });
            return _landscapeEdge;
        }
        else {
            return getEdge();
        }
    } else {
        return UIEdgeInsetsZero;
    }
}


+ (CGFloat)safeTopMargin {
    return [self safeMargin].top;
}

+ (CGFloat)safeBottomMargin {
    return [self safeMargin].bottom;
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

@end
