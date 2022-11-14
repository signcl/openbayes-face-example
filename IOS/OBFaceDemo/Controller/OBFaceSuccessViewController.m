//
//  OBFaceSuccessViewController.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

#import "OBFaceSuccessViewController.h"
#import "OBFaceCalculateTool.h"
#import "OBFaceToastView.h"
#import "OBFaceNetworking.h"
#import <CoreServices/CoreServices.h>
#import "OBFaceConfig.h"

@interface OBFaceSuccessViewController ()

@property (nonatomic, strong) UILabel *successLabel;

@end

@implementation OBFaceSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, [OBFaceCalculateTool safeTopMargin], 44, 44);
    [backButton setImage:[UIImage imageNamed:@"icon_titlebar_close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // 成功图片显示和label
    UIImageView *successImageView = [[UIImageView alloc] init];
    successImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2.0, CGRectGetMaxY(backButton.frame) + 100, 100, 100);
    successImageView.image = self.successImage;
    successImageView.layer.masksToBounds = YES;
    successImageView.layer.cornerRadius = 50;
    successImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:successImageView];
        
    UILabel *successLabel = [[UILabel alloc] init];
    successLabel.font = [UIFont boldSystemFontOfSize:22];
    successLabel.textColor = [UIColor blackColor];
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.numberOfLines = 0;
    [self.view addSubview:successLabel];
    self.successLabel = successLabel;
    
    [self faceIdentify:self.successImage];
}

- (void)backAction:(UIButton *)sende{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**********************************************************************************/

/**
 人像识别
 
 参数             必选     类型       说明
 image            是     string     图片信息(总数据大小应小于10M)，图片上传方式根据image_type来判断
 image_type       是     string     图片类型 BASE64:图片的base64值，base64编码后的图片数据，编码后的图片大小不超过2M；
                                    FACE_TOKEN: 人脸图片的唯一标识，调用人脸检测接口时，会为每个人脸图片赋予一个唯一的FACE_TOKEN，同一张图片多次检测得到的FACE_TOKEN是同一个。
 group_id_list    是     string     从指定的group中进行查找 用逗号分隔，上限10个
 quality_control  否     string     图片质量控制 NONE: 不进行控制 LOW:较低的质量要求 NORMAL: 一般的质量要求 HIGH: 较高的质量要求 默认 NONE
                                    若图片质量不满足要求，则返回结果中会提示质量检测失败
 liveness_control 否     string     活体检测控制 NONE: 不进行控制 LOW:较低的活体要求(高通过率 低攻击拒绝率) NORMAL: 一般的活体要求(平衡的攻击拒绝率, 通过率) HIGH: 较高的活体要求(高攻击拒绝率 低通过率) 默认NONE 若活体检测结果不满足要求，则返回结果中会提示活体检测失败
 user_id          否     string     当需要对特定用户进行比对时，指定user_id进行比对。即人脸认证功能。
 match_threshold  否     int         匹配阈值（设置阈值后，score低于此阈值的用户信息将不会返回） 最大100 最小0 默认0 此阈值设置得越高，检索速度将会越快，推荐使用80的阈值
 max_user_num     否     unit32     查找后返回的用户数量。返回相似度最高的几个用户，默认为1，最多返回50个,若您想要修改最大返回人脸数量，请参考4.如何控制1：N返回的最大人脸数问题文档
 
 返回示例
 {
     "error_code": 0,
     "error_msg": "SUCCESS",
     "log_id": 1234567890123,
     "timestamp": 1533094591,
     "cached": 0,
     "result": {
         "face_token": "fid",
         "user_list": [
             {
                 "group_id": "test1",
                 "user_id": "u333333",
                 "user_info": "Test User",
                 "score": 99.3
             }
         ]
     }
 }
 */
-(void)faceIdentify:(UIImage*)faceImage {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSData *data = [self convertImage:faceImage];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    [parameters setObject:base64String forKey:@"image"];
    [parameters setObject:@"BASE64" forKey:@"image_type"];
    [parameters setObject:OBFace_groupid forKey:@"group_id_list"];
    [parameters setObject:@"NONE" forKey:@"quality_control"];
    [parameters setObject:@"NONE" forKey:@"liveness_control"];
    [parameters setObject:@(80) forKey:@"match_threshold"];
    [parameters setObject:@(1) forKey:@"max_user_num"];
    
    OBFaceNetworking *req = [[OBFaceNetworking alloc] init];
    [req postWithURL:[NSString stringWithFormat:@"%@/face-api/v3/face/identify?appid=%@",OBFace_url, OBFace_appid] params:parameters success:^(id  _Nonnull responseObject) {
        NSLog(@"2: %@",responseObject);
        
        NSInteger error_code = [[responseObject objectForKey:@"error_code"] integerValue];
        if (error_code == 0) {
            NSString *user_id = nil;
            CGFloat score = 0;
            
            NSDictionary *result = [responseObject objectForKey:@"result"];
            NSArray *user_list = [result objectForKey:@"user_list"];
            if (user_list.count > 0) {
                NSDictionary *userInfo = [user_list firstObject];
                user_id = [userInfo objectForKey:@"user_id"];
                score = [[userInfo objectForKey:@"score"] doubleValue];
            }
            
            if (self.clickedLogin == YES) {
                [self warningText:[NSString stringWithFormat:@"登录成功\n%@",user_id]];
            }else {
                [self warningText:[NSString stringWithFormat:@"用户已存在\n%@",user_id]];
            }
        }else if (error_code == 222207) {
            //未找到匹配的用户
            if (self.clickedLogin == YES) {
                [self warningText:@"用户未注册"];
            }else {
                //模拟客户在自己的服务器中生成userid后，再调用人脸库的接口注册人脸
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
                [df setDateFormat:@"yyyyMMddHHmmss"];
                NSString *userId = [NSString stringWithFormat:@"user%@",[df stringFromDate:[NSDate date]]];
                
                [self addFace:faceImage userId:userId];
            }
        }else {
            NSString *error_msg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"error_msg"]];
            [self warningText:error_msg];
        }
    } failure:^(NSError * _Nonnull error) {
        [self warningText:error.localizedDescription];
    }];
}

/**
 人脸注册
 
 参数             必选     类型     说明
 image            是     string     图片信息(总数据大小应小于10M)，图片上传方式根据image_type来判断。 注：组内每个uid下的人脸图片数目上限为20张
 image_type       是     string     图片类型 BASE64:图片的base64值，base64编码后的图片数据，编码后的图片大小不超过2M；
                                    FACE_TOKEN：人脸图片的唯一标识，调用人脸检测接口时，会为每个人脸图片赋予一个唯一的FACE_TOKEN，同一张图片多次检测得到的FACE_TOKEN是同一个。
 group_id         是     string     用户组id，标识一组用户（由数字、字母、下划线组成），长度限制48B。
                                    产品建议：根据您的业务需求，可以将需要注册的用户，按照业务划分，分配到不同的group下，例如按照会员手机尾号作为groupid，用于刷脸支付、会员计费消费等，这样可以尽可能控制每个group下的用户数与人脸数，提升检索的准确率 单个group建议80W人脸上限
 user_id          是     string     用户id（由数字、字母、下划线组成），长度限制48B
 user_info        否     string     用户资料，长度限制256B 默认空
 quality_control  否     string     图片质量控制 NONE: 不进行控制 LOW:较低的质量要求 NORMAL: 一般的质量要求 HIGH: 较高的质量要求 默认 NONE
                                    若图片质量不满足要求，则返回结果中会提示质量检测失败
 liveness_control 否     string     活体检测控制 NONE: 不进行控制 LOW:较低的活体要求(高通过率 低攻击拒绝率) NORMAL: 一般的活体要求(平衡的攻击拒绝率, 通过率)
                                    HIGH: 较高的活体要求(高攻击拒绝率 低通过率) 默认NONE 若活体检测结果不满足要求，则返回结果中会提示活体检测失败
 action_type      否     string     操作方式 APPEND: 当user_id在库中已经存在时，对此user_id重复注册时，新注册的图片默认会追加到该user_id下
                                    REPLACE : 当对此user_id重复注册时,则会用新图替换库中该user_id下所有图片 默认使用APPEND
 
 返回示例
 {
   "error_code": 0,
   "error_msg": "SUCCESS",
   "log_id": 1234567890123,
   "timestamp": 1533094602,
   "cached": 0,
   "result": {
       "face_token": "2fa64a88a9d5118916f9a303782a97d3",
       "location": {
           "left": 117,
           "top": 131,
           "width": 172,
           "height": 170,
           "rotation": 4
       }
   }
 }
 */
-(void)addFace:(UIImage*)faceImage userId:(NSString*)userId {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSData *data = [self convertImage:faceImage];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    [parameters setObject:base64String forKey:@"image"];
    [parameters setObject:@"BASE64" forKey:@"image_type"];
    [parameters setObject:OBFace_groupid forKey:@"group_id"];
    [parameters setObject:userId forKey:@"user_id"];
    [parameters setObject:@"Test User" forKey:@"user_info"];
    [parameters setObject:@"NONE" forKey:@"quality_control"];
    [parameters setObject:@"NONE" forKey:@"liveness_control"];
    [parameters setObject:@"APPEND" forKey:@"action_type"];
    
    OBFaceNetworking *req = [[OBFaceNetworking alloc] init];
    [req postWithURL:[NSString stringWithFormat:@"%@/face-api/v3/face/add?appid=%@",OBFace_url, OBFace_appid] params:parameters success:^(id  _Nonnull responseObject) {
        NSLog(@"3: %@",responseObject);
        
        NSInteger error_code = [[responseObject objectForKey:@"error_code"] integerValue];
        if (error_code == 0) {
            [self warningText:@"注册成功"];
        }else {
            NSString *error_msg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"error_msg"]];
            [self warningText:error_msg];
        }
    } failure:^(NSError * _Nonnull error) {
        [self warningText:error.localizedDescription];
    }];
}

- (NSData *)convertImage:(UIImage *)image {
    NSDictionary *options = @{(__bridge NSString *)kCGImageSourceShouldCache : @NO,
                              (__bridge NSString *)kCGImageSourceShouldCacheImmediately : @NO};
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destRef = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, kUTTypeJPEG, 1, (__bridge CFDictionaryRef)options);
    CGImageDestinationAddImage(destRef, image.CGImage, (__bridge CFDictionaryRef)options);
    CGImageDestinationFinalize(destRef);
    CFRelease(destRef);
    return data;
}

-(void)warningText:(NSString*)text {
    self.successLabel.text = text;
    CGSize size = [self.successLabel sizeThatFits:CGSizeMake([OBFaceCalculateTool screenWidth], MAXFLOAT)];
    self.successLabel.frame = CGRectMake(0, [OBFaceCalculateTool safeTopMargin] + 280, [OBFaceCalculateTool screenWidth], size.height);
}

@end
