//
//  UIActionSheetPickerView.m
//  Wasp
//
//  Created by Foogeez on 14-10-20.
//  Copyright (c) 2014年 Foogeez. All rights reserved.
//

#import "UIActionSheetPickerView.h"

const int NAV_BAR_HEIGHT = 0;

@implementation UIActionSheetPickerView

- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
    
    if (frame.origin.y > 0) {
        self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    else {
        self = [super initWithFrame:frame];
    }
    
    if (self) {
        
        // 载入底部遮罩层
        _fadeView = [[UIView alloc] initWithFrame:self.frame];
        _fadeView.backgroundColor = [UIColor clearColor];
        _fadeView.alpha = 0.6;
        [self addSubview:_fadeView];
        
        // 载入 actionSheetView
        _actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height + 280 + NAV_BAR_HEIGHT, 320, 280)];
        _actionSheetView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_actionSheetView];
        
        // ToolBar
        _actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _actionToolbar.barStyle = UIBarStyleDefault;
        [_actionToolbar.layer setBorderWidth:0.5];  // 绘制边框
        [_actionToolbar.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil)
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(pickerCancelClicked:)];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"confirm", nil)
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(pickerDoneClicked:)];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        [_actionToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexSpace,doneBtn, nil] animated:YES];
        [_actionSheetView addSubview:_actionToolbar];
        
        // pickerTitle
        _pickTitle = [[UILabel alloc] initWithFrame:CGRectMake((_actionToolbar.frame.size.width - 200) / 2, 0, 200, 44)];
        _pickTitle.text = @"Title";
        _pickTitle.font = [UIFont systemFontOfSize:16];
        _pickTitle.textAlignment = NSTextAlignmentCenter;
        
        [_actionToolbar addSubview:_pickTitle];
        
        // Picker View
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_actionToolbar.frame) , 320, 0)];
        [_pickerView sizeToFit];
        [_pickerView setShowsSelectionIndicator:YES];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        _pickerView.backgroundColor = [UIColor clearColor];
        [_actionSheetView addSubview:_pickerView];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_actionToolbar.frame) , 320, 0)];
        [_datePicker sizeToFit];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_actionSheetView addSubview:_datePicker];
        
        [self setDateStyle:NSDateFormatterMediumStyle];
        [self setActionSheetPickerStyle:UIActionSheetPickerStyleTextPicker];
    }
    
    return self;
}

-(void)setActionSheetPickerStyle:(UIActionSheetPickerStyle)actionSheetPickerStyle {
    _actionSheetPickerStyle = actionSheetPickerStyle;
    
    switch (actionSheetPickerStyle) {
        case UIActionSheetPickerStyleTextPicker:
            [_pickerView setHidden:NO];
            [_datePicker setHidden:YES];
            break;
        case UIActionSheetPickerStyleDatePicker:
            [_pickerView setHidden:YES];
            [_datePicker setHidden:NO];
            break;
            
        default:
            break;
    }
}

-(void)setBirthdayDataPicker {
    _datePicker.minimumDate = [self dateFromString:@"1900-01-01"];
    _datePicker.maximumDate = [NSDate date];
    [_datePicker setDate:[self dateFromString:@"1990-01-01"] animated:YES];
}

-(void)setPickerTitle:(NSString*)title {
    _pickTitle.text = title;
}

// 取消选择, 隐藏 pickerView 视图
-(void)pickerCancelClicked:(UIBarButtonItem*)barButton {
    [self hidePickerView];
}

// 选择完成, 保存选择数据
-(void)pickerDoneClicked:(UIBarButtonItem*)barButton
{
    NSMutableArray *selectedTitles = [[NSMutableArray alloc] init];
    
    if (_actionSheetPickerStyle == UIActionSheetPickerStyleTextPicker)
    {
        for (NSInteger component = 0; component<_pickerView.numberOfComponents; component++)
        {
            NSInteger row = [_pickerView selectedRowInComponent:component];
            
            if (row!= -1)
            {
                [selectedTitles addObject:[[_titlesForComponenets objectAtIndex:component] objectAtIndex:row]];
            }
            else
            {
                [selectedTitles addObject:[NSNull null]];
            }
        }
        
        [self setSelectedTitles:selectedTitles];
    }
    else if (_actionSheetPickerStyle == UIActionSheetPickerStyleDatePicker)
    {
        if (_datePicker.datePickerMode == UIDatePickerModeTime) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            
            [selectedTitles addObject:[dateFormatter stringFromDate:_datePicker.date]];
        }
        else if (_datePicker.datePickerMode == UIDatePickerModeDateAndTime) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            
            [selectedTitles addObject:[dateFormatter stringFromDate:_datePicker.date]];
        }
        else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            [selectedTitles addObject:[dateFormatter stringFromDate:_datePicker.date]];
//            [selectedTitles addObject:[NSDateFormatter localizedStringFromDate:_datePicker.date dateStyle:_dateStyle timeStyle:NSDateFormatterNoStyle]];
        }
        
        [self setDate:_datePicker.date];
        [self setSelectedTitles:[[NSArray alloc] initWithObjects:_datePicker.date, nil]];
    }
    
    [self.delegate actionSheetViewDelegate:self didSelectTitles:selectedTitles];
    
    NSLog(@"UIActionSheetPickerView Delegate tag = %d", (int)self.tag);
    
    [self hidePickerView];
}

// 设置当前标题
-(void)setSelectedTitles:(NSArray *)selectedTitles {
    [self setSelectedTitles:selectedTitles animated:NO];
}

// 设置选取器标题
-(void)setSelectedTitles:(NSArray *)selectedTitles animated:(BOOL)animated {
    
    if (_actionSheetPickerStyle == UIActionSheetPickerStyleTextPicker) {
        
        NSUInteger totalComponent = MIN(selectedTitles.count, _pickerView.numberOfComponents);
        
        for (NSInteger component = 0; component<totalComponent; component++) {
            
            NSArray *items = [_titlesForComponenets objectAtIndex:component];
            id selectTitle = [selectedTitles objectAtIndex:component];
            
            if ([items containsObject:selectTitle]) {
                NSUInteger rowIndex = [items indexOfObject:selectTitle];
                [_pickerView selectRow:rowIndex inComponent:component animated:animated];
            }
        }
    }
    else if (_actionSheetPickerStyle == UIActionSheetPickerStyleDatePicker) {
        
        if (selectedTitles.count && [[selectedTitles firstObject] isKindOfClass:[NSDate class]]) {
            [self setDate:[selectedTitles firstObject]];
        }
    }
}

// 设置选取器项
-(void)selectIndexes:(NSArray *)indexes animated:(BOOL)animated {
    
    if (_actionSheetPickerStyle == UIActionSheetPickerStyleTextPicker) {
        NSUInteger totalComponent = MIN(indexes.count, _pickerView.numberOfComponents);
        
        for (NSInteger component = 0; component<totalComponent; component++) {
            
            NSArray *items = [_titlesForComponenets objectAtIndex:component];
            NSUInteger selectIndex = [[indexes objectAtIndex:component] unsignedIntegerValue];
            
            if (items.count < selectIndex) {
                [_pickerView selectRow:selectIndex inComponent:component animated:animated];
            }
        }
    }
}

-(void) setDate:(NSDate *)date {
    [self setDate:date animated:NO];
}

-(void)setDate:(NSDate *)date animated:(BOOL)animated {
    _date = date;
    if (_date != nil)
        [_datePicker setDate:_date animated:animated];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //If having widths
    if (_widthsForComponents) {
        //If object isKind of NSNumber class
        if ([[_widthsForComponents objectAtIndex:component] isKindOfClass:[NSNumber class]]) {
            CGFloat width = [[_widthsForComponents objectAtIndex:component] floatValue];
            
            //If width is 0, then calculating it's size.
            if (width == 0)
                return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
            //Else returning it's width.
            else
                return width;
        }
        //Else calculating it's size.
        else
            return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
    }
    //Else calculating it's size.
    else
    {
        return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [_titlesForComponenets count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[_titlesForComponenets objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_titlesForComponenets objectAtIndex:component] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_isRangePickerView && pickerView.numberOfComponents == 3) {
        
        if (component == 0) {
            [pickerView selectRow:MAX([pickerView selectedRowInComponent:2], row) inComponent:2 animated:YES];
        }
        else if (component == 2) {
            [pickerView selectRow:MIN([pickerView selectedRowInComponent:0], row) inComponent:0 animated:YES];
        }
    }
}

/*
 UIActionSheet上添加UIPickerView iOS8替换方案
 
 采用“UIView＋动画”方式实现（将UIActionSheet替换为UIView）
 第一层：view（这一层充满整个屏幕，初始化时颜色为透明，userInteractionEnabled 为NO；显示时颜色为黑色，alpha值设置为0.6，userInteractionEnabled 为YES。作用是遮挡界面上其他的控件。）
 第二层：contentView（这一层用来代替原来UIActionSheet。UIPickerView就添加在这一层上，颜色为白色，alpha值设置为0.9）
 第三层：UIPickerView
 
 以下代码中self即为第一层的view
 */

// 弹出 pickerView
-(void)showInView:(UIView *)view {
    
    [view addSubview:self];
    
    // 刷新 picker 数据
    [_pickerView reloadAllComponents];
    
    // 设置弹出动画
    [UIView animateWithDuration:0.3 animations:^(void){
        
        _fadeView.backgroundColor = [UIColor blackColor];
        
        CGSize size = _actionSheetView.frame.size;
        float y = view.bounds.size.height - size.height - NAV_BAR_HEIGHT;
        
        [_actionSheetView setFrame:CGRectMake(0, y, size.width, size.height)];
        
    } completion:^(BOOL isFinished){
        // 动画完成时的处理
    }];
}

// 隐藏 pickerView
- (void)hidePickerView {
    
    [UIView animateWithDuration:0.3 animations:^(void){
        
        _fadeView.backgroundColor = [UIColor clearColor];
        
        CGSize size = _actionSheetView.frame.size;
        float y = self.frame.size.height + size.height + NAV_BAR_HEIGHT;
        
        [_actionSheetView setFrame:CGRectMake(0, y, size.width, size.height)];
        
    } completion:^(BOOL isFinished){
        [self removeFromSuperview];
    }];
}

- (void)mySelectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    [_pickerView selectRow:row inComponent:component animated:animated];
}

- (NSDate *)dateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}

@end
