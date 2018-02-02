//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/20.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//
#import <Foundation/Foundation.h>
 

@interface LshGo : NSObject

+ (NSString *)md5:(NSString *)str;
+(long)getTimestamp:(NSDate *)datenow;
+(NSString *)getReq:(NSString *)requestString;



+(NSDateComponents *)dateFengJie:(NSDate *)now;
+(NSArray *)getDateZhou:(NSDate *)now;
+ (NSArray *)getMonthBeginAndEndWith:(NSDate *)newDate;

@end
