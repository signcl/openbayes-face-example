//
//  OBFaceNetworking.h
//  OBFaceDemo
//
//  Created by SUN on 2022/11/13.
//

/**
 *功能：访问网络
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OBFaceNetworkingProgressBlock)(float progress);
typedef void (^OBFaceNetworkingSuccessBlock)(id responseObject);
typedef void (^OBFaceNetworkingFailureBlock)(NSError *error);

@interface OBFaceNetworking : NSObject
 
- (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(OBFaceNetworkingSuccessBlock)success failure:(OBFaceNetworkingFailureBlock)failure;
- (void)uploadFileWithURL:(NSString *)url fileData:(NSData *)fileData fileName:(NSString*)fileName progress:(OBFaceNetworkingProgressBlock)progress success:(OBFaceNetworkingSuccessBlock)success failure:(OBFaceNetworkingFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
