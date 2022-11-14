//
//  OBFaceLivenessViewController.m
//  OBFaceDemo
//
//  Created by SUN on 2022/11/6.
//

#import "OBFaceLivenessViewController.h"
#import "OBFaceCalculateTool.h"
#import "OBFaceToastView.h"
#import "OBFaceCameraView.h"

@interface OBFaceLivenessViewController ()

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) OBFaceCameraView *cameraView;

@property (nonatomic, copy) OBFaceLivenessCompletedBlock completedBlock;

@end

@implementation OBFaceLivenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat cameraWidth = [OBFaceCalculateTool screenWidth];
    CGFloat cameraHeight = cameraWidth * 640.0/480.0;
    OBFaceCameraView *cameraView = [[OBFaceCameraView alloc] init];
    cameraView.frame = CGRectMake(([OBFaceCalculateTool screenWidth] - cameraWidth)/2.0, ([OBFaceCalculateTool screenHeight] - cameraHeight)/2.0, cameraWidth, cameraHeight);
    __weak typeof(self) weakSelf = self;
    [cameraView handleCompletedBlock:^(UIImage * _Nonnull faceImage) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            if (weakSelf.completedBlock) {
                weakSelf.completedBlock(faceImage);
            }
        }];
    }];
    [cameraView handleLivenessRemindBlock:^(LivenessRemindCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (code) {
                case LivenessRemindCodeNoFaceDetected:
                    weakSelf.promptLabel.text = @"请在框内保持正脸";
                    break;
                case LivenessRemindCodeTooFar:
                    weakSelf.promptLabel.text = @"请将脸部靠近一点";
                    break;
                case LivenessRemindCodeLiveEye:
                    weakSelf.promptLabel.text = @"眨眨眼";
                    break;
                case LivenessRemindCodeLiveMouth:
                    weakSelf.promptLabel.text = @"张张嘴";
                    break;
                case LivenessRemindCodeTimeout:
                {
                    weakSelf.promptLabel.text = @"";
                    [weakSelf.cameraView stopRunning];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"人脸采集超时" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新采集" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [weakSelf.cameraView startRunning];
                    }];
                    [alertController addAction:action];
                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                default:
                    break;
            }
        });
    }];
    [self.view addSubview:cameraView];
    self.cameraView = cameraView;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds)/2.0) radius:[OBFaceCalculateTool screenWidth] * 0.7/2.0 startAngle:0 endAngle:M_PI *2 clockwise:YES];
    path.usesEvenOddFillRule = YES;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor whiteColor].CGColor;
    shapeLayer.fillRule=kCAFillRuleEvenOdd;
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
    maskView.backgroundColor = [UIColor whiteColor];
    maskView.alpha = 1;
    maskView.layer.mask = shapeLayer;
    [self.view addSubview:maskView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, [OBFaceCalculateTool safeTopMargin], 44, 44);
    [backButton setImage:[UIImage imageNamed:@"icon_titlebar_close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.font = [UIFont boldSystemFontOfSize:18];
    promptLabel.textColor = [UIColor blackColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.frame = CGRectMake(0, ([OBFaceCalculateTool screenHeight] - CGRectGetWidth(cameraView.bounds))/2.0 - 40, [OBFaceCalculateTool screenWidth], 30);
    [self.view addSubview:promptLabel];
    self.promptLabel = promptLabel;
    
    [self.cameraView preparCamera];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.cameraView stopRunning];
}

- (void)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleCompletedBlock:(OBFaceLivenessCompletedBlock)block {
    self.completedBlock = block;
}

@end
