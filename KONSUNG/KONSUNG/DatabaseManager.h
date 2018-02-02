//
//  DatabaseManager.h
//  GEEZBAND
//
//  Created by 羊德元 on 15/8/1.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDictionaryKey.h"

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "DeviceSyncData.h"

static NSString * const Folder_Name = @"KONSUNG";
static NSString * const Table_Prefix_Name = @"KONSUNG_";
static NSString * const Default_Account   = @"Default_Account";
static NSString * const Default_Device_SN = @"KONSUNG_M6100";

@interface DatabaseManager : NSObject

// 获取单例对象


+ (DatabaseManager *)sharedModel;

/// 获取反向数组
+ (NSArray *)getInversionArray:(NSArray *)array;

/// 打开数据库
- (void)openDatabase;
/// 关闭数据库
- (void)closeDatabase;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  添加数据至数据库
 *
 *  @param data    DeviceSpO2Value
 *  @param utc     当前 utc 时间
 *  @param devName 设备名
 */
- (void)addDataToTable:(DeviceSpO2Value)data currentUTC:(int)utc deviceName:(NSString *)devName;

/**
 *  更新数据
 *
 *  @param utc  数据的时间戳
 *  @param spo2 SpO2
 *  @param pr   Pr
 */
- (void)updateDataToTableWithUTC:(int)utc spo2:(int)spo2 pr:(int)pr;

/**
 *  删除数据
 *
 *  @param utc 数据的时间戳
 */
- (void)deleteDataToTableWithUTC:(int)utc;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Get Data For Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 获取所有有数据的表 */
- (NSMutableArray *)getAllTableNameWithDataForDatabase;
/** 删除所有表 */
- (void)deleteAllTableDataForDatabase;

/** 获取某天的所有数据 */
- (NSMutableArray *)getSpO2DataForOneDay:(int)utc;
/** 获取某个表的所有数据 */
- (NSMutableArray *)getSpO2DataForOneDayWithTableName:(NSString *)tableName;

@end