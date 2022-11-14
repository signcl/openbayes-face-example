//
//  OBFaceNetworking.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/13.
//

#import "OBFaceNetworking.h"

@interface OBFaceNetworking () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, copy) OBFaceNetworkingProgressBlock progressBlock;

@end

@implementation OBFaceNetworking

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.boundary = [self randomBoundary:16];
    }
    return self;
}

-(void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(OBFaceNetworkingSuccessBlock)success failure:(OBFaceNetworkingFailureBlock)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", bodyData.length] forHTTPHeaderField:@"Content-Length"];
    request.timeoutInterval = 3;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                success(dict);
            }else{
                failure(error);
            }
        });
    }];
    [task resume];
}

-(void)uploadFileWithURL:(NSString *)url fileData:(NSData *)fileData fileName:(NSString *)fileName progress:(OBFaceNetworkingProgressBlock)progress success:(OBFaceNetworkingSuccessBlock)success failure:(OBFaceNetworkingFailureBlock)failure {
    self.progressBlock = progress;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",self.boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *bodyData = [NSMutableData data];
    
    [bodyData appendData:[[NSString stringWithFormat:@"--%@",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"%@\"", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"Content-Type: application/*" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [bodyData appendData:fileData];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [bodyData appendData:[[NSString stringWithFormat:@"--%@--",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                success(dict);
            }else{
                failure(error);
            }
        });
    }];
    [task resume];
}

-(NSString *)randomBoundary:(int)len {
    char ch[len];
    for (int index = 0; index < len; index++) {
        int num = arc4random_uniform(75) + 48;
        if (num > 57 && num < 65) {
            num = num%57+48;
        }else if (num > 90 && num < 97) {
            num = num%90+65;
        }
        ch[index] = num;
    }
    
    NSString *randomStr = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"----WebKitFormBoundary%@",randomStr];
}

#pragma mark - NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.progressBlock) {
        self.progressBlock(1.0 * totalBytesSent / totalBytesExpectedToSend);
    }
}

@end
