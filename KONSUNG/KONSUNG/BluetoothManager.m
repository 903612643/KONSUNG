//
//  BluetoothManager.m
//  Wasp
//
//  Created by 羊德元 on 15/6/1.
//  Copyright (c) 2015年 羊德元. All rights reserved.
//

#import "BluetoothManager.h"

static Boolean   BluetoothServerIsFind = false;
static int const Min_RSSI = -100;

@interface BluetoothManager () {
    int tmpRSSI;  // RSSI 索引范围
    NSString *scanDeviceName;
}

@end

@implementation BluetoothManager

/// 获取单例对象
+ (BluetoothManager*)sharedModel {
    static BluetoothManager *sharedInstance;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[BluetoothManager alloc] init];
        }
        return sharedInstance;
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        // 创建设备中心
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _BluetoothSupport = false;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Bluetooth Scan And Connect Device
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)initScan {
    // 重置 RSSI 搜索的范围
    tmpRSSI = -1000;
    scanDeviceName = @"NULL";
    BluetoothServerIsFind = false;
    
    self.nearestPeripheral = nil;
    self.myPeripheral = nil;
    self.scanDeviceList = [[NSMutableArray alloc] init];
}

- (void)scanAroundPeripherals:(float)time block:(ScanAroundPeripheralsBlock)block {
    
    if (block) {
        self.ScanDeviceBlock = block;
    }
    
    NSLog(@"----------开始扫描周边设备!");
    
    [self initScan];
    // 非重复式扫描, 即每个设备只扫描一次
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO}];
    [self performSelector:@selector(scanOver) withObject:nil afterDelay:time];
}

- (void)scanOver {
    NSLog(@"----------扫描结束!");
    [self.centralManager stopScan];
    
    if (self.ScanDeviceBlock) {
        self.ScanDeviceBlock(self.scanDeviceList, self.nearestPeripheral);
    }
}

- (void)connectPeripheral:(CBPeripheral *)peripheral block:(ConnectPeripheralsBlock)block {
    
    if (block) {
        self.ConnectDeviceBlock = block;
    }
    
    if ( peripheral.state != CBPeripheralStateConnected ) {//[peripheral isConnected] == false
        [self.centralManager connectPeripheral:peripheral
                                       options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES}];
        [self performSelector:@selector(checkConnectDevice) withObject:nil afterDelay:3.0];
    }
}

- (void)scanAndConnectPeripheral:(NSString *)name block:(SacnAndConnectPeripheralsBlock)block {
    
    if (block) {
        self.ScanAndConnectBlock = block;
    }
    
    NSLog(@"----------开始寻找特定设备 = %@", name);
    
    [self initScan];
    scanDeviceName = name;
    
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    if ( peripheral.state == CBPeripheralStateConnected ) {//[peripheral isConnected] == true
        _devicePower = 0;
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)checkConnectDevice {
//    if ([self.myPeripheral isConnected] == false) {
    if (self.myPeripheral.state != CBPeripheralStateConnected) {
        if (self.ConnectDeviceBlock) {
            self.ConnectDeviceBlock(false);
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Bluetooth Scan And Connect Callback
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// 中心设备状态改变时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"state=%ld",central.state);
    switch (central.state) {
        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"你的设备不支持蓝牙4.0", nil)
                                                            message:NSLocalizedString(@"",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
            
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"----------蓝牙已打开, 该设备支持 BLE !");
            [self.delegate centralManagerStatePoweredOn];
        }
            break;
            
        default:
            
            break;
    }
}


// 扫描周围设备, 如果周围有多个设备，则这个方法会被调用多次
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([RSSI intValue] <= 0
        && [RSSI intValue] >= Min_RSSI
        && [advertisementData objectForKey:@"kCBAdvDataLocalName"] != nil
        && [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] != nil
        ) {
        
        NSString *device_name = [NSString stringWithFormat:@"%@", [advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        NSString *device_uuid = [NSString stringWithFormat:@"%@", [[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] lastObject]];
        
        NSLog(@"RSSI~~~~~~ %d, name = %@", [RSSI intValue], device_name);
        NSLog(@"设备广播数据 = %@", advertisementData);
        
        if (
            //_________________________________________________________________________________________________
            // 通过设备名排查
            
            [device_name rangeOfString:KONSUNG_Device_SpO2_Finger].location != NSNotFound
            || [device_name rangeOfString:KONSUNG_Device_SpO2_Wrist].location != NSNotFound
            || [device_name rangeOfString:KONSUNG_Device_NIBP].location != NSNotFound
            
            //_________________________________________________________________________________________________
            // 通过 UUID 排查
            || [device_uuid rangeOfString:KONSUNG_Device_UUID].location != NSNotFound
            
            ) {
            
            // 如果找到符合条件的设备, 则进行连接
            if ([device_uuid isEqualToString:KONSUNG_Device_UUID] && self.myPeripheral.state != CBPeripheralStateConnected) {//[self.myPeripheral isConnected] == false
                [self connectPeripheral:peripheral block:^(Boolean isConnect) {
                    if (isConnect) {
                        if (self.ScanAndConnectBlock) {
                            self.ScanAndConnectBlock();
                        }
                    }
                }];
            }
            
            //_________________________________________________________________________________________________
            // 找到最近的设备
            
            if ([advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] != nil) {
                
                if(![self.scanDeviceList containsObject:peripheral]) {
                    [self.scanDeviceList addObject:peripheral];
                }
                
                // 从找到的设备列表中, 匹配最大 RSSI 值的设备, 即是最近的设备
                if (([RSSI intValue] > tmpRSSI) && ([RSSI intValue] < 0)) {
                    self.nearestPeripheral = peripheral;
                    tmpRSSI = [RSSI intValue];
                }
            }
        }
    }
}

// 成功连接设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"----------成功连接设备 = %@", peripheral);
    NSLog(@"----------开始扫描设备中的 Server!");
    
    self.myPeripheral = peripheral;
    self.myPeripheral.delegate  = self;
    
    _deviceName = self.myPeripheral.name;
    [self.myPeripheral discoverServices:nil];
    [self performSelector:@selector(checkDiscoverServices) withObject:nil afterDelay:3.0];
}

// 检测服务是否成功发现
- (void)checkDiscoverServices {
    
    if (BluetoothServerIsFind == false) {
        NSLog(@"############## 扫描 Server 异常!");
        if (self.ConnectDeviceBlock) {
            self.ConnectDeviceBlock(false);
        }
    }
}

// 未能与设备连接
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"----------连接蓝牙设备失败!!!");
    if (self.ConnectDeviceBlock) {
        self.ConnectDeviceBlock(false);
    }
}

// 断开蓝牙连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"----------蓝牙设备 %@ 已断开连接", peripheral.name);
    if (self.ConnectDeviceBlock) {
        self.ConnectDeviceBlock(false);
    }
    [self.delegate disconnectPeripheral];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Discover Services And Characteristics
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// 发现设备中的服务, 并查询服务所带的特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
//    NSLog(@"[error code] = %d, discover services = %@", (int)[error code], peripheral.services);
    
    if ([error code] == 0) {
        
        NSLog(@"----------发现 Server!");
        NSLog(@"----------开始扫描 Server 下的 characteristics!");
        
        BluetoothServerIsFind = true;
        
        for (CBService *services in peripheral.services) {
            
            if (//_________________________________________________________________________________________________
                // SpO2 模块
                
                [[services UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Service_Data]]
                
                //_________________________________________________________________________________________________
                // NIBP 模块
                
                || [[services UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Service_Data_Send]]
                || [[services UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Service_Data_Receive]]
                
                //_________________________________________________________________________________________________
                // 设备电量
                
                || [[services UUID] isEqual:[CBUUID UUIDWithString:UUID_Device_Service_Power]]
                
                ) {
                
                [peripheral discoverCharacteristics:nil forService:services];
            }
        }
        
    }
}

// 返回从服务中扫描设备的特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
//    NSLog(@"[error code] = %d, service = %@, characteristics = %@", (int)[error code], service, [service characteristics]);
    
    if ([error code] == 0) {
        
        NSLog(@"----------发现 characteristics!");
        
        NSArray *serviceCharacteristics = [service characteristics];
        CBCharacteristic *characteristic;
        
        for (characteristic in serviceCharacteristics) {
            
            //_________________________________________________________________________________________________
            // SpO2 模块
            
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Switch]]) {
                _characteristicSpO2DataSwitch = characteristic;
            }
            else if([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Effective]]) {
                _characteristicSpO2DataEffective = characteristic;
            }
            else if([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Count]]) {
                _characteristicSpO2DataCount = characteristic;
            }
            else if([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_SpO2]]) {
                _characteristicSpO2DataSpO2 = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];  // 开启订阅
                
                if (self.ConnectDeviceBlock) {
                    self.ConnectDeviceBlock(true);
                }
            }
            
            //_________________________________________________________________________________________________
            // NIBP 模块
            
            else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Send]]) {
                _characteristicNIBPDataSend = characteristic;
            }
            else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Receive]]) {
                _characteristicNIBPDataReceive = characteristic;
            }
            
            //_________________________________________________________________________________________________
            // 设备电量
            
            else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_Device_Characteristics_Power]]) {
                _characteristicDevicePower = characteristic;
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
        
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update And Write Value Callback
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// 当蓝牙设备有数据返回时系统进行回调通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
//    NSLog(@"[error code] = %d, characteristic_updata = %@", (int)[error code], characteristic);
    
    if ([error code] == 0) {
        
        //_________________________________________________________________________________________________
        // 非订阅模式下的数据更新
        
        if (//_________________________________________________________________________________________________
            // SpO2 模块
            
            [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Switch]]
            || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Effective]]
            
            //_________________________________________________________________________________________________
            // NIBP 模块
            
            || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Send]]
            || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Receive]]
            
            ) {
            
            dispatch_semaphore_signal(read_value_semaphore);  // 发出信号
            
            if (self.ReadValueBlock) {
                self.ReadValueBlock(characteristic.value);
            }
        }
        
        //_________________________________________________________________________________________________
        // 设备电量
        
        else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_Device_Characteristics_Power]]) {
            
            [characteristic.value getBytes:&_devicePower length:sizeof(_devicePower)];
            NSLog(@"Device_BatteryLevel = %d",_devicePower);
            
            if (self.ConnectDeviceBlock) {
                self.ConnectDeviceBlock(true);
            }
        }
        
        //_________________________________________________________________________________________________
        // 订阅模式下产生的数据更新
        
        else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_SpO2]]) {
            [self.delegate updataNotifyValueForSpO2Data:characteristic.value];
        }
        
    }
}

// 向设备发送数据成功时回调, 判断是否写入成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
     
//     NSLog(@"[error code] = %d, characteristic_write = %@", (int)[error code], characteristic);
     
     if ([error code] == 0) {
         
         if (//_________________________________________________________________________________________________
             // SpO2 模块
             
             [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Switch]]
             || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_SpO2_Characteristics_Data_Count]]
             
             //_________________________________________________________________________________________________
             // NIBP 模块
             
             || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Send]]
             || [[characteristic UUID] isEqual:[CBUUID UUIDWithString:UUID_NIBP_Characteristics_Data_Receive]]
             
             ) {
             
             dispatch_semaphore_signal(write_value_semaphore);  // 发出信号
         }
         
     }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Send And Read Value Or Data
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 
 信号量是一个整形值并且具有一个初始计数值，并且支持两个操作：信号通知和等待。当一个信号量被信号通知，其计数会被增加。
 当一个线程在一个信号量上等待时，线程会被阻塞（如果有必要的话），直至计数器大于零，然后线程会减少这个计数。
 在GCD中有三个函数是semaphore的操作，分别是：
 dispatch_semaphore_create(int)　　　                          创建一个semaphore
 dispatch_semaphore_signal(semaphore)　　　                    发送一个信号
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)    等待信号, 可以设置延时
 简单的介绍一下这三个函数，dispatch_semaphore_create有一个整型的参数，可以理解为信号的总量;dispatch_semaphore_signal是发送一个信号，会让信号总量加1;
 dispatch_semaphore_wait等待信号，当信号总量少于0的时候就会一直等待，否则就可以正常的执行，并让信号总量-1.
 
 */

dispatch_semaphore_t read_value_semaphore;    // 读值信号
dispatch_semaphore_t write_value_semaphore;   // 写值信号

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic block:(ReadValueForCharacteristicBlock)block {
    
//    if ([self.myPeripheral isConnected] == true && characteristic != nil) {
    if ( self.myPeripheral.state == CBPeripheralStateConnected && characteristic != nil) {
    
        if (block) {
            self.ReadValueBlock = block;
        }
        
        read_value_semaphore = dispatch_semaphore_create(0);
        
        dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.myPeripheral readValueForCharacteristic:characteristic];
            
            dispatch_semaphore_wait(read_value_semaphore, DISPATCH_TIME_FOREVER);  // 等待信号
        });
    }
}

/// 从特征值通道反写入值, 使用线程等待方法
- (void)writeValueForCharacteristic:(CBCharacteristic *)characteristic value:(NSData *)value whetherWait:(Boolean)wait {
    
//    if ([self.myPeripheral isConnected] == true && characteristic != nil) {
    if (self.myPeripheral.state == CBPeripheralStateConnected && characteristic != nil) {
    
        if (wait) {
            write_value_semaphore = dispatch_semaphore_create(0);
            
            dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self.myPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                
                dispatch_semaphore_wait(write_value_semaphore, DISPATCH_TIME_FOREVER);  // 等待信号
            });
        }
        else {
            [self.myPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

@end
