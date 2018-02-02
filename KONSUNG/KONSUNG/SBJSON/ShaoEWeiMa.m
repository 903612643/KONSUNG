//
//  ShaoEWeiMa.m
//  Central
//
//  Created by 刘少弘 on 14-11-17.
//  Copyright (c) 2014年 lshgo. All rights reserved.
//

#define WIDTH240 240
#import "ShaoEWeiMa.h"

@interface ShaoEWeiMa ()
{
    UIView *viewV;
    UILabel *labeA;
    
    UIImageView *imgViewC;
    NSTimer *_timer;
    
    NSInteger count;
}
@end

@implementation ShaoEWeiMa



-(void)butReturn:(id *)but{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupCamera
{
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
   
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
   
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
 
    self.output.metadataObjectTypes =[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode, nil];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    self.preview.frame =CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [viewV.layer addSublayer:self.preview];
    
    UILabel *labe = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, 120,300, 30)];
    labe.text = @"正在实别二维码或条形码...";
    labe.textColor = [UIColor whiteColor];
    labe.textAlignment = NSTextAlignmentCenter;
    labe.font = [UIFont systemFontOfSize:16];
    [viewV addSubview:labe];
    
    UIImageView *imgViewK = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-WIDTH240)/2, 160, WIDTH240, WIDTH240)];
    [imgViewK setImage:[UIImage imageNamed:@"capture.9.png"]];
    [viewV addSubview:imgViewK];
    
    imgViewC = [[UIImageView alloc] initWithFrame:CGRectMake((imgViewK.frame.size.width-200)/2, 0, 200, 4)];
    [imgViewC setImage:[UIImage imageNamed:@"scan_line.png"]];
    [imgViewK addSubview:imgViewC];
    
    
    UIImageView *imgTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, imgViewK.frame.origin.y)];
    [imgTop setImage:[UIImage imageNamed:@"scan_mask.png"]];
    [viewV addSubview:imgTop];
    
    UIImageView *imgLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, imgTop.frame.size.height,imgViewK.frame.origin.x, imgViewK.frame.size.height)];
    [imgLeft setImage:[UIImage imageNamed:@"scan_mask.png"]];
    [viewV addSubview:imgLeft];
    
    UIImageView *imgRight = [[UIImageView alloc] initWithFrame:CGRectMake(imgLeft.frame.size.width+imgViewK.frame.size.width, imgTop.frame.size.height,imgViewK.frame.origin.x, imgViewK.frame.size.height)];
    [imgRight setImage:[UIImage imageNamed:@"scan_mask.png"]];
    [viewV addSubview:imgRight];
    
    UIImageView *imgButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, imgLeft.frame.size.height+imgLeft.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height)];
    [imgButton setImage:[UIImage imageNamed:@"scan_mask.png"]];
    [viewV addSubview:imgButton];
    
    
    
    // Start
    [self.session startRunning];
    [_timer setFireDate:[NSDate date]];
    
    
    CGFloat v = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-60;
    
    UIView *logoTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, v, 20)];
    logoTopView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:logoTopView];
    
    
    UIView *logoViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 20, v, 40)];
    logoViewTop.backgroundColor = [UIColor blackColor];
    logoViewTop.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_top.png"]];
    [self.view addSubview:logoViewTop];
    
//    UIButton *butReturn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
//    [butReturn setImage:[UIImage imageNamed:@"right_return.png"] forState:UIControlStateNormal];
//    [butReturn addTarget:self action:@selector(butReturn:) forControlEvents:UIControlEventTouchUpInside];
//    [logoViewTop addSubview:butReturn];
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(butReturn:)];
    [self.view addGestureRecognizer:tapView];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(v/2-120, 10, 240, 20)];
    labelTitle.text = @"扫描二维码或条形码";
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont boldSystemFontOfSize:20];
    [logoViewTop addSubview:labelTitle];
    
    //主界面
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, v, h)];
    [self.view addSubview:logoView];
    
}



#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [self.session stopRunning];
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
    //                                                      message:stringValue
    //                                                     delegate:nil
    //                                            cancelButtonTitle:@"OK"
    //                                            otherButtonTitles:nil,nil];
    //    [alert show];
    
    [_timer setFireDate:[NSDate distantFuture]];
    [viewV removeFromSuperview];
    labeA.text = stringValue;
    
    [_delegate returnDeviecID:stringValue];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)transformView{
    CGRect imgFra = imgViewC.frame;
    count += 7;
    imgViewC.frame = CGRectMake(imgFra.origin.x, count, imgFra.size.width, imgFra.size.height);
    if (count > 233) {
        count = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    viewV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:viewV];
    
    [self setupCamera];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(transformView) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
