//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/8/25.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "ModifyPasswordViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"

@interface ModifyPasswordViewController () <ASIHTTPRequestDelegate,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    UITableView *tableViewList;
    NSArray     *grouplistData;
    
    UITextField *oldPasswordTextField;
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
    
    
    UserObj *userObj;
    
    ASIFormDataRequest *asiRequest;
}

@end

@implementation ModifyPasswordViewController

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

    [self initGroupListData];  // 初始化 group 数组数据
    
    tableViewList = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableViewList.delegate = self;
    tableViewList.dataSource = self;
    // 确保TablView能够正确的调整大小
    tableViewList.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableViewList.scrollEnabled = true;  // 设置 scroll 为可见
    [self.view addSubview:tableViewList];
    
    // 让 UITableView 响应点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tableViewList addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initGroupListData {
    
    /** 按照 Header, Title, 来封装二维 list 表 */
    
    grouplistData = [NSArray arrayWithObjects:
                     
                     [NSArray arrayWithObjects:NSLocalizedString(@"",nil),
                      NSLocalizedString(@"old_password",nil),
                      NSLocalizedString(@"new_password",nil),
                      NSLocalizedString(@"confirm_password",nil), nil],
                     
                     [NSArray arrayWithObjects:@"",
                      NSLocalizedString(@"confirm",nil), nil],
                     
                     nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table View Data Source Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 一共有多少组数据
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return grouplistData.count;
}

/// 每组有多少行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = ((int)[grouplistData[section] count] - 1);
    return count;
}

/// 生成所有的 table cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // 设置为点击不变色
    
    int section = (int)[indexPath section];
    int row = (int)[indexPath row];
    NSString *cell_title = [NSString stringWithFormat:@"%@", grouplistData[section][row + 1]];
    
    //_________________________________________________________________________________________________
    
    if ([cell_title isEqualToString:NSLocalizedString(@"old_password",nil)]) {
        
        // 输入框
        oldPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        oldPasswordTextField.font = [UIFont systemFontOfSize:15];
        oldPasswordTextField.delegate  = self;
        oldPasswordTextField.secureTextEntry = true;  // 密码隐私
        oldPasswordTextField.placeholder = NSLocalizedString(@"enter_old_pswd", nil);
        
        cell.accessoryView = oldPasswordTextField;
    }
    else if ([cell_title isEqualToString:NSLocalizedString(@"new_password",nil)]) {
        
        // 输入框
        newPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        newPasswordTextField.font = [UIFont systemFontOfSize:15];
        newPasswordTextField.delegate  = self;
        newPasswordTextField.secureTextEntry = true;  // 密码隐私
        newPasswordTextField.placeholder = NSLocalizedString(@"enter_new_pswd", nil);
        
        cell.accessoryView = newPasswordTextField;
    }
    else if ([cell_title isEqualToString:NSLocalizedString(@"confirm_password",nil)]) {
        
        // 输入框
        confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        confirmPasswordTextField.font = [UIFont systemFontOfSize:15];
        confirmPasswordTextField.delegate  = self;
        confirmPasswordTextField.secureTextEntry = true;  // 密码隐私
        confirmPasswordTextField.placeholder = NSLocalizedString(@"confirm_new_pswd", nil);
        
        cell.accessoryView = confirmPasswordTextField;
    }
    else if ([cell_title isEqualToString:NSLocalizedString(@"confirm",nil)]) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(self.view.frame.size.width/2-110, (cell.frame.size.height - 34) / 2, 220, 34)];
        [button setTitle:cell_title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setBackgroundColor:[UIColor orangeColor]];
        
        // 绘制圆角
        button.layer.cornerRadius = button.frame.size.height / 2;
        button.layer.masksToBounds = true;
        
        button.accessibilityValue = cell_title;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        
        cell_title = @"";
    }
    
    //_________________________________________________________________________________________________
    
    cell.textLabel.text = cell_title;  // 设置 cell title
    cell.textLabel.font = [UIFont systemFontOfSize:10];
//    cell.textLabel.adjustsFontSizeToFitWidth = true;
    return cell;
}

/// 选中 cell 的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];  //选中后的反显颜色即刻消失
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ---touch to resignFirstResponder
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 点击屏幕任意空白位置隐藏键盘
- (void)hideKeyboard {
    [oldPasswordTextField     resignFirstResponder];
    [newPasswordTextField     resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [oldPasswordTextField     resignFirstResponder];
    [newPasswordTextField     resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
    return YES;
}

- (IBAction)buttonPressed:(UIButton *)sender {
    
    NSString *stroldPasswordTextField = oldPasswordTextField.text;
    NSString *strnewPasswordTextField = newPasswordTextField.text;
    NSString *strconfirmPasswordTextField = confirmPasswordTextField.text;
    
    if (stroldPasswordTextField.length < 6 || stroldPasswordTextField.length > 16) {
        [self Alert:NSLocalizedString(@"old_pswd_error",nil)];
        return;
    }
    
    if (strnewPasswordTextField.length < 6 || strnewPasswordTextField.length > 16) {
        [self Alert:NSLocalizedString(@"new_pswd_error",nil)];
        return;
    }
    
    if (![strnewPasswordTextField isEqualToString:strconfirmPasswordTextField]) {
        [self Alert:NSLocalizedString(@"two_pswd_error",nil)];
        return;
    }
    
    [self getHTTPRequest:stroldPasswordTextField :strnewPasswordTextField];
}


//成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
        
        NSString *requestString = [LshGo getReq:[request responseString]];
        NSDictionary *dict = [requestString JSONValue];
        
        if (request.tag == 1) {
            NSString *strMasg = [dict objectForKey:@"errcode"];
            if ([strMasg isEqualToString:@"000"]) {
                NSString *stErrmsg = [dict objectForKey:@"errmsg"];
                [self Alert:stErrmsg];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if([strMasg isEqualToString:@"009"]){
                NSString *stErrmsg = [dict objectForKey:@"errmsg"];
                [self Alert:stErrmsg];
            }else{
                NSString *stErrmsg = [dict objectForKey:@"errmsg"];
                [self Alert:stErrmsg];
            }
            
            
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
    [self Alert:NSLocalizedString(@"fix_pswd_failed",nil)];
}

-(void)getHTTPRequest:(NSString *)strpwd :(NSString *)strNewPWD{
    NSDictionary *dict = userObj.user;
    NSString *strUID = [dict objectForKey:@"uid"];
    
    if (!strUID) {
        [self Alert:NSLocalizedString(@"login_account",nil)];
        return;
    }
    
    NSDate *datenow = [NSDate date];
    
    NSString *pwd = [LshGo md5:strpwd];
    NSString *newPwd = [LshGo md5:strNewPWD];
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1013\",\"errcode\":\"000\",\"timestamp\":%ld,\"uid\":\"%@\",\"oldpwd\":\"%@\",\"newpwd\":\"%@\"}abx23579436",[LshGo getTimestamp:datenow],strUID, pwd, newPwd];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"apptype\":\"2\",\"command\":\"1013\",\"errcode\":\"000\",\"timestamp\":%ld,\"uid\":\"%@\",\"oldpwd\":\"%@\",\"newpwd\":\"%@\"}", strpackmd5, [LshGo getTimestamp:datenow],strUID, pwd, newPwd];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 1;
    [asiRequest startAsynchronous];
    
    
}

-(void)Alert:(NSString *)strMag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system_hint",nil)
                                                    message:strMag
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"confirm",nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark --- UIAlertView Delegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
//        [networking logoutAccount];
    }
}

@end
