//
//  DatabaseManager.m
//  GEEZBAND
//
//  Created by 羊德元 on 15/8/1.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager() {
    FMDatabase *database;
}

@end

@implementation DatabaseManager

+ (DatabaseManager *)sharedModel {
    static DatabaseManager *sharedInstance;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[DatabaseManager alloc] init];
        }
        return sharedInstance;
    }
    return sharedInstance;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Create/Open/Close Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 打开/建立资料库
 
 在iOS环境下，只有document directory 是可以进行读写的。
 在写程式时用的那个Resource资料夹底下的东西都是read-only。
 因此，建立的资料库要放在document 资料夹下。
 
 */
// 打开数据库, 传入用户当前 ID 作为文件夹保存, 当前绑定设备 SN 作为数据库名
- (void)openDatabaseWithAccount:(NSString *)account deviceSN:(NSString *)SN {
    
    // 获取 APP 沙盒路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *uidPath = [NSString stringWithFormat:@"%@/%@/%@", docPath, Folder_Name, account];
    NSString *dbPath  = [NSString stringWithFormat:@"%@/%@.sqlite", uidPath, SN];
    
    NSLog(@"dbPath=%@",dbPath);
    
    // 检测路径是否存在, 如果不存在则创建路径
    if ([[NSFileManager defaultManager] fileExistsAtPath:uidPath] == false) {
        [[NSFileManager defaultManager] createDirectoryAtPath:uidPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    
    database = [FMDatabase databaseWithPath:dbPath];
    
    if (![database open]) {
        return;
    }
    
    NSLog(@"FMDB_数据库打开! account = %@, device = %@ \n dbPath = %@", account, SN, dbPath);
}

/** 打开数据库 */
- (void)openDatabase {
    
    NSString *account = Default_Account;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userAccount"] != nil) {
        account = [[NSUserDefaults standardUserDefaults] objectForKey:@"userAccount"];
    }
    
    [self openDatabaseWithAccount:account deviceSN:Default_Device_SN];
}

/** 关闭数据库 */
- (void)closeDatabase {
    NSLog(@"FMDB_数据库关闭!");
    [database close];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Check Table In Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 检测是否存在表 */
- (BOOL)isTableExsit:(NSString *)name {
    FMResultSet *rs = [database executeQuery:@"SELECT COUNT(*) FROM sqlite_master WHERE type ='table' AND name = ?", name];
    
    if ([rs next]) {
        if ([rs intForColumnIndex:0] > 0) {
            NSLog(@"FMDB_已存在表: %@", name);
            return true;
        }
    }
    [rs close];
    NSLog(@"FMDB_未找到表: %@", name);
    return false;
}

/** 获取当前表总数 */
- (int)getTableNumber {
    FMResultSet *rs = [database executeQuery:@"SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' "];
    [rs next];
    int num = [rs intForColumnIndex:0];
    
    [rs close];
    return num;
}

/** 获取表中记录数 */
- (int)getRecordNumber:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", tableName];
    FMResultSet *rs = [database executeQuery:sqlstr];
    [rs next];
    int num = [rs intForColumnIndex:0];
    
    [rs close];
    return num;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)getTableName:(int)utc {
    
    NSString *tableDate = [DeviceSyncData utcToDateString:utc dateFormat:@"yyyy_MM_dd"];
    NSString *tableName = [NSString stringWithFormat:@"%@%@", Table_Prefix_Name, tableDate];
    
    return tableName;
}

- (void)addDataToTable:(DeviceSpO2Value)data currentUTC:(int)utc deviceName:(NSString *)devName {
    
    NSString *tableName = [self getTableName:utc];
    
    //______________________________________________________________________________________________________
    // 如果不存在表名, 则创建表
    
    if ([self isTableExsit:tableName] == false) {
        NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@,%@,%@,%@,%@,%@)",
                            tableName,
                            @"ID integer PRIMARY KEY AUTOINCREMENT NOT NULL",
                            KEY_TABLE_CREATE_UTC,
                            KEY_TABLE_CREATE_DATE,
                            KEY_TABLE_CREATE_DEVICE,
                            KEY_TABLE_CREATE_SPO2,
                            KEY_TABLE_CREATE_PR];
        [database executeUpdate:sqlstr];
        
        NSLog(@"FMDB_正在建表: %@",tableName);
    }
    
    //______________________________________________________________________________________________________
    // 更新数据
    
    NSString *dateStr = [DeviceSyncData utcToDateString:utc dateFormat:@"yyyy_MM_dd HH:mm:ss"];
    
    NSString *sqlstr = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@) VALUES (?,?,?,?,?)",
                        tableName,
                        KEY_DATA_UTC,
                        KEY_DATA_DATE,
                        KEY_DATA_DEVICE,
                        KEY_DATA_SPO2,
                        KEY_DATA_PR];
    
    [database executeUpdate:sqlstr,
     [NSNumber numberWithInt:utc],
     [NSString stringWithFormat:@"%@", dateStr],
     [NSString stringWithFormat:@"%@", devName],
     [NSNumber numberWithInt:data.SpO2],
     [NSNumber numberWithInt:data.Pr]];
    
    NSLog(@"FMDB_插入新数据成功!");
}



- (void)updateDataToTableWithUTC:(int)utc spo2:(int)spo2 pr:(int)pr {
    
    NSString *tableName = [self getTableName:utc];
    
    NSString *sqlstr = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ?",
                        tableName,
                        KEY_DATA_SPO2,
                        KEY_DATA_PR,
                        KEY_DATA_UTC];
    
    [database executeUpdate:sqlstr,
     [NSNumber numberWithInt:spo2],
     [NSNumber numberWithInt:pr],
     [NSNumber numberWithInt:utc]];
    
    NSLog(@"FMDB_数据修改成功! utc = %d, spo2 = %d, pr = %d", utc, spo2, pr);
}

- (void)deleteDataToTableWithUTC:(int)utc {
    
    NSString *tableName = [self getTableName:utc];
    
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                        tableName,
                        KEY_DATA_UTC];
    
    [database executeUpdate:sqlstr,
     [NSNumber numberWithInt:utc]];

    NSLog(@"FMDB_删除数据成功! utc = %d", utc);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Get Data For Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 获取所有有数据的表 */
- (NSMutableArray *)getAllTableNameWithDataForDatabase {
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name LIKE '%@%%' ORDER BY name DESC", Table_Prefix_Name];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        
        NSString *tableName = [rs stringForColumn:@"name"];
        
        if ([self getRecordNumber:tableName] > 0) {
            [dataArray addObject:tableName];
        }
    }
    [rs close];
    
    // 如果没有当天的表, 则添加未知项进去
    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSString *currentDate = [self getTableName:[[NSDate date] timeIntervalSince1970]];
    NSString *listDate    = @"last";
    
    if (dataArray.count > 0) {
        listDate = [NSString stringWithFormat:@"%@", dataArray[0]];
    }
    
    if ([currentDate isEqualToString:listDate] == false) {
        [newArray addObject:currentDate];
        [newArray addObjectsFromArray:dataArray];
        
        return newArray;
    }
    
    return dataArray;
}

- (void)deleteAllTableDataForDatabase {
    
    //______________________________________________________________________________________________________
    // 找到所有表
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name LIKE '%@%%' ORDER BY name DESC", Table_Prefix_Name];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        NSString *tableName = [rs stringForColumn:@"name"];
        [deleteArray addObject:tableName];
    }
    [rs close];
    
    //______________________________________________________________________________________________________
    // 删除所有表
    
    for (int i = 0; i < deleteArray.count; i++) {
        NSString *tableName = [NSString stringWithFormat:@"%@", deleteArray[i]];
        [self deleteTable:tableName];
    }
}

// 删除表
- (BOOL)deleteTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![database executeUpdate:sqlstr]) {
        NSLog(@"Delete table error!");
        return NO;
    }
    
    NSLog(@"FMDB_删除表成功! table = %@", tableName);
    return YES;
}

// 清除表
- (BOOL)cleanTable:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![database executeUpdate:sqlstr]) {
        NSLog(@"Clean table error!");
        return NO;
    }
    
    NSLog(@"FMDB_清除表中数据成功! table = %@", tableName);
    return YES;
}

/** 取得某个表中最大 utc 时间 */
- (int)getMaxUtcInTable:(NSString *)tableName {
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", tableName, KEY_DATA_UTC];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    [rs next];
    
    int utc = [rs intForColumn:KEY_DATA_UTC];
    
    [rs close];
    
    return utc;
}

/** 获取所有数据中最大的 utc 时间 */
- (int)getRecentRecordUtc {
    
    if ( [self getTableNumber] <= 0 ) {  // 如果表中没有数据, 则返回 0
        return 0;
    }
    
    // 查找所有表中最大的日期
    
    int maxUtc = 0;
    
    FMResultSet *rs = [database executeQuery:@"SELECT * FROM sqlite_master WHERE type = 'table' RDER BY name DESC"];
    
    [rs next];
    
    {
        NSString *maxTableName = [rs stringForColumn:@"name"];
        
        if ( [self getRecordNumber:maxTableName] ) {
            maxUtc = [self getMaxUtcInTable:maxTableName];
        }
        
        [rs close];
    }
    
    return maxUtc;
}

/** 获取某天的所有数据 */
- (NSMutableArray *)getSpO2DataForOneDay:(int)utc {
    
    NSString *tableName = [self getTableName:utc];
    return [self getSpO2DataForOneDayWithTableName:tableName];
}

// 获取某个表的所有数据
- (NSMutableArray *)getSpO2DataForOneDayWithTableName:(NSString *)tableName {
    
    if ([self isTableExsit:tableName] == false || [self getRecordNumber:tableName] <= 0) return nil;
    
    //______________________________________________________________________________________________________
    // 查找数据并封装
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", tableName, KEY_DATA_UTC];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    while ([rs next]) {
        NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
        
        [dataDic setObject:[NSNumber numberWithInt:[rs intForColumn:KEY_DATA_UTC]]  forKey:KEY_DATA_UTC];
        [dataDic setObject:[NSString stringWithFormat:@"%@", [rs stringForColumn:KEY_DATA_DATE]]   forKey:KEY_DATA_DATE];
        [dataDic setObject:[NSString stringWithFormat:@"%@", [rs stringForColumn:KEY_DATA_DEVICE]] forKey:KEY_DATA_DEVICE];
        [dataDic setObject:[NSNumber numberWithInt:[rs intForColumn:KEY_DATA_SPO2]] forKey:KEY_DATA_SPO2];
        [dataDic setObject:[NSNumber numberWithInt:[rs intForColumn:KEY_DATA_PR]]   forKey:KEY_DATA_PR];
        
        [dataArray addObject:dataDic];
    }
    [rs close];
    
    
    return dataArray;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Other Method
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 获取反向数组
+ (NSArray *)getInversionArray:(NSArray *)array {
    
    if (array.count > 0 == false) {
        return nil;
    }
    
    NSMutableArray *inversionArray = [[NSMutableArray alloc] init];
    for (int i = (int)array.count - 1; i >= 0; i--) {
        [inversionArray addObject:array[i]];
    }
    return inversionArray;
}

@end
