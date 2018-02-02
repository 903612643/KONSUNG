//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/26.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "ForgetPasswordViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"

@interface ForgetPasswordViewController ()<ASIHTTPRequestDelegate>

{
    UserObj *userObj;
    
    ASIFormDataRequest *asiRequest;
}

@property(nonatomic, strong) UITextField *accountTextField;

@end

@implementation ForgetPasswordViewController

- (id)initWithTitle:(NSString *)title color:(UIColor *)color {
    self = [super init];
    
    if (self) {
        UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        navTitleLabel.font = [UIFont systemFontOfSize:18];
        navTitleLabel.textColor = color;
        navTitleLabel.textAlignment = NSTextAlignmentCenter;
        navTitleLabel.adjustsFontSizeToFitWidth = true;
        
        navTitleLabel.text = title;
        self.navigationItem.titleView = navTitleLabel;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userObj = [UserObj getUserObj];
    
    // Do any additional setup after loading the view.
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    background.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:background];
    
    //_________________________________________________________________________________________________
    // 帐号
    
    self.accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(40,
                                                                          50,
                                                                          self.view.frame.size.width-80,
                                                                          40)];
    self.accountTextField.font = [UIFont systemFontOfSize:14];
    self.accountTextField.textColor = [UIColor blackColor];
    self.accountTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;  // 编辑时出现 X 号
    
    self.accountTextField.placeholder = NSLocalizedString(@"enter_account", nil);  // 当输入框没有内容时，水印提示
    [self.view addSubview:self.accountTextField];
    
    //_________________________________________________________________________________________________
    // 找回密码
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    registerButton.frame = CGRectMake(40,
                                      CGRectGetMaxY(self.accountTextField.frame) + 50,
                                      self.view.frame.size.width-80,
                                      36);
    registerButton.backgroundColor = [UIColor orangeColor];
    registerButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [registerButton setTitle:NSLocalizedString(@"modify_password",nil) forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    registerButton.layer.cornerRadius = 5;
    registerButton.layer.masksToBounds = true;
    
    [registerButton addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)forgetPassword {
    NSString *strMobileno = self.accountTextField.text;
    if (strMobileno.length < 4 || strMobileno.length > 40) {
        [self Alert:NSLocalizedString(@"enter_account_error",nil)];
        return;
    }
    
    [self getHTTPRequest2];
}


//成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
        
        NSString *requestString = [LshGo getReq:[request responseString]];
        NSDictionary *dict = [requestString JSONValue];
        
        if (request.tag == 3) {
            NSString *strMasg = [dict objectForKey:@"errcode"];
            if ([strMasg isEqualToString:@"000"]) {
                NSString *strErrMsg = [dict objectForKey:@"errmsg"];
                [self Alert: strErrMsg];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSString *strErrMsg = [dict objectForKey:@"errmsg"];
                [self Alert: strErrMsg];
            }

        }
    
    }@catch (NSException * e) {
        [self Alert:NSLocalizedString(@"network_is_error",nil)];
    }
    @finally {
        
    }
}

-(void)getHTTPRequest2{
    
    NSString *strMobileno = self.accountTextField.text;
    
    NSDate *datenow = [NSDate date];
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1011\",\"errcode\":\"000\",\"timestamp\":%ld,\"loginname\":\"%@\"}abx23579436",[LshGo getTimestamp:datenow], strMobileno];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1011\",\"errcode\":\"000\",\"timestamp\":%ld,\"loginname\":\"%@\"}", strpackmd5, [LshGo getTimestamp:datenow], strMobileno];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 3;
    [asiRequest startAsynchronous];
    
    
}

-(void)Alert:(NSString *)strMag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system_hint",nil)
                                                    message:strMag
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"confirm",nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Touch To ResignFirstResponder
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 点击屏幕任意空白位置隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.tapCount >= 1) {
        [self.accountTextField resignFirstResponder];
    }
}

@end
