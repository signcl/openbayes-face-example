//
//  OBFaceCameraView.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/7.
//

#import "OBFaceCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import "OBFaceToastView.h"
#import "OBFaceNetworking.h"
#import "OBFaceConfig.h"

@interface OBFaceCameraView () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;//session：由他把输入输出结合在一起，并开始启动捕获设备
@property (nonatomic, strong) AVCaptureDevice *device; // 视频输入设备
@property (nonatomic ,strong) AVCaptureDeviceInput *deviceInput;//图像输入源
@property (nonatomic ,strong) AVCaptureVideoDataOutput *videoPutData;   //视频输出源
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVAssetWriter *writer;//视频采集
@property (nonatomic ,strong) AVAssetWriterInput *writerVideoInput;//视频采集

@property (nonatomic, copy) OBFaceCameraCompletedBlock completedBlock;
@property (nonatomic, copy) OBFaceCameraLivenessRemindBlock livenessRemindBlock;

@property (nonatomic, strong) NSURL *videoFilePath;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL canWritting;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL timeout;

//录视频计时器
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) CGFloat recordSeconds;
@property (nonatomic, assign) CGFloat signal;

@end

@implementation OBFaceCameraView

-(void)handleCompletedBlock:(OBFaceCameraCompletedBlock)block {
    self.completedBlock = block;
}

-(void)handleLivenessRemindBlock:(OBFaceCameraLivenessRemindBlock)block {
    self.livenessRemindBlock = block;
}

-(void)preparCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if (authStatus == AVAuthorizationStatusDenied) {
        [OBFaceToastView showToast:self.superview text:@"未开启相机权限"];
    }else {
        self.session = [[AVCaptureSession alloc] init];
        if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]){
            self.session.sessionPreset = AVCaptureSessionPresetHigh;
        }else if ([self.session canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
            self.session.sessionPreset = AVCaptureSessionPresetiFrame960x540;
        }
        
        self.device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        
        self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
        if ([self.session canAddInput:self.deviceInput]) {
            [self.session addInput:self.deviceInput];
        }
        
        NSDictionary *videoSetting = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        self.videoPutData = [[AVCaptureVideoDataOutput alloc] init];
        self.videoPutData.videoSettings = videoSetting;
        self.videoPutData.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
        dispatch_queue_t videoQueue = dispatch_queue_create("video", DISPATCH_QUEUE_CONCURRENT);
        [self.videoPutData setSampleBufferDelegate:self queue:videoQueue];
        if ([self.session canAddOutput:self.videoPutData]) {
            [self.session addOutput:self.videoPutData];
        }
        // 设置 imageConnection 控制相机拍摄视频的角度方向
        AVCaptureConnection *imageConnection = [self.videoPutData connectionWithMediaType:AVMediaTypeVideo];
        if (imageConnection.supportsVideoOrientation) {
            imageConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        self.previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:self.previewLayer];
        
        //开始启动
        [self.session startRunning];
        if ([self.device lockForConfiguration:nil]) {
            if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            [self.device unlockForConfiguration];
        }
    }
}

-(void)startRunning {
    self.timeout = NO;
    self.finished = NO;
    [self.session startRunning];
}

-(void)stopRunning {
    [self.session stopRunning];
}

-(void)startRecord {
    self.videoFilePath = [self createVideoFilePathUrl];
    
    dispatch_queue_t writeQueueCreate = dispatch_queue_create("writeQueueCreate", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(writeQueueCreate, ^{
        NSError *error = nil;
        self.writer = [AVAssetWriter assetWriterWithURL:self.videoFilePath fileType:AVFileTypeMPEG4 error:&error];
        
        CGFloat width = 480;
        CGFloat height = 640;
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey : @(200 * 8 * 1024),
                                                 AVVideoExpectedSourceFrameRateKey : @(25),
                                                 AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel};
        //视频属性
        NSDictionary *videoSetting = @{ AVVideoCodecKey : AVVideoCodecH264,
                                        AVVideoWidthKey : @(width),
                                        AVVideoHeightKey : @(height),
                                        AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                        AVVideoCompressionPropertiesKey : compressionProperties };
        self.writerVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSetting];
        self.writerVideoInput.expectsMediaDataInRealTime = YES; //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
        
        if ([self.writer canAddInput:self.writerVideoInput]) {
            [self.writer addInput:self.writerVideoInput];
        }
        
        self.isRecording = YES;
    });
}

-(void)stopRecordWithCompleted:(BOOL)completed {
    if (self.writer.status == AVAssetWriterStatusWriting) {
        self.canWritting = NO;
        self.isRecording = NO;
        
        if (completed == YES) {
            self.finished = YES;
        }
        
        /// 完成录制
        dispatch_queue_t writeQueue = dispatch_queue_create("writeQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(writeQueue, ^{
            [self.writer finishWritingWithCompletionHandler:^{
                if (completed == YES) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self faceLiveness];
                    });
                }
            }];
        });
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    if (@available(iOS 10.2, *)) {
        NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera];//设备类型：广角镜头、双镜头
        AVCaptureDeviceDiscoverySession *sessionDiscovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:position];
        NSArray<AVCaptureDevice *> *devices = sessionDiscovery.devices;//当前可用的AVCaptureDevice集合

        __block AVCaptureDevice *newVideoDevice = nil;
        //遍历所有可用的AVCaptureDevice，获取 后置双镜头
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( device.position == position && [device.deviceType isEqualToString:AVCaptureDeviceTypeBuiltInDualCamera] ) {
                newVideoDevice = device;
                * stop = YES;
            }
        }];

        if (!newVideoDevice){
            //如果后置双镜头获取失败，则获取广角镜头
            [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( device.position == position) {
                    newVideoDevice = device;
                    * stop = YES;
                }
            }];
        }

        return newVideoDevice;
    } else {
        //获取指定mediaType类型的AVCaptureDevice集合
        NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

        __block AVCaptureDevice *newVideoDevice = nil;
        //遍历所有可用的AVCaptureDevice，获取后置镜头
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( device.position == position) {
                newVideoDevice = device;
                * stop = YES;
            }
        }];

        return newVideoDevice;
    }
}

- (NSURL *)createVideoFilePathUrl {
    NSString *documentPath = [NSHomeDirectory() stringByAppendingString:@"/tmp/shortVideo"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];

    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *videoName = [destDateString stringByAppendingString:@".mp4"];

    NSString *filePath = [documentPath stringByAppendingFormat:@"/%@",videoName];

    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![manager fileExistsAtPath:documentPath isDirectory:&isDir]) {
        [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSURL fileURLWithPath:filePath];
}

- (UIImage *)imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef)sampleBuffer {
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        CGImageRelease(quartzImage);
        return (image);
    }
}

-(void)detectFaceWithImage:(UIImage *)faceImg {
    if (faceImg != nil) {
        CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow,CIDetectorNumberOfAngles:@1}];
        CIImage *ciimg = [CIImage imageWithCGImage:faceImg.CGImage];
        NSArray *features = [faceDetector featuresInImage:ciimg];
        
        CGRect faceRect = CGRectZero;
        CIFaceFeature *faceFeature = [features firstObject];
        if (faceFeature) {
            faceRect = faceFeature.bounds;
        }
        
        CGPoint imgCenter = CGPointMake(faceImg.size.width/2.0, faceImg.size.height/2.0);
        CGFloat diameter = MIN(faceImg.size.width, faceImg.size.height);
        CGFloat maxRadius = (diameter * 1.0)/2.0;
        CGFloat minRadius = (diameter * 0.3)/2.0;
        CGRect maxRect = CGRectMake(imgCenter.x - maxRadius, imgCenter.y - maxRadius, maxRadius * 2, maxRadius * 2);
        if (CGRectContainsRect(maxRect, faceRect) == YES) {
            if (CGRectGetWidth(faceRect) > minRadius * 2 && CGRectGetHeight(faceRect) > minRadius * 2) {
                self.signal = 0;

                if (self.isRecording == NO && self.finished == NO && self.timeout == NO) {
                    if (self.recordTimer) {
                        [self.recordTimer invalidate];
                        self.recordTimer = nil;
                    }

                    [self startRecord];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.recordSeconds = 0;
                        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(recordTimerFired:) userInfo:nil repeats:YES];
                    });
                }
            }else {
                if (self.livenessRemindBlock) {
                    self.livenessRemindBlock(LivenessRemindCodeTooFar);
                }

                if (self.isRecording == YES && self.signal == 0) {
                    //录制过程中 检测到人脸过小
                    self.signal = self.recordSeconds;
                }
            }
        }else {
            if (self.livenessRemindBlock) {
                self.livenessRemindBlock(LivenessRemindCodeNoFaceDetected);
            }

            if (self.isRecording == YES && self.signal == 0) {
                //录制过程中 检测到人脸离开
                self.signal = self.recordSeconds;
            }
        }
    }
}

-(void)recordTimerFired:(NSTimer *)timer {
    if (self.signal > 0) {
        //未检测到人脸超过2秒 则算作超时
        if (self.recordSeconds - self.signal >= 2) {
            self.timeout = YES;
            self.signal = 0;
            
            if (self.recordTimer) {
                [self.recordTimer invalidate];
                self.recordTimer = nil;
            }
            [self stopRecordWithCompleted:NO];
            
            if (self.livenessRemindBlock) {
                self.livenessRemindBlock(LivenessRemindCodeTimeout);
            }
        }
    }else {
        if (self.recordSeconds >= 3) {
            if (self.livenessRemindBlock) {
                self.livenessRemindBlock(LivenessRemindCodeLiveEye);
            }
        }else if (self.recordSeconds >= 0) {
            if (self.livenessRemindBlock) {
                self.livenessRemindBlock(LivenessRemindCodeLiveMouth);
            }
        }
    }
    
    if (self.recordSeconds >= 6) {
        self.recordSeconds = 0;
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        
        [self stopRecordWithCompleted:YES];
    }
    
    self.recordSeconds += 0.01;
}

/**********************************************************************************/

/**
 活体检测
 
 字段                必选     类型                 说明
 score               是     float                活体检测分数。此分数为视频分析结果，不包含语音验证结果，语音验证。需开发基于自己的业务需求做判断。
 maxspoofing         是     float                合成图检测分数。返回的1-8张图片中合成图检测得分的最大值 范围[0,1]，分数越高则概率越大。
 thresholds          是     array                阈值参考，实际业务应用中，请以score>阈值判定通过，可直接选择不同误识别率的阈值，无需对应具体的分值，选择阈值参数即可。
 pic_list            是     array                抽取图片信息列表
 pic_list[i].face_id 是     string               face唯一ID
 pic_list[i].pic     是     string/encryption    base64编码后的图片信息
 
 返回示例
 {
     err_no:0,
     err_msg: 'success',
     result: {
         score: 0.984654366,
         thresholds: {
             "frr_1e-4": 0.05, //万分之一误识别率的阈值
             "frr_1e-3": 0.3,  //千分之一误识别率的阈值
             "frr_1e-2": 0.9   //百分之一误识别率的阈值
            },
  
            pic_list: [
                {
                  "face_id": 5745745747,
                  "pic": "gsagaheryzxv..."
                },
                {
                  "face_id": 5745745747,
                  "pic": "gsagaheryzxv..."
                }
            ]
      },
      "timestamp": 1509611848,
      "cached": 0,
      "serverlogid": "2248375729"
 }
 */
-(void)faceLiveness {
    NSString *fileUrlStr = self.videoFilePath.absoluteString;
    if ([fileUrlStr hasPrefix:@"file://"]) {
        fileUrlStr = [fileUrlStr substringFromIndex:7];
    }
    NSString *fileName = [fileUrlStr lastPathComponent];
    NSData *videoData = [NSData dataWithContentsOfFile:fileUrlStr options:NSDataReadingMappedIfSafe error:nil];
    
    OBFaceNetworking *req = [[OBFaceNetworking alloc] init];
    [req uploadFileWithURL:[NSString stringWithFormat:@"%@/face-api/face/liveness?appid=%@",OBFace_url, OBFace_appid] fileData:videoData fileName:fileName progress:^(float progress) {
        
    } success:^(id  _Nonnull responseObject) {
        NSLog(@"1: %@",responseObject);
        NSInteger err_no = [[responseObject objectForKey:@"err_no"] integerValue];
        if (err_no == 0) {
            NSDictionary *result = [responseObject objectForKey:@"result"];
            CGFloat score = [[result objectForKey:@"score"] doubleValue];
            NSDictionary *thresholds = [result objectForKey:@"thresholds"];
            CGFloat frr_1e_3 = [[thresholds objectForKey:@"frr_1e-3"] doubleValue];
            
            UIImage *image = nil;
            if (score > frr_1e_3) {
                //活体检测通过
                NSArray *pic_list = [result objectForKey:@"pic_list"];
                if (pic_list.count > 0) {
                    NSDictionary *firstPic = [pic_list firstObject];
                    NSString *pic = [NSString stringWithFormat:@"%@",[firstPic objectForKey:@"pic"]];
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:pic options:0];
                    image = [UIImage imageWithData:data];
                }
            }
            
            if (image != nil) {
                if (self.completedBlock) {
                    self.completedBlock(image);
                }
            }else {
                [self stopRunning];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"人脸采集失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新采集" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self startRunning];
                }];
                [alertController addAction:action];
                [[self viewController] presentViewController:alertController animated:YES completion:nil];
            }
        }else {
            NSString *error_msg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"error_msg"]];
            
            [self stopRunning];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"人脸采集失败" message:error_msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新采集" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self startRunning];
            }];
            [alertController addAction:action];
            [[self viewController] presentViewController:alertController animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [self stopRunning];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"人脸采集失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新采集" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self startRunning];
        }];
        [alertController addAction:action];
        [[self viewController] presentViewController:alertController animated:YES completion:nil];
    }];
}

-(UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CMFormatDescriptionRef desMedia = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(desMedia);
    if (mediaType == kCMMediaType_Video) {
        if (self.canWritting == NO && self.isRecording == YES) {
            NSLog(@"start video");
            [self.writer startWriting];
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            self.canWritting = YES;
            [self.writer startSessionAtSourceTime:timestamp];
        }
        
        if (self.canWritting == YES) {
            if (self.writerVideoInput.readyForMoreMediaData) {
                BOOL success = [self.writerVideoInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    NSLog(@"video write failed");
                }
            }
        }
        
        UIImage* sampleImage = [self imageFromSamplePlanerPixelBuffer:sampleBuffer];
        [self detectFaceWithImage:sampleImage];
    }
}

@end
