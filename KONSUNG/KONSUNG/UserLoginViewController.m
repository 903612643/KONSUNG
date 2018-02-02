//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/25.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserRegisterViewController.h"
#import "ForgetPasswordViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"
#import "AppDelegate.h"

#import "ViewController.h"
@interface UserLoginViewController ()<ASIHTTPRequestDelegate,UITextFieldDelegate>
{
    UserObj *userObj;
    
    ASIFormDataRequest *asiRequest;
    
    NSUserDefaults * tmp;
    
    UIView *viewSele;
    BOOL isOKSele;
    UIImageView *background;
}

@property(nonatomic, strong) UITextField *accountTextField;
@property(nonatomic, strong) UITextField *passwordTextField;

@end

@implementation UserLoginViewController

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

//每次进入
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = false;
    
    NSArray  *arrrtn = (NSArray *)[tmp objectForKey:@"loginUsrtName"];
    
      NSLog(@"arrrtn=%@",arrrtn);
    
    if ([arrrtn count] > 0) {
        self.accountTextField.text = arrrtn[0];//@"tt@qq.com";
        self.passwordTextField.text = arrrtn[1];//@"123123";
        isOKSele = NO;
        [self selectjizhu];
    }else{
        self.accountTextField.text = @"";//@"tt@qq.com";
        self.passwordTextField.text = @"";//arrrtn[1];//@"123123";
        isOKSele = YES;
        [self selectjizhu];
    }
    
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //关闭定时器
    NSLog(@"每次离开时关闭");
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [asiRequest clearDelegatesAndCancel];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isOKSele = YES;
    
    background = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height)];
    background.image = [UIImage imageNamed:@"5.png"];
    background.userInteractionEnabled = YES;
    [self.view addSubview:background];
    
    self.navigationItem.hidesBackButton = true;

    
    
    
    tmp = [NSUserDefaults standardUserDefaults];
    userObj = [UserObj getUserObj];
    
 
    //_________________________________________________________________________________________________
    // 注册
    
    //_________________________________________________________________________________________________
    // 帐号background.frame.size.height-230,
    
    CGFloat intHeight = background.frame.size.height-225;
    if (background.frame.size.height == 480) {
        intHeight = background.frame.size.height-190;
    }
    UIImageView *viewImage = [[UIImageView alloc] initWithFrame:CGRectMake(40,
                                                                          intHeight,
                                                                          self.view.frame.size.width-80,
                                                                          40)];
    viewImage.image = [UIImage imageNamed:@"8.png"];
    viewImage.userInteractionEnabled = YES;
    [background addSubview:viewImage];
    
    
    self.accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(40,
                                                                            0,
                                                                           viewImage.frame.size.width-40,
                                                                           40)];
    self.accountTextField.font = [UIFont systemFontOfSize:14];
//    self.accountTextField.textColor = [UIColor blackColor];
//    self.accountTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;  // 编辑时出现 X 号
    
    self.accountTextField.placeholder = NSLocalizedString(@"enter_account", nil);  // 当输入框没有内容时，水印提示
    
//    NSArray  *arrrtn = (NSArray *)[tmp objectForKey:@"loginUsrtName"];
    self.accountTextField.text = @"";//arrrtn[0];//@"tt@qq.com";
    self.accountTextField.delegate = self;
    [self.accountTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [viewImage addSubview:self.accountTextField];
    
    
    
    //验证马。
    
    
    //_________________________________________________________________________________________________
    // 密码
    
    UIImageView *viewImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(40,
                                                                           CGRectGetMaxY(viewImage.frame) + 10,
                                                                           self.view.frame.size.width-80,
                                                                            40)];
    viewImage1.image = [UIImage imageNamed:@"8.png"];
    viewImage1.userInteractionEnabled = YES;
    [background addSubview:viewImage1];
    
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(40,
                                                                           0,
                                                                           viewImage1.frame.size.width-40,
                                                                           40)];
    self.passwordTextField.font = [UIFont systemFontOfSize:14];
//    self.passwordTextField.textColor = [UIColor blackColor];
//    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.secureTextEntry = YES; //密码
    self.passwordTextField.clearsOnBeginEditing = true;  // 再次编辑就清空
    
    self.passwordTextField.placeholder = NSLocalizedString(@"enter_password", nil);
    self.passwordTextField.text = @"";//arrrtn[1];//@"123123";
    self.passwordTextField.delegate = self;
    [viewImage1 addSubview:self.passwordTextField];
    
    //_________________________________________________________________________________________________
    // 登录
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    loginButton.frame = CGRectMake(40,
                                   CGRectGetMaxY(viewImage1.frame) + 10,
                                   110,
                                   33);
//    loginButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"butsubmit.png"]];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"butsubmit.png"] forState:UIControlStateNormal];
    loginButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [loginButton setTitle:NSLocalizedString(@"login",nil) forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
//    loginButton.layer.cornerRadius = 5;
//    loginButton.layer.masksToBounds = true;
    
    [loginButton addTarget:self action:@selector(userLoginSystem) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:loginButton];
    
    
    UIButton *rightButtonLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    rightButtonLogin.frame = CGRectMake(self.view.frame.size.width-150, CGRectGetMaxY(viewImage1.frame) + 10, 110, 33);
//    loginButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"butsubmit.png"]];
    [rightButtonLogin setBackgroundImage:[UIImage imageNamed:@"butsubmit.png"] forState:UIControlStateNormal];
    [rightButtonLogin setTitle:NSLocalizedString(@"register",nil) forState:UIControlStateNormal];
    [rightButtonLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButtonLogin addTarget:self action:@selector(registerNewAccount) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:rightButtonLogin];
    
    //_________________________________________________________________________________________________
    // 找回密码
    
    UIButton *findPWbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    findPWbutton.frame = CGRectMake(self.view.frame.size.width-140,
                                   CGRectGetMaxY(loginButton.frame) + 10,
                                   120,
                                   30);
    findPWbutton.titleLabel.adjustsFontSizeToFitWidth = true;
    [findPWbutton setTitle:@"Forgot Password" forState:UIControlStateNormal];
    [findPWbutton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [findPWbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [findPWbutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    findPWbutton.layer.cornerRadius = 5;
    findPWbutton.layer.masksToBounds = true;
    findPWbutton.layer.borderWidth = 0.5f;
    findPWbutton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [findPWbutton addTarget:self action:@selector(findMyPassword) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:findPWbutton];
    
    viewSele = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(loginButton.frame) + 13, 26, 26)];
    viewSele.backgroundColor = [UIColor orangeColor];
    viewSele.layer.cornerRadius = 13.0f;
    viewSele.layer.masksToBounds = true;
    [background addSubview:viewSele];
    
    UITapGestureRecognizer *tapVsele = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectjizhu)];
    [viewSele addGestureRecognizer:tapVsele];
    
    UIView *viewSele1 = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 16, 16)];
    viewSele1.backgroundColor = [UIColor whiteColor];
    viewSele1.layer.cornerRadius = 8.0f;
    viewSele1.layer.masksToBounds = true;
    [viewSele addSubview:viewSele1];
    
    
    UILabel *labJiMi = [[UILabel alloc] initWithFrame:CGRectMake(73, viewSele.frame.origin.y-2-64, 160, 30)];
    labJiMi.text = @"Remember password";
    labJiMi.font = [UIFont systemFontOfSize:12];
    labJiMi.userInteractionEnabled = YES;
    [self.view addSubview:labJiMi];
    
    
    //版本号
    UILabel *labVer = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 20, viewSele.frame.origin.y-10, 100, 30)];
    labVer.text = @"V1.0.1";
    labVer.font = [UIFont systemFontOfSize:10];
    labVer.userInteractionEnabled = YES;
    labVer.textColor = [UIColor whiteColor];
    [self.view addSubview:labVer];
    
    
    UITapGestureRecognizer *tapVsele1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectjizhu)];
    [labJiMi addGestureRecognizer:tapVsele1];
}

-(void)selectjizhu{
    if (isOKSele) {
        viewSele.backgroundColor = [UIColor whiteColor];
    }else{
        viewSele.backgroundColor = [UIColor orangeColor];
    }
    
    isOKSele = !isOKSele;
}

/// 用户登录
- (void)userLoginSystem {
    
    NSString *strName = self.accountTextField.text;
    NSString *strPWD = self.passwordTextField.text;
    
    if([strName length] < 4){
        [self Alert:NSLocalizedString(@"enter_account_error",nil)];
        return;
    }
    
    if ([strPWD length] < 6 || [strPWD length] > 40) {
        [self Alert:@"the password is wrong, plesse enter again."];
        return;
    }
    
    [self getHTTPRequest:strName :strPWD];
    
    
//    [self.navigationController popToRootViewControllerAnimated:false];
}

/// 找回密码
- (void)findMyPassword {
    ForgetPasswordViewController *viewCtrl = [[ForgetPasswordViewController alloc] initWithTitle:NSLocalizedString(@"Forget_Password",nil) color:UIColor.whiteColor];
    [self.navigationController pushViewController:viewCtrl animated:true];
}

/// 注册
- (void)registerNewAccount {
    UserRegisterViewController *viewCtrl = [[UserRegisterViewController alloc] initWithTitle:NSLocalizedString(@"User_Register",nil) color:UIColor.whiteColor];
    [self.navigationController pushViewController:viewCtrl animated:true];
}

- (void) textFieldDidChange:(UITextField *) TextField{
    NSLog(@"在输入 = %@",TextField.text);
    NSString *strUserNameL = TextField.text;
    NSMutableArray *arrList = [tmp objectForKey:@"LoginUsrtNameList"];
    BOOL isIFok = YES;
    for (NSInteger i = 0; i < [arrList count]; i++) {
        NSArray *dictL = arrList[i];
        if ([dictL[0] isEqualToString:strUserNameL]) {
//            NSString *strName = self.accountTextField.text;
            self.passwordTextField.text = dictL[1];
            isIFok = NO;
            break;
        }
    }
    if (isIFok) {
        self.passwordTextField.text = @"";
    }
}
//liuy@i7778.com /123123

//18497314@qq.com  / 123123

//成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
        
        NSString *requestString = [LshGo getReq:[request responseString]];
        
        NSDictionary *dict = [requestString JSONValue];
        
        NSLog(@"dict=%@",dict);
        
        NSString *strMasg = [dict objectForKey:@"errcode"];
        NSString *strErrMsg = [dict objectForKey:@"errmsg"];
        if ([strMasg isEqualToString:@"000"]) {
            
            NSString *strUserNa = self.accountTextField.text;
            NSString *strPWD = self.passwordTextField.text;
            
            if (isOKSele) {
                NSArray *arrU = [[NSArray alloc] initWithObjects:strUserNa,strPWD, nil];
                [tmp setObject:arrU forKey:@"loginUsrtName"];
                [tmp synchronize];
                
                
                //记录登陆过的账号。
                NSMutableArray *arrList = [tmp objectForKey:@"LoginUsrtNameList"];
                NSMutableArray *arrMutableList = [[NSMutableArray alloc] init];
                BOOL isIFok = YES;
                for (NSInteger i = 0; i < [arrList count]; i++) {
                    NSArray *dictL = arrList[i];
                    if ([dictL[0] isEqualToString:strUserNa]) {
                        
                        NSArray *arrU = [[NSArray alloc] initWithObjects:strUserNa,strPWD, nil];
                        [arrMutableList addObject:arrU];
                        isIFok = NO;
                        break;
                    }else{
                        [arrMutableList addObject:dictL];
                    }
                }
                if (isIFok) {
                    NSArray *arrU = [[NSArray alloc] initWithObjects:strUserNa,strPWD, nil];
                    [arrMutableList addObject:arrU];
                }
                [tmp setObject:arrMutableList forKey:@"LoginUsrtNameList"];
                [tmp synchronize];
                
            }else{
                [tmp setObject:nil forKey:@"loginUsrtName"];
                [tmp synchronize];
                
                //记录登陆过的账号。
                NSMutableArray *arrList = [tmp objectForKey:@"LoginUsrtNameList"];
                NSMutableArray *arrMutableList = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < [arrList count]; i++) {
                    NSArray *dictL = arrList[i];
                    if (![dictL[0] isEqualToString:strUserNa]) {
                        [arrMutableList addObject:dictL];
                    }
                }
                
                [tmp setObject:arrMutableList forKey:@"LoginUsrtNameList"];
                [tmp synchronize];
            }
            
            userObj.user = dict;
            userObj.strUserName = strUserNa;
            
            // 保存用户名
            [[NSUserDefaults standardUserDefaults] setObject:userObj.strUserName forKey:@"userAccount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 重新打开数据库
            [(AppDelegate *)[UIApplication sharedApplication].delegate openUserDatabase];
            [self.navigationController popToRootViewControllerAnimated:false];
            
        }else{
            [self Alert:strErrMsg];
        }
        
    }@catch (NSException * e) {
        [self Alert:NSLocalizedString(@"network_is_error",nil)];
    }
    @finally {
        
    }
}

//失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self Alert:NSLocalizedString(@"login_failed",nil)];
}

//
-(void)getHTTPRequest:(NSString *)strName :(NSString *)strPWD{
    
    NSDate *datenow = [NSDate date];
    
    NSString *pwd = [LshGo md5:strPWD];
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1003\",\"errcode\":\"000\",\"timestamp\":%ld,\"loginname\":\"%@\",\"loginpwd\":\"%@\"}abx23579436",[LshGo getTimestamp:datenow], strName, pwd];
    NSString *pwd1 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1003\",\"errcode\":\"000\",\"timestamp\":%ld,\"loginname\":\"%@\",\"loginpwd\":\"%@\"}",pwd1, [LshGo getTimestamp:datenow], strName, pwd];
    
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
        background.frame = CGRectMake(background.frame.origin.x, -64, background.frame.size.width, background.frame.size.height);
        [self.accountTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    background.frame = CGRectMake(background.frame.origin.x, -120-64, background.frame.size.width, background.frame.size.height);
}




@end
