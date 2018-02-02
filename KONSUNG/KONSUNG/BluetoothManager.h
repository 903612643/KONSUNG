//
//  BluetoothManager.h
//  Wasp
//
//  Created by 羊德元 on 15/6/1.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//
/**
 *  <-蓝牙连接管理类->
 *  每个蓝牙4.0的设备都是通过服务和特征来展示自己的，一个设备必然包含一个或多个服务，每个服务下面又包含若干个特征。特征是与外界交互的最小单位。
 *  比如说，一台蓝牙4.0设备，用特征A来描述自己的出厂信息，用特征B来与收发数据等. 服务和特征都是用UUID来唯一标识的.
 *
 *  作为一个中心要实现完整的通讯，一般要经过这样几个步骤：
 *  建立中心角色 — 扫描外设（discover）— 连接外设(connect) — 扫描外设中的服务和特征(discover) — 与外设做数据交互(explore and interact) — 断开连接(disconnect)
 *
 
 2015-06-02 10:13:36.445 GEEZBAND[12037:6252583] RSSI~~~~~~ -60, name = KONSUNG M6100
 2015-06-02 10:13:36.446 GEEZBAND[12037:6252583] advertisementData = {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = "KONSUNG M6100";
 kCBAdvDataServiceUUIDs =     (
 FF60
 );
 }
 
 2015-06-02 16:43:54.252 KONSUNG[12358:6332271] [error code] = 0, discover services = (
 "<CBService: 0x170469240, isPrimary = YES, UUID = FF60>"
 )
 2015-06-02 16:43:54.431 KONSUNG[12358:6332271] [error code] = 0, service = <CBService: 0x170469240, isPrimary = YES, UUID = FF60>, characteristics = (
 "<CBCharacteristic: 0x17009d650, UUID = FF61, properties = 0xA, value = (null), notifying = NO>",
 "<CBCharacteristic: 0x17009d600, UUID = FF62, properties = 0x2, value = (null), notifying = NO>",
 "<CBCharacteristic: 0x17009d5b0, UUID = FF63, properties = 0x8, value = (null), notifying = NO>",
 "<CBCharacteristic: 0x1702810e0, UUID = FF64, properties = 0x10, value = (null), notifying = NO>"
 )
 
 
 
 *
 */


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceSyncData.h"

//_________________________________________________________________________________________________

static NSString * const KONSUNG_Device_SpO2_Finger   = @"KONSUNG M6100";  // 指夹式血氧
static NSString * const KONSUNG_Device_SpO2_Wrist    = @"KONSUNG M6200";  // 腕式血氧
static NSString * const KONSUNG_Device_NIBP          = @"KONSUNG M6303";  // 血压
static NSString * const KONSUNG_Device_UUID          = @"FF60";  // 设备UUID

static NSString * const UUID_Device_Service_Power                = @"180F";
static NSString * const UUID_Device_Characteristics_Power        = @"2A19";


static NSString * const UUID_SpO2_Service_Data                   = @"0xFF60";
static NSString * const UUID_SpO2_Characteristics_Data_Switch    = @"0xFF61";
static NSString * const UUID_SpO2_Characteristics_Data_Effective = @"0xFF62";
static NSString * const UUID_SpO2_Characteristics_Data_Count     = @"0xFF63";
static NSString * const UUID_SpO2_Characteristics_Data_SpO2      = @"0xFF64";


static NSString * const UUID_NIBP_Service_Data_Send              = @"0xFFE5";
static NSString * const UUID_NIBP_Characteristics_Data_Send      = @"0xFFE9";


static NSString * const UUID_NIBP_Service_Data_Receive           = @"0xFFE0";
static NSString * const UUID_NIBP_Characteristics_Data_Receive   = @"0xFFE4";

//_________________________________________________________________________________________________

@protocol BluetoothManagerDelegate <NSObject>

- (void)centralManagerStatePoweredOn;
- (void)disconnectPeripheral;
- (void)updataNotifyValueForSpO2Data:(NSData *)data;

@end


@interface BluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(assign, nonatomic) id<BluetoothManagerDelegate> delegate;

@property(nonatomic, readonly) Boolean BluetoothSupport;  // 当前蓝牙是否可用

// 创建中心设备
@property(nonatomic, strong) CBCentralManager *centralManager;     // 创建中心设备
@property(nonatomic, strong) CBPeripheral     *myPeripheral;       // 当前连接的设备
@property(nonatomic, strong) CBPeripheral     *myPeripheralSpO2Finger;    // 当前连接的设备
@property(nonatomic, strong) CBPeripheral     *myPeripheralSpO2Wrist;     // 当前连接的设备
@property(nonatomic, strong) CBPeripheral     *myPeripheralNIBP;

@property(nonatomic, strong) CBPeripheral     *nearestPeripheral;  // 离设备中心最近的外设, 匹配RSSI最大的设备
@property(nonatomic, strong) NSMutableArray   *scanDeviceList;     // 扫描到的所有设备列表

// 设备基本信息
@property(nonatomic, readonly) int devicePower;  // 设备电量
@property(nonatomic, readonly) NSString *deviceName;    // 设备名称

// 保存从服务中扫描的特征
@property(nonatomic, readonly) CBCharacteristic *characteristicDevicePower;

@property(nonatomic, readonly) CBCharacteristic *characteristicSpO2DataSwitch;
@property(nonatomic, readonly) CBCharacteristic *characteristicSpO2DataEffective;
@property(nonatomic, readonly) CBCharacteristic *characteristicSpO2DataCount;
@property(nonatomic, readonly) CBCharacteristic *characteristicSpO2DataSpO2;

@property(nonatomic, readonly) CBCharacteristic *characteristicNIBPDataSend;
@property(nonatomic, readonly) CBCharacteristic *characteristicNIBPDataReceive;

// 从设备发送请求返回的数据
@property(readonly) int returnValue;
@property(readonly) NSData *returnData;

/// 生成单例对象
+ (BluetoothManager*)sharedModel;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 蓝牙基本方法(扫描\建立连接\断开连接)
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  @param scanDeviceList    返回扫描到的所有设备列表
 *  @param nearestPeripheral 返回靠近手机的最近设备
 */
typedef void (^ScanAroundPeripheralsBlock)(NSArray *scanDeviceList, CBPeripheral *nearestPeripheral);
@property (nonatomic, copy) ScanAroundPeripheralsBlock ScanDeviceBlock;
/**
 *  扫描周边设备
 *
 *  @param time  扫描时间
 *  @param block 回调
 */
- (void)scanAroundPeripherals:(float)time block:(ScanAroundPeripheralsBlock)block;

/**
 *  @param isConnect 是否成功连接设备
 */
typedef void (^ConnectPeripheralsBlock)(Boolean isConnect);
@property (nonatomic, copy) ConnectPeripheralsBlock ConnectDeviceBlock;
/**
 *  连接设备
 *
 *  @param peripheral 指定的设备
 *  @param block      回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral block:(ConnectPeripheralsBlock)block;

/**
 *  扫描并连接设备
 *
 *  @param lastDeviceName 需要连接的设备名
 *  @param block          回调
 */
typedef void (^SacnAndConnectPeripheralsBlock)();
@property (nonatomic, copy) SacnAndConnectPeripheralsBlock ScanAndConnectBlock;
- (void)scanAndConnectPeripheral:(NSString *)name block:(SacnAndConnectPeripheralsBlock)block;

/**
 *  断开指定的设备
 *
 *  @param peripheral 指定的设备
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 蓝牙基本方法(数据读写)
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  @param value 从特征值读取到的数据
 */
typedef void (^ReadValueForCharacteristicBlock)(NSData *value);
@property (nonatomic, copy) ReadValueForCharacteristicBlock ReadValueBlock;

/**
 *  从特征值读取数据
 *
 *  @param characteristic 特征值
 *  @param block          回调
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic block:(ReadValueForCharacteristicBlock)block;

/**
 *  从特征值写入数据
 *
 *  @param characteristic 特征值
 *  @param value          数据
 */
- (void)writeValueForCharacteristic:(CBCharacteristic *)characteristic value:(NSData *)value whetherWait:(Boolean)wait;

@end
