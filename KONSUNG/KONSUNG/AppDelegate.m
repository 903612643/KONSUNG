//
//  AppDelegate.m
//  KONSUNG
//
//  Created by 羊德元 on 15/6/1.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"

#import "ViewController.h"
#import "UserLoginViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"

// (AppDelegate *)[UIApplication sharedApplication].delegate

@interface AppDelegate ()

@property (nonatomic, strong) ViewController *rootViewCtrl;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
    
    
    /**
     *  下载数据示意
     2015-06-16 16:09:50.592 KONSUNG[23109:9130596] setDownloadDataToDatabase___count = 2, array = (
     {
     checkdate = "2015-06-16 16:09:32";
     devicetype = "CONSUNG M6100";
     id = 4;
     prdata = "75.00000";
     spo2data = "99.00000";
     },
     {
     checkdate = "2015-06-16 16:08:27";
     devicetype = "CONSUNG M6100";
     id = 3;
     prdata = "71.00000";
     spo2data = "99.00000";
     }
     )
     
     */
    
    DatabaseManager *databasemang=[DatabaseManager sharedModel];
    
   // [databasemang openDatabase];
    
    // 将获取的数据插入数据库
    
    DeviceSpO2Value spo2;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"2015-06-16 16:09:32", @"checkdate",
                          @"CONSUNG M6100", @"devicetype",
                          @"4", @"id",
                          @"75.00000", @"prdata",
                          @"99.00000", @"spo2data",
                          nil];
    NSLog(@"dic=%@",dic);

    //NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:dataArray[i]];
    
    spo2.SpO2 = [[dic objectForKey:@"spo2data"] intValue];
    spo2.Pr = [[dic objectForKey:@"prdata"] intValue];
    
    // 将 2015-10-25 格式的字符串替换为 2015_10_25，避免数据库异常
    NSString *date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"checkdate"]];
    //        date = [date stringByReplacingOccurrencesOfString:@"-"
    //                                               withString:@"_"];
    
    int utc = [DeviceSyncData dateFormatToUTC:date dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *devName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"devicetype"]];
    
    [databasemang addDataToTable:spo2 currentUTC:utc deviceName:devName];
    
  //  [databasemang getAllTableNameWithDataForDatabase];
    
  //  [databasemang getSpO2DataForOneDayWithTableName];
    
    //[self initRootViewController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[DatabaseManager sharedModel] closeDatabase];
}

/// 初始化根视图
- (void)initRootViewController {
    //_________________________________________________________________________________________________
    // 载入APP主界面
    //"Konsung_System" = "konsung health control system";//"康尚健康管理系统"; 国际化
    self.rootViewCtrl = [[ViewController alloc] initWithTitle:NSLocalizedString(@"Konsung_System",nil) color:UIColor.whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.rootViewCtrl];
 
    [self.rootViewCtrl.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.39 green:0.67 blue:0.21 alpha:1]];
    [self.rootViewCtrl.navigationController.navigationBar setTintColor:UIColor.whiteColor];
    
    //_________________________________________________________________________________________________
    // 检测是否已登录, 如果未登录则载入用户登录界面
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
    if ([login isEqualToString:@"1"] == YES) {
        [self pushUserLoginView];
    }
}

- (void)pushUserLoginView {
    
    UserLoginViewController *viewCtrl = [[UserLoginViewController alloc] initWithTitle:NSLocalizedString(@"Login",nil) color:UIColor.whiteColor];
    
    [self.rootViewCtrl.navigationController pushViewController:viewCtrl animated:false];
}
//打开用户数据库
- (void)openUserDatabase {
    
    [[DatabaseManager sharedModel] openDatabase];
   // [self.rootViewCtrl refreshView];
}

@end
