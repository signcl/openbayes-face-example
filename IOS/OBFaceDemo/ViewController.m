//
//  ViewController.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

#import "ViewController.h"
#import "OBFaceCalculateTool.h"
#import "OBFaceToastView.h"
#import "OBFaceAgreementViewController.h"
#import "OBFaceLivenessViewController.h"
#import "OBFaceSuccessViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *checkAgreeBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat safeTopMargin = [OBFaceCalculateTool safeTopMargin];
    CGFloat screenWidth = [OBFaceCalculateTool screenWidth];
    CGFloat screenHeight = [OBFaceCalculateTool screenHeight];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 480.0/1080.0 * CGRectGetWidth(self.view.frame))];
    bgView.image = [UIImage imageNamed:@"image_guide"];
    [self.view addSubview:bgView];
    
    // 欢迎使用的label
    UILabel *welcome = [[UILabel alloc] init];
    welcome.frame = CGRectMake(50, safeTopMargin + 44 + 5, screenWidth - 50, 0);
    welcome.text = @"欢迎使用";
    welcome.font =  [UIFont boldSystemFontOfSize:20];
    welcome.textColor = [UIColor blackColor];
    [welcome sizeToFit];
    [self.view addSubview:welcome];
    
    // 欢迎使用的下一行
    UILabel *welcomeNext = [[UILabel alloc] init];
    welcomeNext.frame = CGRectMake(50, CGRectGetMaxY(welcome.frame) + 5, screenWidth - 50, 0);
    welcomeNext.text = @"人脸采集SDK";
    welcomeNext.font = [UIFont boldSystemFontOfSize:25];
    welcomeNext.textColor = [UIColor blackColor];
    [welcomeNext sizeToFit];
    [self.view addSubview:welcomeNext];
    
    CGRect middleContentFrame = CGRectMake(50, CGRectGetMaxY(welcomeNext.frame) + 10, screenWidth - 100, 0);
    UIView *middleContentView = [[UIView alloc] initWithFrame:middleContentFrame];
    {
        // 光线的提示和图片
        UIImageView *lightImage = [[UIImageView alloc] init];
        lightImage.frame =  CGRectMake(0, 0, 60, 60);
        lightImage.image = [UIImage imageNamed:@"icon_guide1"];
        [middleContentView addSubview:lightImage];
        
        UILabel *adjustLight = [[UILabel alloc] init];
        adjustLight.frame =  CGRectMake(75, 12.5, screenWidth, 18);
        adjustLight.text = @"识别光线适中";
        adjustLight.font = [UIFont boldSystemFontOfSize:18];
        adjustLight.textColor = [UIColor blackColor];
        
        [middleContentView addSubview:adjustLight];
        UILabel *adjustLight2 = [[UILabel alloc] init];
        adjustLight2.frame =  CGRectMake(75, CGRectGetMaxY(adjustLight.frame) + 5, screenWidth, 12);
        adjustLight2.text = @"请保证光线不要过暗或过亮";
        adjustLight2.font = [UIFont systemFontOfSize:12];
        adjustLight2.textColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1 / 1.0];
        [middleContentView addSubview:adjustLight2];
        
        // 正对手机的图片和提示
        UIImageView *angleImage = [[UIImageView alloc] init];
        angleImage.frame = CGRectMake(0, CGRectGetMaxY(lightImage.frame) + 20, 60, 60);
        angleImage.image = [UIImage imageNamed:@"icon_guide2"];
        [middleContentView addSubview:angleImage];
        
        UILabel *focesText = [[UILabel alloc] init];
        focesText.frame = CGRectMake(75, CGRectGetMinY(angleImage.frame) + 12.5, screenWidth, 18);
        focesText.text = @"请正对手机";
        focesText.font = [UIFont boldSystemFontOfSize:18];
        focesText.textColor = [UIColor blackColor];
        [middleContentView addSubview:focesText];
        
        UILabel *focesTextNext = [[UILabel alloc] init];
        focesTextNext.frame = CGRectMake(75, CGRectGetMaxY(focesText.frame) + 5, screenWidth, 12);
        focesTextNext.text = @"保持您的脸出现在取景框内";
        focesTextNext.font = [UIFont systemFontOfSize:12];
        focesTextNext.textColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1 / 1.0];
        [middleContentView addSubview:focesTextNext];
        
        // 避免遮挡的图片和提示
        UIImageView *maskImage = [[UIImageView alloc] init];
        maskImage.frame = CGRectMake(0, CGRectGetMaxY(angleImage.frame) + 20, 60, 60);
        maskImage.image = [UIImage imageNamed:@"icon_guide3"];
        [middleContentView addSubview:maskImage];
        
        UILabel *maskText = [[UILabel alloc] init];
        maskText.frame = CGRectMake(75, CGRectGetMinY(maskImage.frame) + 12.5, screenWidth, 18);
        maskText.text = @"避免遮挡";
        maskText.font = [UIFont boldSystemFontOfSize:18];
        maskText.textColor = [UIColor blackColor];
        [middleContentView addSubview:maskText];
        
        UILabel *maskTextNext = [[UILabel alloc] init];
        maskTextNext.frame = CGRectMake(75, CGRectGetMaxY(maskText.frame) + 5, screenWidth, 12);
        maskTextNext.text = @"请保持您的脸部清晰无遮挡";
        maskTextNext.font = [UIFont systemFontOfSize:12];
        maskTextNext.textColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1 / 1.0];
        [middleContentView addSubview:maskTextNext];
        
        middleContentFrame.size.height = CGRectGetMaxY(maskImage.frame);
        middleContentView.frame = middleContentFrame;
    }
    [self.view addSubview:middleContentView];
    
    CGFloat toBottom = 30.0f;
    CGFloat remdinderHeight = 30.0f;
    UIView *remindView = [[UIView alloc] init];
    [self.view addSubview:remindView];
    
    // 勾选人脸验证协议的button
    UIButton *checkAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkAgreeBtn.frame = CGRectMake(0, 0, remdinderHeight, remdinderHeight);
    [checkAgreeBtn setImage:[UIImage imageNamed:@"icon_guide"] forState:UIControlStateNormal];
    [checkAgreeBtn addTarget:self action:@selector(checkAgreeClick:) forControlEvents:UIControlEventTouchUpInside];
    [remindView addSubview:checkAgreeBtn];
    self.checkAgreeBtn = checkAgreeBtn;
    
    UILabel *agreeLabel = [[UILabel alloc] init];
    agreeLabel.text = @"同意";
    agreeLabel.font = [UIFont systemFontOfSize:15];
    agreeLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
    [agreeLabel sizeToFit];
    agreeLabel.frame = CGRectMake(CGRectGetMaxX(checkAgreeBtn.frame), 0, CGRectGetWidth(agreeLabel.frame), remdinderHeight);
    [remindView addSubview:agreeLabel];
    
    // 人脸验证协议的label，提供了点击响应事件
    UILabel *remindLabel = [[UILabel alloc] init];
    remindLabel.text = @"《人脸验证协议》";
    remindLabel.font = [UIFont systemFontOfSize:15];
    remindLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];
    remindLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementAction:)];
    [remindLabel addGestureRecognizer:tap];
    [remindLabel sizeToFit];
    remindLabel.frame = CGRectMake(CGRectGetMaxX(agreeLabel.frame), 0, CGRectGetWidth(remindLabel.frame), remdinderHeight);
    [remindView addSubview:remindLabel];
    
    remindView.frame = CGRectMake((screenWidth - CGRectGetMaxX(remindLabel.frame))/2.0, screenHeight - [OBFaceCalculateTool safeBottomMargin] - toBottom - remdinderHeight, CGRectGetMaxX(remindLabel.frame), remdinderHeight);
    
    CGFloat btnHeight = 52;
    // 开始采集的Button
    UIButton *loginBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake((screenWidth - 266.7)/2.0, CGRectGetMinY(remindView.frame) - btnHeight - 10, 266.7, btnHeight);
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_main_normal"] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_main_p"] forState:UIControlStateSelected];
    [loginBtn setTitle:@"人脸登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1 / 1.0] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    loginBtn.tag = 0;
    [loginBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *registerBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake((screenWidth - 266.7)/2.0, CGRectGetMinY(loginBtn.frame) - btnHeight - 5, 266.7, btnHeight);
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_main_normal"] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_main_p"] forState:UIControlStateSelected];
    [registerBtn setTitle:@"人脸注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1 / 1.0] forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    registerBtn.tag = 1;
    [registerBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    // 调整中间部分View居中
    CGFloat middleMaxHeight = (CGRectGetMinY(registerBtn.frame) - CGRectGetMaxY(welcomeNext.frame));
    CGFloat middleViewOriginY = CGRectGetMaxY(welcomeNext.frame) + (middleMaxHeight - CGRectGetHeight(middleContentView.frame)) / 2.0f;
    middleContentFrame.origin.y = middleViewOriginY;
    middleContentFrame.origin.x = (screenWidth - CGRectGetWidth(middleContentFrame))/2.0;
    middleContentView.frame = middleContentFrame;
}

#pragma mark - Button Action

- (void)checkAgreeClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    // 如果再次点击选中button，提示窗口消失
    if (sender.selected == YES) {
        [sender setImage:[UIImage imageNamed:@"icon_guide_s"] forState:UIControlStateSelected];
    } else {
        [sender setImage:[UIImage imageNamed:@"icon_guide"] forState:UIControlStateNormal];
    }
}

- (void)startAction:(UIButton *)sender {
    // 检测是否同意，如果同意"开始人脸采集"可点击
    if (self.checkAgreeBtn.isSelected == NO){
        [OBFaceToastView showToast:self.view text:@"请先同意《人脸验证协议》"];
        return;
    }
    
    OBFaceLivenessViewController* lvc = [[OBFaceLivenessViewController alloc] init];
    [lvc handleCompletedBlock:^(UIImage * _Nonnull faceImage) {
        OBFaceSuccessViewController *vc = [[OBFaceSuccessViewController alloc] init];
        vc.successImage = faceImage;
        vc.clickedLogin = (sender.tag == 0);
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        navi.navigationBarHidden = YES;
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navi animated:YES completion:nil];
    }];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
    navi.navigationBarHidden = YES;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)agreementAction:(UILabel *)sender{
    OBFaceAgreementViewController *avc = [[OBFaceAgreementViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:avc];
    navi.navigationBarHidden = YES;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
}

@end
