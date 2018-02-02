//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/8/26.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "AboutInfoViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"


@interface AboutInfoViewController ()<ASIHTTPRequestDelegate>
{
    UserObj *userObj;
    ASIFormDataRequest *asiRequest;
}
@end

@implementation AboutInfoViewController

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
    
    [self getHTTPRequest];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

//"packmd5":"MD5MD5MDMD5MD5MDMD5MD5MDMD5MD5MD",
//
//"ver":"1.0",
//
//"command":"1006",
//
//"errcode":"000",
//
//"errmsg":"提示信息"
//
//"timestamp":"137889283",
//
//"content":"公司介绍"


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
            CGFloat v = self.view.frame.size.width;
            CGFloat h = self.view.frame.size.height;
            
            NSString *strUrl = [dict objectForKey:@"content"];
            NSURL * url  = [NSURL URLWithString:strUrl];
            UIWebView  *_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, v, h)];
            //    _webView.delegate = self;
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:_webView];
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


//"packmd5":"MD5MD5MDMD5MD5MDMD5MD5MDMD5MD5MD",
//
//"ver":"1.0",
//
//"command":"1005",
//
//"errcode":"000",
//
//"timestamp":"137889283",
//
//"keyname":"C100"

-(void)getHTTPRequest{
    
    NSDate *datenow = [NSDate date];
    NSDictionary *dict = userObj.user;
    NSString *strUID = [dict objectForKey:@"uid"];
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"command\":\"1005\",\"errcode\":\"000\",\"timestamp\":%ld,\"keyname\":\"c100\"}abx23579436",[LshGo getTimestamp:datenow]];
    NSString *pwd1 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"command\":\"1005\",\"errcode\":\"000\",\"timestamp\":%ld,\"keyname\":\"c100\"}",pwd1, [LshGo getTimestamp:datenow]];
    
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
