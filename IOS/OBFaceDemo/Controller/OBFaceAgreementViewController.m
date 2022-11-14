//
//  OBFaceAgreementViewController.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

#import "OBFaceAgreementViewController.h"
#import "OBFaceCalculateTool.h"

@interface OBFaceAgreementViewController ()

@end

@implementation OBFaceAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titeLabel = [[UILabel alloc] init];
    titeLabel.frame = CGRectMake(0, [OBFaceCalculateTool safeTopMargin], [UIScreen mainScreen].bounds.size.width, 44);
    titeLabel.text = @"人脸采集协议";
    titeLabel.font = [UIFont boldSystemFontOfSize:20];
    titeLabel.textColor = [UIColor blackColor];
    titeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titeLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, [OBFaceCalculateTool safeTopMargin], 44, 44);
    [backButton setImage:[UIImage imageNamed:@"icon_titlebar_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, [OBFaceCalculateTool safeTopMargin] + 44, [UIScreen mainScreen].bounds.size.width, 0.5);
    lineView.backgroundColor = [UIColor colorWithRed:216 / 255.0 green:216 / 255.0 blue:216 / 255.0 alpha:1 / 1.0];
    [self.view addSubview:lineView];
    
    UIView *liveView = [[UIView alloc] init];
    liveView.frame = CGRectMake(20, CGRectGetMaxY(lineView.frame) + 15, [UIScreen mainScreen].bounds.size.width - 40, 400);
    
    CGFloat top = 0;
    for (int num = 0; num < 3; num++){
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, top, 3, 18);
        imageView.image = [UIImage imageNamed:@"image_agreement"];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 5, top, CGRectGetWidth(liveView.frame), 18);
        titleLabel.text = [self getTitle:num];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
       
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top + CGRectGetHeight(titleLabel.frame) + 15,  CGRectGetWidth(liveView.frame), 0)];
        descLabel.numberOfLines = 0;
        descLabel.font = [UIFont systemFontOfSize:14];
        descLabel.textColor = [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1 / 1.0];
        descLabel.text = [self getMessage:num];
        descLabel.textAlignment = NSTextAlignmentLeft;
        [descLabel sizeToFit];
        descLabel.frame = CGRectMake(0, top + CGRectGetHeight(titleLabel.frame)+ 15, CGRectGetWidth(liveView.frame), descLabel.frame.size.height);
        
        top += CGRectGetHeight(titleLabel.frame) + 15 + CGRectGetHeight(descLabel.frame) + 25;
        
        [liveView addSubview:imageView];
        [liveView addSubview:titleLabel];
        [liveView addSubview:descLabel];
    }
    [self.view addSubview:liveView];
}

- (void)backAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getTitle:(int)type{
    NSString* title;
    switch (type) {
        case 0:
            title = @"功能说明";
            break;
           case 1:
            title = @"授权与许可";
            break;
        case 2:
            title = @"信息安全声明";
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)getMessage:(int)type{
    NSString* title;
    switch (type) {
        case 0:
            title = @"为保障用户账户的安全，提供更好的服务，在提供部分产品及服务之前,采用人脸核身验证功能对用户的身份进行认证，用于验证操作人是否为账户持有者本人，通过人脸识别结果评估是否为用户提供后续产品或服务。该功能会请求权威数据源进行身份信息确认。";
            break;
           case 1:
            title = @"如您点击“确认”或以其他方式选择接受本协议规则，则视为您在使用人脸识别服务时，同意并授权、获取、使用您在申请过程中所提供的个人信息。";
            break;
        case 2:
            title = @"承诺对您的个人信息严格保密，并基于国家监管部门认可的加密算法进行数据加密传输，数据加密存储，承诺尽到信息安全保护义务。";
            break;
        default:
            break;
    }
    return title;
}

@end
