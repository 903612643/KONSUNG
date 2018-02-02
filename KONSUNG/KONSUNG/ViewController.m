//
//  ViewController.m
//  KONSUNG
//
//  Created by 羊德元 on 15/6/1.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "BluetoothManager.h"
#import "DatabaseManager.h"

#import "DateSelectControl.h"
#import "DetectionDataDisplayControl.h"
#import "PlethDisplayView.h"
#import "AccountSettingViewController.h"
#import "DetectionDataEditViewController.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"
#import "AppDelegate.h"

static Boolean Get_Once_Valid_Data = false;  // 用于标记抓取的数据, 只取1次
static int     Control_Space       = 10;     // 控件之间的间隔
static int     Head_Icon_Size      = 80;     // 头像大小
static int     Chart_Height        = 200;    // 图表高度

@interface ViewController () <BluetoothManagerDelegate, DateSelectControlDelegate, DetectionDataEditDelegate,ASIHTTPRequestDelegate> {
    BluetoothManager *bluetooth;
    DatabaseManager  *database;
    
    UserObj *userObj;
    ASIFormDataRequest *asiRequest;
}

@property(nonatomic, strong) DateSelectControl *dateSelCtrl;

@property(nonatomic, strong) UIImageView *myIconView;
@property(nonatomic, strong) DetectionDataDisplayControl *mySpO2DataCtrl;
@property(nonatomic, strong) DetectionDataDisplayControl *myPrDataCtrl;
@property(nonatomic, strong) PlethDisplayView *plethView;

@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *deviceStateLabel;
@property(nonatomic, strong) UILabel *currentDateLabel;
@property(nonatomic, strong) UILabel *spo2HintLabel;
@property(nonatomic, strong) UILabel *prHintLabel;

@end

@implementation ViewController

- (id)initWithTitle:(NSString *)title color:(UIColor *)color {
    self = [super init];
    
    if (self) {
        
        UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        navTitleLabel.font = [UIFont systemFontOfSize:18];
        navTitleLabel.textColor = color;
        navTitleLabel.textAlignment = NSTextAlignmentCenter;
        navTitleLabel.adjustsFontSizeToFitWidth = true;
        
        navTitleLabel.text = title;
        navTitleLabel.backgroundColor=[UIColor clearColor];
        self.navigationItem.titleView = navTitleLabel;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = false;
    
    //_________________________________________________________________________________________________
    // 设置按钮  tt@qq.com
    
    UIButton *save_button = [UIButton buttonWithType:UIButtonTypeSystem];
    save_button.frame = CGRectMake(0, 0, 36, 36);
    [save_button setBackgroundImage:[UIImage imageNamed:@"setting@2x"] forState:UIControlStateNormal];
    [save_button addTarget:self action:@selector(appGlobalSettings) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:save_button];
    
    self.navigationItem.leftBarButtonItem = nil;
    
}

- (void)refreshView {
    
    //_________________________________________________________________________________________________
    // load name
    
    NSString *userName = @"NULL";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userAccount"] != nil) {
        userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userAccount"];
    }
    self.userNameLabel.text = userName;
    
    //_________________________________________________________________________________________________
    // load data
    
    //[self getAllTableForDatabase];
    [self readDataAndDisplay];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    bluetooth = [BluetoothManager sharedModel];
    database  = [DatabaseManager sharedModel];
    userObj   = [UserObj getUserObj];
    
    bluetooth.delegate = self;
    [(AppDelegate *)[UIApplication sharedApplication].delegate openUserDatabase];
    
    //_________________________________________________________________________________________________
    
    if (self.view.frame.size.height < 568) {  // 4S
        Control_Space  = 5;
        Head_Icon_Size = 75;
        Chart_Height   = 150;
    }
    else if ((int)self.view.frame.size.height < 667) {  // 5, 5S
        Control_Space  = 15;
        Head_Icon_Size = 85;
        Chart_Height   = 200;
    }
    else if (self.view.frame.size.height < 736) {  // 6
        Control_Space  = 20;
        Head_Icon_Size = 95;
        Chart_Height   = 240;
    }
    else {  // 6P
        Control_Space  = 30;
        Head_Icon_Size = 120;
        Chart_Height   = 300;
    }
    
    //_________________________________________________________________________________________________
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    background.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:background];
    
    UIColor *borderColor = [UIColor colorWithRed:0.39 green:0.67 blue:0.21 alpha:1];
    
    //_________________________________________________________________________________________________
    // 设备状态 label
    
    self.deviceStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 150, 24)];
    self.deviceStateLabel.font = [UIFont boldSystemFontOfSize:15];
    self.deviceStateLabel.textAlignment = NSTextAlignmentLeft;
    self.deviceStateLabel.adjustsFontSizeToFitWidth = true;
    
    self.deviceStateLabel.text = NSLocalizedString(@"unconnect",nil);
    [self.view addSubview:self.deviceStateLabel];
    
    //_________________________________________________________________________________________________
    // 用户 Icon
    
    self.myIconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - Head_Icon_Size) / 2,
                                                                          Control_Space,
                                                                          Head_Icon_Size,
                                                                          Head_Icon_Size)];
    self.myIconView.image = [UIImage imageNamed:@"53.png"];
    self.myIconView.layer.cornerRadius = Head_Icon_Size / 2;
    self.myIconView.layer.masksToBounds = true;
    self.myIconView.layer.borderWidth = 1;
    self.myIconView.layer.borderColor = borderColor.CGColor;
    [self.view addSubview:self.myIconView];
    
    
    //_________________________________________________________________________________________________
    // 日期选择控件
    
    self.dateSelCtrl = [[DateSelectControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, 40)
                                                      textColor:[UIColor blackColor]];
    self.dateSelCtrl.center = self.myIconView.center;
    self.dateSelCtrl.delegate = self;
    [self.view addSubview:self.dateSelCtrl];
    
    //_________________________________________________________________________________________________
    // 用户名
    
    float width = 5.0 * Head_Icon_Size / 4.0;
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - width) / 2,
                                                                   CGRectGetMaxY(self.myIconView.frame) + Control_Space / 2,
                                                                   width,
                                                                   20)];
    self.userNameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    self.userNameLabel.adjustsFontSizeToFitWidth = true;
    self.userNameLabel.textColor = borderColor;
    [self.view addSubview:self.userNameLabel];
    
    //_________________________________________________________________________________________________
    // SpO2 和 Pr 视图
    
    self.mySpO2DataCtrl = [[DetectionDataDisplayControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 4 - Head_Icon_Size / 2,
                                                                                        CGRectGetMaxY(self.userNameLabel.frame) + Control_Space,
                                                                                        Head_Icon_Size,
                                                                                        Head_Icon_Size)];
//    self.mySpO2DataCtrl.dataLabel.text = @"--";
    self.mySpO2DataCtrl.unitLabel.text = @"SpO2";
    [self.view addSubview:self.mySpO2DataCtrl];
    
    
    
    
    self.myPrDataCtrl = [[DetectionDataDisplayControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3 / 4 - Head_Icon_Size / 2,
                                                                                      self.mySpO2DataCtrl.frame.origin.y,
                                                                                      Head_Icon_Size,
                                                                                      Head_Icon_Size)];
   // self.myPrDataCtrl.dataLabel.text = @"--";
    self.myPrDataCtrl.unitLabel.text = @"Bpm";
    [self.view addSubview:self.myPrDataCtrl];
    
    
    UILabel *poo2Lab = [[UILabel alloc] initWithFrame:CGRectMake(self.mySpO2DataCtrl.frame.origin.x,
                                                                 self.mySpO2DataCtrl.frame.origin.y - 20,
                                                                 self.mySpO2DataCtrl.frame.size.width,
                                                                 20)];
    poo2Lab.text = @"SpO2";
    poo2Lab.font = [UIFont boldSystemFontOfSize:15];
    poo2Lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:poo2Lab];
    
    
    UILabel *bmpLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3 / 4 - Head_Icon_Size / 2,
                                                                self.myPrDataCtrl.frame.origin.y - 20,
                                                                self.myPrDataCtrl.frame.size.width,
                                                                20)];
    bmpLab.text = @"PR";
    bmpLab.font = [UIFont boldSystemFontOfSize:15];
    bmpLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bmpLab];
    
    //_________________________________________________________________________________________________
    // PlethDisplayView
    
    self.plethView = [[PlethDisplayView alloc] initWithFrame:CGRectMake(0,
                                                                        self.view.frame.size.height - Chart_Height - 135,
                                                                        self.view.frame.size.width,
                                                                        Chart_Height)];

    [self.view addSubview:self.plethView];
    
    //_________________________________________________________________________________________________
    // SpO2 和 Pr 提示标签
    
    self.spo2HintLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120) / 2,
                                                                   self.plethView.frame.origin.y - 5,
                                                                   120,
                                                                   20)];
    self.spo2HintLabel.font = [UIFont boldSystemFontOfSize:12];
    self.spo2HintLabel.textAlignment = NSTextAlignmentCenter;
    self.spo2HintLabel.adjustsFontSizeToFitWidth = true;
    self.spo2HintLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.spo2HintLabel];
    
    self.prHintLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120) / 2,
                                                                   CGRectGetMaxY(self.spo2HintLabel.frame),
                                                                   120,
                                                                   20)];
    self.prHintLabel.font = [UIFont boldSystemFontOfSize:12];
    self.prHintLabel.textAlignment = NSTextAlignmentCenter;
    self.prHintLabel.adjustsFontSizeToFitWidth = true;
    self.prHintLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.prHintLabel];
    
    self.spo2HintLabel.text = @"";
    self.prHintLabel.text   = @"";
    
    self.mySpO2DataCtrl.dataLabel.text = @"--";
    self.myPrDataCtrl.dataLabel.text   = @"--";
    
    //_________________________________________________________________________________________________
    // 当前数据日期 label
    
    self.currentDateLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 120) / 2,
                                                                      CGRectGetMaxY(self.plethView.frame),
                                                                      120,
                                                                      20)];
    self.currentDateLabel.font = [UIFont boldSystemFontOfSize:15];
    self.currentDateLabel.textAlignment = NSTextAlignmentCenter;
    self.currentDateLabel.adjustsFontSizeToFitWidth = true;
    self.currentDateLabel.text = @"NO DATE";
    [self.view addSubview:self.currentDateLabel];
    
    //_________________________________________________________________________________________________
    // 下载数据按钮
    
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    downloadButton.frame = CGRectMake(self.view.frame.size.width / 4 - 120 / 2,
                                  CGRectGetMaxY(self.plethView.frame) + 25,
                                  120,
                                  30);
    downloadButton.backgroundColor = borderColor;
    downloadButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [downloadButton setTitle:NSLocalizedString(@"download_data",nil) forState:UIControlStateNormal];
    [downloadButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downloadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    downloadButton.layer.cornerRadius = 5;
    downloadButton.layer.masksToBounds = true;
    
    [downloadButton addTarget:self action:@selector(downloadServersData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadButton];
    
    //_________________________________________________________________________________________________
    // 编辑数据按钮
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.frame = CGRectMake(self.view.frame.size.width * 3 / 4 - 120 /  2,
                                  CGRectGetMaxY(self.plethView.frame) + 25,
                                  120,
                                  30);
    editButton.backgroundColor = borderColor;
    editButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [editButton setTitle:NSLocalizedString(@"edit_data",nil) forState:UIControlStateNormal];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    editButton.layer.cornerRadius = 5;
    editButton.layer.masksToBounds = true;
    
    [editButton addTarget:self action:@selector(editMyDetectionData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    //_________________________________________________________________________________________________
    // load data
    
    [self refreshView];
    
    //[self readDataAndDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appGlobalSettings {
    AccountSettingViewController *viewCtrl = [[AccountSettingViewController alloc] initWithTitle:NSLocalizedString(@"Account_Setting",nil) color:UIColor.whiteColor];
    [self.navigationController pushViewController:viewCtrl animated:true];
}

- (void)editMyDetectionData {
    DetectionDataEditViewController *viewCtrl = [[DetectionDataEditViewController alloc] initWithTitle:NSLocalizedString(@"Edit_Detection_Data",nil) color:UIColor.whiteColor];
    viewCtrl.delegate = self;
    [self.navigationController pushViewController:viewCtrl animated:true];
    
    NSMutableArray *dataArray = [database getSpO2DataForOneDayWithTableName:[self.dateSelCtrl getCurrentTableName]];
    [viewCtrl initDataSource:[DatabaseManager getInversionArray:dataArray]];
}


- (void)downloadServersData {
    [self getHTTPRequest1];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark BluetoothManagerDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)centralManagerStatePoweredOn {
    
    Get_Once_Valid_Data = false;
    
    [bluetooth scanAndConnectPeripheral:KONSUNG_Device_UUID block:^{
        
        self.deviceStateLabel.text = NSLocalizedString(@"connect",nil);
        
       // [SVProgressHUD showSuccessWithStatus:@"连接成功!"];
        
        uint8_t value = 1;
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [bluetooth writeValueForCharacteristic:bluetooth.characteristicSpO2DataSwitch
                                             value:[NSData dataWithBytes:&value length:sizeof(value)]
                                       whetherWait:true];
        });
        
    }];
}

- (void)disconnectPeripheral {
    Get_Once_Valid_Data = false;
    self.deviceStateLabel.text = NSLocalizedString(@"unconnect",nil);
}

- (void)updataNotifyValueForSpO2Data:(NSData *)data {
    
    NSLog(@"dicSpO2Value = %@", [DeviceSyncData analysisDeviceSpO2ValueForDic:data]);
    DeviceSpO2Value spo2 = [DeviceSyncData analysisDeviceSpO2ValueForStruct:data];
    
    //______________________________________________________________________________________________________
    // 成功获取数据处理，只取第一笔有效数据
    
    if (
        Get_Once_Valid_Data == false
        && (spo2.SpO2 > 0 && spo2.SpO2 <= 100)
        && (spo2.Pr > 0 && spo2.Pr <= 250)
        ) {
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"get_data_success",nil)];
        NSLog(@"成功获取数据 = %@", [DeviceSyncData analysisDeviceSpO2ValueForDic:data]);
        
        Get_Once_Valid_Data = true;
        
        if (spo2.SpO2 >= 90 && spo2.SpO2 <= 100) {
            self.spo2HintLabel.text = NSLocalizedString(@"spo2_normal",nil);
        }
        else {
            self.spo2HintLabel.text = NSLocalizedString(@"spo2_abnormal",nil);
        }
        
        if (spo2.Pr >= 50 && spo2.Pr <= 100) {
            self.prHintLabel.text = NSLocalizedString(@"pr_normal",nil);
        }
        else {
            self.prHintLabel.text = NSLocalizedString(@"pr_abnormal",nil);
        }
        
        self.mySpO2DataCtrl.dataLabel.text = [NSString stringWithFormat:@"%d", spo2.SpO2];
        self.myPrDataCtrl.dataLabel.text   = [NSString stringWithFormat:@"%d", spo2.Pr];
        
        //______________________________________________________________________________________________________
        // 将获取的第一个正确数据写入数据库中
        
        int current_utc = [[NSDate date] timeIntervalSince1970];
        
        [database addDataToTable:spo2 currentUTC:current_utc deviceName:bluetooth.myPeripheral.name];
        [self getAllTableForDatabase];
        [self readDataAndDisplay];
        
        //______________________________________________________________________________________________________
        // 将获取的数据上传至服务器
        
        [self uploadDataToServers:spo2
                             date:@""/*[DeviceSyncData utcToDateString:current_utc dateFormat:@"yyyy_MM_dd HH:mm:ss"]*/
                       deviceName:bluetooth.myPeripheral.name];
    }
    
//    [self.plethView setPlethData:spo2.Pleth];
    
    //______________________________________________________________________________________________________
    // 反馈计数统计
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [bluetooth writeValueForCharacteristic:bluetooth.characteristicSpO2DataCount
                                         value:[NSData dataWithBytes:&spo2.Counter length:sizeof(spo2.Counter)]
                                   whetherWait:false];
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark DateSelectControlDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)changeCurrentDate {
    
//    self.mySpO2DataCtrl.dataLabel.text = @"——";
//    self.myPrDataCtrl.dataLabel.text   = @"——";
    self.spo2HintLabel.text = @"";
    self.prHintLabel.text   = @"";
    
    [self readDataAndDisplay];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark DetectionDataEditDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// 更改数据时回调
- (void)changeDataWithUTC:(int)utc spo2:(NSString *)spo2 pr:(NSString *)pr devName:(NSString *)devName {
    
    // 添加与服务器关联的操作
    // ......
    // ......
    
    [self readDataAndDisplay];  // 刷新视图
}

// 删除数据时回调
- (void)deleteDataWithUTC:(int)utc spo2:(NSString *)spo2 pr:(NSString *)pr devName:(NSString *)devName {
    
    // 添加与服务器关联的操作
    // ......
    // ......
//    1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
    NSString *strUtc = [DeviceSyncData utcToDateString:utc dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self getHTTPRequestDelete:spo2 :pr :devName :strUtc];
    
    [self readDataAndDisplay];  // 刷新视图
    
    self.mySpO2DataCtrl.dataLabel.text = @"——";
    self.myPrDataCtrl.dataLabel.text   = @"——";
    self.spo2HintLabel.text = @"";
    self.prHintLabel.text   = @"";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Read Database Data
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAllTableForDatabase {
    //______________________________________________________________________________________________________
    // 获取数据表
    
    NSArray *tableArray = [database getAllTableNameWithDataForDatabase];
    NSLog(@"getAllTableNameWithDataForDatabase = %@", tableArray);
    
    [self.dateSelCtrl setSelectDateArray:tableArray];
}

// 读取新的数据并在图表中展示
- (void)readDataAndDisplay {
    
    [self.plethView refreshThisView];
    
    //______________________________________________________________________________________________________
    // 获取数据
    
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
    NSDictionary *dict1=@{@"checkdate":@"2015-06-16 16:09:32",
                          @"devicetype":@"CONSUNG M6100",
                          @"id":@"4",
                          @"prdata":@"75.00000",
                          @"spo2data":@"99.00000"
                          };
    
    NSDictionary *dict2=@{@"checkdate":@"2015-06-16 16:08:27",
                          @"devicetype":@"CONSUNG M6100",
                          @"id":@"3",
                          @"prdata":@"71.00000",
                          @"spo2data":@"90.00000"
                          };
    
    
    NSArray *dataArray = [database getSpO2DataForOneDayWithTableName:[self.dateSelCtrl getCurrentTableName]];
    
   // NSArray *dataArray=[[NSArray array] initWithObjects:dict1,dict2, nil];
    
    NSLog(@"dict1=%@",dataArray);
    
    self.currentDateLabel.text = self.dateSelCtrl.currentDataStr;
//    NSLog(@"getSpO2DataForOneDay = %@", dataArray);
    
    //dataArray = [self getRightDataArray:dataArray];  // 选取正确数据
    
    int data_count = (int)dataArray.count;
    
    if (data_count == 0) {
//        self.mySpO2DataCtrl.dataLabel.text = @"——";
//        self.myPrDataCtrl.dataLabel.text = @"——";
      return;
    }
    else if (data_count > 10) {
        data_count = 10;
    }
    
    NSMutableArray *spo2DataArray = [[NSMutableArray alloc] init];
    NSMutableArray *prDataArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < data_count; i++) {
        [spo2DataArray addObject:[dataArray[i] objectForKey:KEY_DATA_SPO2]];
        [prDataArray addObject:[dataArray[i] objectForKey:KEY_DATA_PR]];
    }
    
//    self.mySpO2DataCtrl.dataLabel.text = [NSString stringWithFormat:@"%@", spo2DataArray[0]];
//    self.myPrDataCtrl.dataLabel.text   = [NSString stringWithFormat:@"%@", prDataArray[0]];
    
    [self.plethView setSpO2_PR_DataArray:@[[DatabaseManager getInversionArray:spo2DataArray],
                                           [DatabaseManager getInversionArray:prDataArray]
                                           ]];
    
//    [self.plethView setSpO2_PR_DataArray:@[[DatabaseManager getInversionArray:@[@"95",@"78"]],
//                                           [DatabaseManager getInversionArray:@[@"90",@"71"]]
//                                           ]];
   
    
    
}

- (NSArray *)getRightDataArray:(NSArray *)dataArray {
    
    NSMutableArray *rightArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in dataArray) {
        int cur_spo2 = [[dic objectForKey:KEY_DATA_SPO2] intValue];
        int cur_pr   = [[dic objectForKey:KEY_DATA_PR] intValue];
        
        if (cur_spo2 < Data_Min_SpO2
            || cur_spo2 > Data_Max_SpO2
            || cur_pr < Data_Min_Pr
            || cur_pr > Data_Max_Pr
            ) {
        }
        else {
            [rightArray addObject:dic];
        }
    }
    
    return rightArray;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Upload And Download Data
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  将获取的数据上传至服务器
 *
 *  @param spo2    DeviceSpO2Value 结构的数据
 *  @param date    日期字符串 yyyy_MM_dd HH:mm:ss
 *  @param devName 设备名
 */
- (void)uploadDataToServers:(DeviceSpO2Value)spo2 date:(NSString*)date deviceName:(NSString *)devName {
    //上传数据。 1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
    [self getHTTPRequest:[NSString stringWithFormat:@"%d", spo2.SpO2]
                        :[NSString stringWithFormat:@"%d", spo2.Pr]
                        :devName];
}

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

-(void)addDataTotable
{
   DeviceSpO2Value spo2;
}

- (void)setDownloadDataToDatabase:(NSArray *)dataArray count:(int)count {
    
    NSLog(@"setDownloadDataToDatabase___count = %d, array = %@", count, dataArray);
    [SVProgressHUD showWithStatus:NSLocalizedString(@"data_updating",nil)];
    
    //______________________________________________________________________________________________________
    // 删除本地所有数据表
    
    [database deleteAllTableDataForDatabase];
    
    //______________________________________________________________________________________________________
    // 将获取的数据插入数据库
    
    DeviceSpO2Value spo2;
    
    for (int i = 0; i < count; i++) {
        
        NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:dataArray[i]];
        
        spo2.SpO2 = [[dataDic objectForKey:@"spo2data"] intValue];
        spo2.Pr = [[dataDic objectForKey:@"prdata"] intValue];
        
        // 将 2015-10-25 格式的字符串替换为 2015_10_25，避免数据库异常
        NSString *date = [NSString stringWithFormat:@"%@", [dataDic objectForKey:@"checkdate"]];
//        date = [date stringByReplacingOccurrencesOfString:@"-"
//                                               withString:@"_"];
        
        int utc = [DeviceSyncData dateFormatToUTC:date dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *devName = [NSString stringWithFormat:@"%@", [dataDic objectForKey:@"devicetype"]];
        
        [database addDataToTable:spo2 currentUTC:utc deviceName:devName];
    }
    
    //______________________________________________________________________________________________________
    
//    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"",nil)];
    [SVProgressHUD dismiss];
    [self getAllTableForDatabase];
    
    [self readDataAndDisplay];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Servers HTTPRequest
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//成功  HTTP接收数据。
- (void)requestFinished:(ASIHTTPRequest *)request
{
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
        
        NSString *requestString = [LshGo getReq:[request responseString]];
        NSDictionary *dict = [requestString JSONValue];
        
        NSString *strMasg = [dict objectForKey:@"errcode"];
        
        if (request.tag == 1 && [strMasg isEqualToString:@"000"]) {//上传成功
            // 上传一次测试的数据  这里不需要处理。
            NSLog(@"数据上传成功!");
        }else if (request.tag == 2 && [strMasg isEqualToString:@"000"]) {
            // 如果有数据。在这里先要把数据库测试数据。全清空。在插入取到的数据。、、、、、、、、、、、//这里有个处理。
            
            int count  = [[dict objectForKey:@"count"] intValue];
            NSArray *dataArray = [dict objectForKey:@"sellrec"];
            
            if (count > 0) {
                [self setDownloadDataToDatabase:dataArray count:count];
            }
            
            [self Alert:[dict objectForKey:@"errmsg"]];
            
        }else if (request.tag == 3 && [strMasg isEqualToString:@"000"]) {
            // 删除数据。、、、、、、、、、、、//这里有个处理。
            NSLog(@"数据删除成功!");
        } else {
            NSString *strErrMsg = [dict objectForKey:@"errmsg"];
            [self Alert:strErrMsg];//上传失败
        }
        
        
    }@catch (NSException * e) {
        [self Alert:NSLocalizedString(@"network_is_error",nil)];
    }
    @finally {
        
    }
}

////失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
//    [self Alert:@"注册失败！"];
}

//上传数据。 1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
-(void)getHTTPRequest:(NSString *)strSpO2data :(NSString *)strPRdata :(NSString *)strdevicename{
    
    NSDate *datenow = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    NSString *strcheckdateTime =  [formater stringFromDate:datenow];
    
//    "SpO2data":"56.6",
//    "PRdata":"56.6",
//    "checkdate":"2015-05-12 11:22:33",
//    "devicename":"检测设备名称",
//    "uid":"123",
    
//    NSString *strSpO2data = @"";
//    NSString *strPRdata = @"";
    NSString *strcheckdate = strcheckdateTime;
//    NSString *strdevicename = @"";
    NSString *struid = [userObj.user objectForKey:@"uid"];
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"command\":\"1007\",\"errcode\":\"000\",\"timestamp\":%ld,\"SpO2data\":\"%@\",\"PRdata\":\"%@\",\"checkdate\":\"%@\",\"devicename\":\"%@\",\"uid\":\"%@\",\"op\":\"1\"}abx23579436",[LshGo getTimestamp:datenow],strSpO2data,strPRdata,strcheckdate,strdevicename,struid];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 =  [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"command\":\"1007\",\"errcode\":\"000\",\"timestamp\":%ld,\"SpO2data\":\"%@\",\"PRdata\":\"%@\",\"checkdate\":\"%@\",\"devicename\":\"%@\",\"uid\":\"%@\",\"op\":\"1\"}", strpackmd5, [LshGo getTimestamp:datenow],strSpO2data,strPRdata,strcheckdate,strdevicename,struid];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 1;
    
    NSLog(@"strJson = %@", strJson);
    NSLog(@"strJson1 = %@", strJson1);
    
    [asiRequest startAsynchronous];
}


//删除数据。 1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
-(void)getHTTPRequestDelete:(NSString *)strSpO2data :(NSString *)strPRdata :(NSString *)strdevicename :(NSString *)strcheckdateTime{
    
    NSDate *datenow = [NSDate date];
//    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
//    NSString *strcheckdateTime =  [formater stringFromDate:datenow];
    
    //    "SpO2data":"56.6",
    //    "PRdata":"56.6",
    //    "checkdate":"2015-05-12 11:22:33",
    //    "devicename":"检测设备名称",
    //    "uid":"123",
    
    //    NSString *strSpO2data = @"";
    //    NSString *strPRdata = @"";
    NSString *strcheckdate = strcheckdateTime;
    //    NSString *strdevicename = @"";
    NSString *struid = [userObj.user objectForKey:@"uid"];
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"command\":\"1007\",\"errcode\":\"000\",\"timestamp\":%ld,\"SpO2data\":\"%@\",\"PRdata\":\"%@\",\"checkdate\":\"%@\",\"devicename\":\"%@\",\"uid\":\"%@\",\"op\":\"0\"}abx23579436",[LshGo getTimestamp:datenow],strSpO2data,strPRdata,strcheckdate,strdevicename,struid];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 =  [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"command\":\"1007\",\"errcode\":\"000\",\"timestamp\":%ld,\"SpO2data\":\"%@\",\"PRdata\":\"%@\",\"checkdate\":\"%@\",\"devicename\":\"%@\",\"uid\":\"%@\",\"op\":\"0\"}", strpackmd5, [LshGo getTimestamp:datenow],strSpO2data,strPRdata,strcheckdate,strdevicename,struid];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 3;
    
    NSLog(@"strJson = %@", strJson);
    NSLog(@"strJson1 = %@", strJson1);
    
    [asiRequest startAsynchronous];
}



//下载同步数据。
-(void)getHTTPRequest1{
    
    NSDate *datenow = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    NSString *strendtimeL =  [formater stringFromDate:datenow];
    
    NSArray *arrtime = [strendtimeL componentsSeparatedByString:@" "];
    NSArray *arrtime1 = [arrtime[0] componentsSeparatedByString:@"-"];
    
    NSString *strYesL = arrtime1[0];
    
    NSString *strMol = arrtime1[1];//月份
    NSInteger int67 = [strMol intValue];
    if (int67 == 1) {
        strYesL = [NSString stringWithFormat:@"%d",(int)([strYesL intValue]-1)];
        strMol = @"12";
    }else{
        int intL = (int)int67-1;
        if (intL < 10) {
            strMol = [NSString stringWithFormat:@"0%d",intL];
        }else{
            strMol = [NSString stringWithFormat:@"%d",intL];
        }
    }
    
    NSString *strDayl = arrtime1[2];//日
    NSInteger int910 = [strDayl intValue];
    if (int910 >= 28) {
        strDayl = @"28";
    }
    
    NSString *struid = [userObj.user objectForKey:@"uid"];;
    NSString *strstarttime = [NSString stringWithFormat:@"%@-%@-%@ %@",strYesL,strMol,strDayl,arrtime[1]];
    NSString *strendtime = strendtimeL;
    
    NSString *strJson = [[NSString alloc] initWithFormat:@"{\"ver\":\"1.0\",\"command\":\"1009\",\"errcode\":\"000\",\"timestamp\":%ld,\"querytype\":\"1\",\"sort\":\"1\",\"uid\":\"%@\",\"starttime\":\"%@\",\"endtime\":\"%@\"}abx23579436",[LshGo getTimestamp:datenow],struid,strstarttime,strendtime];
    NSString *strpackmd5 = [LshGo md5:strJson];
    
    NSString *strJson1 = [[NSString alloc] initWithFormat:@"{\"packmd5\":\"%@\",\"ver\":\"1.0\",\"command\":\"1009\",\"errcode\":\"000\",\"timestamp\":%ld,\"querytype\":\"1\",\"sort\":\"1\",\"uid\":\"%@\",\"starttime\":\"%@\",\"endtime\":\"%@\"}", strpackmd5, [LshGo getTimestamp:datenow],struid,strstarttime,strendtime];
    
    strJson1 = [NSString stringWithFormat:@"%@%@",STR_URL_IP, strJson1];
    NSString *strURL = [strJson1 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    asiRequest.delegate = self;
    asiRequest.tag = 2;
    
    [asiRequest startAsynchronous];
}


-(void)Alert:(NSString *)strMag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system_hint",nil)
                                                    message:strMag
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"confirm",nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}



@end
