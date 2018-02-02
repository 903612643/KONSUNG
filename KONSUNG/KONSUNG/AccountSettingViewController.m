//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/8/25.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "AccountSettingViewController.h"
#import "ModifyPasswordViewController.h"
#import "AboutInfoViewController.h"
#import "UserObj.h"

#import "UserLoginViewController.h"

@interface AccountSettingViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
{
    UserObj *userObj;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray     *dataItems;

@end

@implementation AccountSettingViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userObj = [UserObj getUserObj];
    // Do any additional setup after loading the view.
    
    [self initDataSource];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.scrollEnabled  = true;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init Table Data
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)initDataSource {
    self.dataItems = @[NSLocalizedString(@"Modify_Password", nil),
                       NSLocalizedString(@"About_Konsung", nil),
                       NSLocalizedString(@"logout", nil),
                       ];
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

/// 生成所有的 table cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;  // 向右的小箭头
    
    NSString *cell_title  = [NSString stringWithFormat:@"%@", self.dataItems[indexPath.row]];
    
    cell.textLabel.text = cell_title;
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    return cell;
}

/// 选中 cell 的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cell_title  = cell.textLabel.text;
    
    if ([cell_title isEqualToString:NSLocalizedString(@"Modify_Password",nil)]) {
        ModifyPasswordViewController *viewCtrl = [[ModifyPasswordViewController alloc] initWithTitle:NSLocalizedString(@"Modify_Password",nil) color:[UIColor blackColor]];
        [self.navigationController pushViewController:viewCtrl animated:true];
    }
    else if ([cell_title isEqualToString:NSLocalizedString(@"About_Konsung",nil)]) {
        AboutInfoViewController *viewCtrl = [[AboutInfoViewController alloc] initWithTitle:NSLocalizedString(@"About_Konsung",nil) color:[UIColor blackColor]];
        [self.navigationController pushViewController:viewCtrl animated:true];
    }
    else if ([cell_title isEqualToString:NSLocalizedString(@"logout",nil)]) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_account",nil)
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel",nil)
                                              otherButtonTitles:NSLocalizedString(@"confirm",nil), nil];
        [alert show];
        
        
        // 注销当前帐号
        // ......
        // ......
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1)
    {
        ////处理删除操作
        userObj.user = nil;
        userObj.strUserName = nil;
        
        UserLoginViewController *viewCtrl = [[UserLoginViewController alloc] initWithTitle:NSLocalizedString(@"Login",nil) color:UIColor.whiteColor];
        [self.navigationController pushViewController:viewCtrl animated:true];
    }
}



@end
