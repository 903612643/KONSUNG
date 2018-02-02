//
//  DeviceSyncData.m
//  康尚健康
//
//  Created by SpaceTime on 15/5/29.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//

#import "DeviceSyncData.h"
#import "DataDictionaryKey.h"

@implementation DeviceSyncData

+ (DeviceSpO2Value)analysisDeviceSpO2ValueForStruct:(NSData *)data {
    
    DeviceSpO2Value spo2Value;
    
    [data getBytes:&spo2Value.Counter range:NSMakeRange(0, 1)];
    [data getBytes:&spo2Value.SpO2    range:NSMakeRange(1, 1)];
    [data getBytes:&spo2Value.Pr      range:NSMakeRange(2, 1)];
    [data getBytes:&spo2Value.Pleth   range:NSMakeRange(3, 1)];
    
    return spo2Value;
}


+ (NSDictionary *)analysisDeviceSpO2ValueForDic:(NSData *)data {
    
    DeviceSpO2Value spo2Value = [DeviceSyncData analysisDeviceSpO2ValueForStruct:data];
    
    NSDictionary *dic = @{KEY_DATA_COUNTER : @(spo2Value.Counter),
                          KEY_DATA_SPO2    : @(spo2Value.SpO2),
                          KEY_DATA_PR      : @(spo2Value.Pr),
                          KEY_DATA_PLETH   : @(spo2Value.Pleth),
                          };
    return dic;
}

/**
 *  将 UTC 时间转换为字符串
 *
 *  @param UTC    将 UTC 时间转换为字符串
 *  @param format @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return 字符串
 */
+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:UTC]];
    return dateString;
}

/**
 *  将字符串转换为 UTC 时间
 *
 *  @param date_string 时间字符串
 *  @param format      @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return utc 时间
 */
+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format {
    
    int utc = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    utc = [[dateFormatter dateFromString:date_string] timeIntervalSince1970];
    return utc;
}

@end
