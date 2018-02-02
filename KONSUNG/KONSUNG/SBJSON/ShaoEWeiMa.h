//
//  ShaoEWeiMa.h
//  Central
//
//  Created by 刘少弘 on 14-11-17.
//  Copyright (c) 2014年 lshgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShaoWeiMaHeader.h"
#import <AVFoundation/AVFoundation.h>

@interface ShaoEWeiMa : UIViewController

@property (nonatomic, strong)id<ShaoWeiMaHeader> delegate;

@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;


@end
