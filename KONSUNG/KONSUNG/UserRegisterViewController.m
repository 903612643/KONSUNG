//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/26.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "UserRegisterViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"


@interface UserRegisterViewController ()<ASIHTTPRequestDelegate>
{
    UserObj *userObj;
    
    ASIFormDataRequest *asiRequest;
    
}

@property(nonatomic, strong) UITextField *accountTextField;
@property(nonatomic, strong) UITextField *userNameTextField;

@end

@implementation UserRegisterViewController

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
    // 用户名
    
    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(40,
                                                                           CGRectGetMaxY(self.accountTextField.frame) + 20,
                                                                           self.view.frame.size.width-80,
                                                                           40)];
    self.userNameTextField.font = [UIFont systemFontOfSize:14];
    self.userNameTextField.textColor = [UIColor blackColor];
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;  // 编辑时出现 X 号
    
    self.userNameTextField.placeholder = NSLocalizedString(@"enter_username", nil);
    [self.view addSubview:self.userNameTextField];
    
    //_________________________________________________________________________________________________
    // 注册
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    registerButton.frame = CGRectMake(40,
                                   CGRectGetMaxY(self.userNameTextField.frame) + 30,
                                   self.view.frame.size.width-80,
                                   36);
    registerButton.backgroundColor = [UIColor orangeColor];
    registerButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [registerButton setTitle:NSLocalizedString(@"register",nil) forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    registerButton.layer.cornerRadius = 5;
    registerButton.layer.masksToBounds = true;
    
    [registerButton addTarget:self action:@selector(registerNewAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 注册
- (void)registerNewAccount {
    NSString *strHone = self.accountTextField.text;          //手机号
    NSString *strpwd = self.userNameTextField.text;          //密码
    
    if (strHone.length < 4 || strHone.length > 20) {
        [self Alert:NSLocalizedString(@"enter_account_error",nil)];
        return;
    }
    if (strpwd.length < 6 || strpwd.length > 20) {
        [self Alert:@"Enter the correct password!"];
        return;
    }
    
    [self getHTTPRequest];
}


//成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
        
        NSString *requestString = [LshGo getReq:[request responseString]];
        NSDictionary *dict = [requestString JSONValue];
     
        NSString *strMasg = [dict objectForKey:@"errcode"];
        if ([strMasg isEqualToString:@"000"]) {
            
//            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            [self Alert:NSLocalizedString(@"register_success",nil)];
        }else{
            NSString *strErrMsg = [dict objectForKey:@"errmsg"];
            [self Alert:strErrMsg];
        }
        
        
    }@catch (NSException * e) {
        [self Alert:NSLocalizedString(@"network_is_error",nil)];
    }
    @finally {
        
    }
}

//失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self Alert:NSLocalizedString(@"register_failed",nil)];
}

-(void)getHTTPRequest{
    NSString *strHone = self.accountTextField.text;          //手机号
    NSString *strpwd = self.userNameTextField.text;             //密码
    NSDate *datenow = [NSDate date];
    
    NSString *pwd = [LshGo md5:strpwd];
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1001\",\"errcode\":\"000\",\"timestamp\":%ld,\"username\":\"%@\",\"loginpwd\":\"%@\"}abx23579436",[LshGo getTimestamp:datenow], strHone, pwd];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1001\",\"errcode\":\"000\",\"timestamp\":%ld,\"username\":\"%@\",\"loginpwd\":\"%@\"}", strpackmd5, [LshGo getTimestamp:datenow], strHone, pwd];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 1;
    
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
        [self.userNameTextField resignFirstResponder];
    }
}
//#pragma mark UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//{
////    if (<#condition#>) {
////        
////    }
//}

@end
