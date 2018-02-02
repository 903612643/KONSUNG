//
//  DeviceSyncData.h
//  康尚健康
//
//  Created by SpaceTime on 15/6/29.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//
// 用于设备同步的数据进行组装/拆分

#import <Foundation/Foundation.h>

/**
 *  Counter:参数数据模式下,APP 每收一个参数包需要反馈 0xFF61 特征值,以确认数据发送成功, 测试模式下发送数据无需确认;
 *  SpO2:血氧参数,8 位无符号数,有效范围 0-100,0x7F 是无效值,显示“--”; 
 *  Pr:脉率参数,8 位无符号数,有效范围 0-250,0x7F 是无效值,显示“--”
 *  Pleth:实时血氧波形, 8位无符号数,有效范围0-100,0xFF是无效值,pleth需要在屏幕绘制,建立一个图形显示区,纵向范围是 0-100,收到一点显示一点,横坐标右移一点,满屏后把屏幕清空;
 */
#pragma pack(1)  // 设置结构体的边界对齐为1个字节，也就是所有数据在内存中是连续存储的
typedef struct {
    uint8_t Counter;
    uint8_t SpO2;
    uint8_t Pr;
    uint8_t Pleth;
} DeviceSpO2Value;

@interface DeviceSyncData : NSObject

+ (DeviceSpO2Value)analysisDeviceSpO2ValueForStruct:(NSData *)data;
+ (NSDictionary *)analysisDeviceSpO2ValueForDic:(NSData *)data;

/**
 *  将 UTC 时间转换为字符串
 *
 *  @param UTC    utc时间
 *  @param format 如格式 @"yyyy-MM-dd HH:mm:ss Z"
 *
 *  @return 格式化的字符串
 */
+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format;

/**
 *  将字符串转换为 UTC 时间
 *
 *  @param date_string 时间字符串
 *  @param format      @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return utc 时间
 */
+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format;

@end
