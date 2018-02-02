//
//  DateSelectControl.h
//  GEEZBAND
//
//  Created by Foogeez on 14/11/14.
//  Copyright (c) 2014年 Foogeez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateSelectControlDelegate <NSObject>

-(void)changeCurrentDate;

@end

@interface DateSelectControl : UIView

@property(nonatomic, strong) id<DateSelectControlDelegate>delegate;
@property(nonatomic, strong) NSString * currentDataStr;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor;

- (void)setSelectDateArray:(NSArray *)dateArray;
- (NSString *)getCurrentTableName;

@end
