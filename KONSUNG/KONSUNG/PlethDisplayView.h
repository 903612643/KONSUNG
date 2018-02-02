//
//  PlethDisplayView.h
//  KONSUNG
//
//  Created by Foogeez on 15/6/3.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import <UIKit/UIKit.h>

//______________________________________________________________________________________________________

static float const Data_Label_Width     = 20;
static float const Data_Label_Height    = 16;

static float const Data_Standard_SpO2   = 90;
static float const Data_Min_SpO2        = 50;
static float const Data_Max_SpO2        = 100;

static float const Data_Standard_Pr     = 70;
static float const Data_Min_Pr          = 50;
static float const Data_Max_Pr          = 150;

static float const Data_Offset_Space    = 40;  // SpO2 和 PR 之间的间距
static float const Data_Refresh_Speed   = 240;

static int         Max_Line_Count       = 10;  // 总共 10 次测量

//______________________________________________________________________________________________________

@interface PlethDisplayView : UIView

- (void)setPlethData:(int)data;
- (void)setSpO2_PR_DataArray:(NSArray *)dataArray;
- (NSArray *)getRightData:(NSArray *)dataArray;

- (void)refreshThisView;

@end
