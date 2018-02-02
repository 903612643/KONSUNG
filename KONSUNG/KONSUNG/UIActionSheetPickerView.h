//
//  UIActionSheetPickerView.h
//  Wasp
//
//  Created by Foogeez on 14-10-20.
//  Copyright (c) 2014年 Foogeez. All rights reserved.
//
//  使用 UIView 重写 ActionSheet 的功能

#import <UIKit/UIKit.h>

typedef enum UIActionSheetPickerStyle {
    UIActionSheetPickerStyleTextPicker,
    UIActionSheetPickerStyleDatePicker,
}UIActionSheetPickerStyle;

@class UIActionSheetPickerView;

@protocol UIActionSheetPickerViewDelegate <NSObject>

- (void)actionSheetViewDelegate:(UIActionSheetPickerView *)pickerView didSelectTitles:(NSArray*)titles;

@end

@interface UIActionSheetPickerView : UIView <UIPickerViewDataSource,UIPickerViewDelegate> {
    UIPickerView    *_pickerView;
//    UIDatePicker    *_datePicker;
    UIToolbar       *_actionToolbar;
    
    UIView          *_fadeView;  // 遮罩层
//    UIView          *_actionSheetView;  // 将 pickerView 组装进来
    UILabel         *_pickTitle;
}

// 通过委托来代理实现协议方法的调用
@property(nonatomic,strong) id<UIActionSheetPickerViewDelegate> delegate;

@property(nonatomic, assign) UIActionSheetPickerStyle actionSheetPickerStyle;

@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) UIView *actionSheetView;  // 将 pickerView 组装进来

/*for UIActionSheetPickerStyleTextPicker*/
@property(nonatomic, assign) BOOL isRangePickerView;
@property(nonatomic, strong) NSArray *titlesForComponenets;
@property(nonatomic, strong) NSArray *widthsForComponents;
@property(nonatomic, strong) NSArray *selectedTitles;
-(void)selectIndexes:(NSArray *)indexes animated:(BOOL)animated;

/*for UIActionSheetPickerStyleDatePicker*/
@property(nonatomic, assign) NSDateFormatterStyle dateStyle;    //returning date string style.
@property(nonatomic, assign) NSDate *date; //get/set date.
-(void)setDate:(NSDate *)date animated:(BOOL)animated;

/*for Both picker styles*/
-(void)showInView:(UIView *)view;
-(void)setPickerTitle:(NSString*)title;
-(void)setSelectedTitles:(NSArray *)selectedTitles animated:(BOOL)animated;
-(void)mySelectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

-(void)setBirthdayDataPicker;

@end
