//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/25.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define STR_URL_IP @"http://120.27.36.122:81/konsung/konsung.php/App/Mobile/login?mobile="
#define STR_URL_IP @"http://www.zclear.cn/konsung/konsung.php/App/Mobile/login?mobile="
//#define STR_URL_IP @"http://192.168.1.35:8080/YanHong/mobile.action"

@interface UserObj : NSObject

@property (nonatomic, strong)NSDictionary *user;

@property (nonatomic, strong)NSString *strUserName;
 
+(UserObj*)getUserObj;

@end
