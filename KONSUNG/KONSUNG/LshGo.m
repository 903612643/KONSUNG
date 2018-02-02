//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/20.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "LshGo.h"
#import "NSString+SBJSON.h"
 

@implementation LshGo

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

+(long)getTimestamp:(NSDate *)datenow{
//    NSDate *datenow = [NSDate date];
//    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return (long)[datenow timeIntervalSince1970];
}

+(NSString *)getReq:(NSString *)requestString{
    NSRange rang = [requestString rangeOfString:@"{"];
    return [requestString substringFromIndex:rang.location];
}


//可以取年  月 日 等等。
+(NSDateComponents *)dateFengJie:(NSDate *)now{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    
    return[calendar components:unitFlags fromDate:now];
}


//周
+(NSArray *)getDateZhou:(NSDate *)now{
//    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:now];
    
    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday]-1;//[comp weekday]-1;//改过的。
    // 得到几号
    NSInteger day = [comp day];
    
    NSLog(@"weekDay:%ld   day:%ld",(long)weekDay,(long)day);
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 1;
        lastDiff = 0;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 7 - weekDay;//lastDiff = 9 - weekDay; //改过的
    }
    
    NSLog(@"firstDiff:%ld   lastDiff:%ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    NSLog(@"星期一开始 %@",[formater stringFromDate:firstDayOfWeek]);
    NSLog(@"当前 %@",[formater stringFromDate:now]);
    
    NSDateFormatter *formater1 = [[NSDateFormatter alloc] init];
    [formater1 setDateFormat:@"yyyy-MM-dd 23:59:59"];
    NSLog(@"星期天结束 %@",[formater1 stringFromDate:lastDayOfWeek]);
    
    [mutableArr addObject:firstDayOfWeek];
    [mutableArr addObject:lastDayOfWeek];
    
    [mutableArr addObject:[formater stringFromDate:firstDayOfWeek]];
    [mutableArr addObject:[formater1 stringFromDate:lastDayOfWeek]];
    [mutableArr addObject:[NSNumber numberWithInteger:weekDay]];
    
    return mutableArr;
}

+ (NSArray *)getMonthBeginAndEndWith:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return nil;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
//    NSString *strname = [NSString stringWithFormat:@"%@-%@",beginString,endString];
 
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    [mutableArr addObject:beginDate];
    [mutableArr addObject:endDate];
    
    [mutableArr addObject:beginString];
    [mutableArr addObject:endString];
    
    return  mutableArr;
    
}

@end
