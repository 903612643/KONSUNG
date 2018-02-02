//
//  DetectionDataEditViewController.m
//  KONSUNG
//
//  Created by 羊德元 on 15/6/6.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "DetectionDataEditViewController.h"
#import "DatabaseManager.h"
#import "UIActionSheetPickerView.h"

#import "UserObj.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "LshGo.h"

static Boolean Can_Edit_Data = false;

@interface DetectionDataEditViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetPickerViewDelegate, ASIHTTPRequestDelegate> {
    DatabaseManager  *database;
    
    UserObj *userObj;
    ASIFormDataRequest *asiRequest;
}

@property(nonatomic, strong) UITableView    *tableView;
@property(nonatomic, strong) NSMutableArray *dataItems;

@end

@implementation DetectionDataEditViewController

- (id)initWithTitle:(NSString *)title color:(UIColor *)color {
    
    self = [super init];
    
    if (self) {
        UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        navTitleLabel.font = [UIFont systemFontOfSize:18];
        navTitleLabel.textColor = color;
        navTitleLabel.textAlignment = NSTextAlignmentCenter;
        navTitleLabel.adjustsFontSizeToFitWidth = true;
        
        navTitleLabel.text = title;
        self.navigationItem.titleView = navTitleLabel;
    }
    
    return self;
}

- (void)refreshThisView {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = false;
    
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;  // 在右侧添加编辑按钮
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userObj = [UserObj getUserObj];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    
    database = [DatabaseManager sharedModel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.scrollEnabled  = true;
    [self.view addSubview:self.tableView];
    
    
    // 编辑数据按钮
//    
//    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    editButton.frame = CGRectMake(60,
//                                  self.view.frame.size.height-114+10,
//                                  self.view.frame.size.width-120,
//                                  30);
//    editButton.backgroundColor = [UIColor orangeColor];
//    editButton.titleLabel.adjustsFontSizeToFitWidth = true;
//    [editButton setTitle:@"同步检测数据" forState:UIControlStateNormal];
//    [editButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
//    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    
//    editButton.layer.cornerRadius = 5;
//    editButton.layer.masksToBounds = true;
//    
//    [editButton addTarget:self action:@selector(editMyDetectionData) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:editButton];
    
}

//-(void)editMyDetectionData{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请确认是否同步数据！" delegate:self cancelButtonTitle:@"取  消" otherButtonTitles:@"确  定", nil];
//    [alert show];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    if (buttonIndex == 1)
//    {
//        ////处理删除操作
//        [self getHTTPRequest1];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init Table Data
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)initDataSource:(NSArray *)data {
    self.dataItems = [[NSMutableArray alloc] initWithArray:data];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    Can_Edit_Data = true;
    
    // 如果数据不是当天的, 则不显示编辑按钮
    if (self.dataItems.count > 0) {
        
        NSString *mydate  = [NSString stringWithFormat:@"%@", [self.dataItems[0] objectForKey:KEY_DATA_DATE]];
        NSString *curDate = [DeviceSyncData utcToDateString:[[NSDate date] timeIntervalSince1970] dateFormat:@"yyyy_MM_dd"];
        
        if ([mydate rangeOfString:curDate].location == NSNotFound) {
//            self.navigationItem.rightBarButtonItem = nil;
            Can_Edit_Data = false;
        }
    }
    else {
//        self.navigationItem.rightBarButtonItem = nil;
        Can_Edit_Data = false;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table View Data Source Methods
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 一共有多少组数据
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/// 每组有多少行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataItems.count;
}

/// 返回 cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

/// 生成所有的 table cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = true;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    //______________________________________________________________________________________________________
    
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 190, 20)];
    dataLabel.adjustsFontSizeToFitWidth = true;
    dataLabel.font = [UIFont systemFontOfSize:16];
    dataLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:dataLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 190, 15)];
    timeLabel.adjustsFontSizeToFitWidth = true;
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:timeLabel];
    
    //______________________________________________________________________________________________________
    
    int spo2 = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_SPO2] intValue];
    int pr   = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_PR] intValue];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedString(@"data",nil), (int)indexPath.row + 1];
    timeLabel.text = [NSString stringWithFormat:@"%@", [self.dataItems[indexPath.row] objectForKey:KEY_DATA_DATE]];
    dataLabel.text = [NSString stringWithFormat:@"SPO2: %02d%%, PR: %dpm", spo2, pr];
    
    return cell;
}

/// 选中 cell 的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    // 载入界面, 可对 SpO2 和 Pr 的数值进行编辑
    
    Can_Edit_Data = false;  // 2015-07-18, 暂时关闭编辑功能, 因为服务器未提供编辑后替换数据的上传接口
    
    if (Can_Edit_Data) {
        UIActionSheetPickerView *picker = [[UIActionSheetPickerView alloc] initWithFrame:self.view.frame];
        [picker setPickerTitle:[NSString stringWithFormat:@"%@%d", NSLocalizedString(@"data",nil), (int)indexPath.row + 1]];
        picker.delegate = self;
        picker.tag = indexPath.row;
        
        NSMutableArray *spo2Array = [[NSMutableArray alloc] init];
        NSMutableArray *prArray   = [[NSMutableArray alloc] init];
        
        for (int i = 50; i <= 100; i++) {
            [spo2Array addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        for (int i = 50; i <= 150; i++) {
            [prArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        int spo2 = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_SPO2] intValue];
        int pr   = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_PR] intValue];
        
        [picker setTitlesForComponenets:[NSArray arrayWithObjects:
                                         [NSArray arrayWithObjects:@"SpO2", nil],
                                         [NSArray arrayWithArray:spo2Array],
                                         [NSArray arrayWithObjects:@"PR", nil],
                                         [NSArray arrayWithArray:prArray],
                                         nil]];
        
        [picker mySelectRow:spo2 - 50 inComponent:1 animated:YES];
        [picker mySelectRow:pr - 50 inComponent:3 animated:YES];
        [picker showInView:self.view];
    }
}

// 删除 cell 操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        int utc = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_UTC] intValue];
        int spo2 = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_SPO2] intValue];
        int pr   = [[self.dataItems[indexPath.row] objectForKey:KEY_DATA_PR] intValue];
        NSString *devName = [NSString stringWithFormat:@"%@", [self.dataItems[indexPath.row] objectForKey:KEY_DATA_DEVICE]];
        
        //______________________________________________________________________________________________________
        // 删除数据库中对应的数据
        
        [database deleteDataToTableWithUTC:utc];
        
        //______________________________________________________________________________________________________
        // 通知代理
        
        [self.delegate deleteDataWithUTC:utc
                                    spo2:[NSString stringWithFormat:@"%d", spo2]
                                      pr:[NSString stringWithFormat:@"%d", pr]
                                 devName:devName];
        
        //______________________________________________________________________________________________________
        // 移除数据源 和 tableView 中的数据
        
        [self.dataItems removeObjectAtIndex:indexPath.row];
//        [self.tableView reloadData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIActionSheetPickerViewDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// 编辑 cell 数据操作
- (void)actionSheetViewDelegate:(UIActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles {
    
//    NSLog(@"titles = %@", titles);
    
    int utc  = [[self.dataItems[pickerView.tag] objectForKey:KEY_DATA_UTC] intValue];
    int spo2 = [[self.dataItems[pickerView.tag] objectForKey:KEY_DATA_SPO2] intValue];
    int pr   = [[self.dataItems[pickerView.tag] objectForKey:KEY_DATA_PR] intValue];
    NSString *devName = [NSString stringWithFormat:@"%@", [self.dataItems[pickerView.tag] objectForKey:KEY_DATA_DEVICE]];
    
    //______________________________________________________________________________________________________
    // 更新数据库
    [database updateDataToTableWithUTC:utc spo2:[titles[1] intValue] pr:[titles[3] intValue]];
    
    //______________________________________________________________________________________________________
    // 通知代理
    
    [self.delegate changeDataWithUTC:utc
                                spo2:[NSString stringWithFormat:@"%d", spo2]
                                  pr:[NSString stringWithFormat:@"%d", pr]
                             devName:devName];
    
    //______________________________________________________________________________________________________
    // 更新数据源
    
    [self.dataItems[pickerView.tag] setObject:[NSNumber numberWithInt:[titles[1] intValue]] forKey:KEY_DATA_SPO2];
    [self.dataItems[pickerView.tag] setObject:[NSNumber numberWithInt:[titles[3] intValue]] forKey:KEY_DATA_PR];
    [self.tableView reloadData];
}


// 删除数据时回调
- (void)deletesDataWithUTC:(int)utc spo2:(NSString *)spo2 pr:(NSString *)pr devName:(NSString *)devName {
    
    // 添加与服务器关联的操作
    // ......
    // ......
    //    1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
    NSString *strUtc = [DeviceSyncData utcToDateString:utc dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self getsHTTPRequestDelete:spo2 :pr :devName :strUtc];
}

//删除数据。 1 SpO2data":"56.6"  2 PRdata":"56.6"  3 "devicename":"检测设备名称",
-(void)getsHTTPRequestDelete:(NSString *)strSpO2data :(NSString *)strPRdata :(NSString *)strdevicename :(NSString *)strcheckdateTime{
    
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
    
    [asiRequest startAsynchronous];
}


//成功  HTTP接收数据。
- (void)requestFinisheds:(ASIHTTPRequest *)request
{
    @try
    {
        NSLog(@"服务器返回 %@",[request responseString]);
//        
//        NSString *requestString = [LshGo getReq:[request responseString]];
//        NSDictionary *dict = [requestString JSONValue];
//        
//        NSString *strMasg = [dict objectForKey:@"errcode"];
//        if (request.tag == 3 && [strMasg isEqualToString:@"000"]) {
            // 删除数据。、、、、、、、、、、、//这里有个处理。
            NSLog(@"数据删除成功!");
         
//        }
    }@catch (NSException * e) {
        [self Alert:NSLocalizedString(@"network_is_error",nil)];
    }
    @finally {
        
    }
}

////失败
- (void)requestFaileds:(ASIHTTPRequest *)request
{
//    [self Alert:@"注册失败！"];
}



-(void)Alert:(NSString *)strMag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system_hint",nil)
                                                    message:strMag
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"confirm",nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}
 
//*/

@end
