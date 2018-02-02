//
//  DetectionDataEditViewController.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/6.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetectionDataEditDelegate <NSObject>

/**
 *  当数据发生删除/修改时进行通知
 */

- (void)changeDataWithUTC:(int)utc spo2:(NSString *)spo2 pr:(NSString *)pr devName:(NSString *)devName;

- (void)deleteDataWithUTC:(int)utc spo2:(NSString *)spo2 pr:(NSString *)pr devName:(NSString *)devName;

@end

@interface DetectionDataEditViewController : UIViewController

@property(nonatomic, strong) id<DetectionDataEditDelegate>delegate;

- (id)initWithTitle:(NSString *)title color:(UIColor *)color;
- (void)refreshThisView;

- (void)initDataSource:(NSArray *)data;

@end
