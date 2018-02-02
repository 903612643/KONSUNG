//
//  DateSelectControl.m
//  GEEZBAND
//
//  Created by Foogeez on 14/11/14.
//  Copyright (c) 2014年 Foogeez. All rights reserved.
//

#import "DateSelectControl.h"

@interface DateSelectControl () {
    UIButton *m_prv_button;
    UIButton *m_nxt_button;
    
    UILabel *m_prv_label;
    UILabel *m_nxt_label;
    
    int current_date;
    int max_date_count;
}

@property(nonatomic, strong) NSArray *dateArray;

@end

@implementation DateSelectControl

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        int button_size = self.frame.size.height;
        
        m_prv_button = [UIButton buttonWithType:UIButtonTypeSystem];
        m_prv_button.frame = CGRectMake(0, 0, button_size, button_size);
        [m_prv_button setImage:[UIImage imageNamed:@"prv_new"] forState:UIControlStateNormal];
        [m_prv_button addTarget:self action:@selector(selectPreviousDate) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:m_prv_button];
        
        m_nxt_button = [UIButton buttonWithType:UIButtonTypeSystem];
        m_nxt_button.frame = CGRectMake(self.frame.size.width - button_size, 0, button_size, button_size);
        [m_nxt_button setImage:[UIImage imageNamed:@"nxt_new"] forState:UIControlStateNormal];
        [m_nxt_button addTarget:self action:@selector(selectNextDate) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:m_nxt_button];
        
        UILabel *m_prv_hint = [[UILabel alloc] initWithFrame:CGRectMake(m_prv_button.frame.size.width - 10, 0, 60, button_size / 2)];
        m_prv_hint.font = [UIFont boldSystemFontOfSize:12];
        m_prv_hint.textAlignment = NSTextAlignmentLeft;
        m_prv_hint.adjustsFontSizeToFitWidth = true;
        m_prv_hint.text = NSLocalizedString(@"previous_date",nil);
//        [self addSubview:m_prv_hint];
        
        UILabel *m_nxt_hint = [[UILabel alloc] initWithFrame:CGRectMake(m_nxt_button.frame.origin.x - 60 + 10, 0, 60, button_size / 2)];
        m_nxt_hint.font = [UIFont boldSystemFontOfSize:12];
        m_nxt_hint.textAlignment = NSTextAlignmentRight;
        m_nxt_hint.adjustsFontSizeToFitWidth = true;
        m_nxt_hint.text = NSLocalizedString(@"next_date",nil);
//        [self addSubview:m_nxt_hint];
        
        m_prv_label = [[UILabel alloc] initWithFrame:CGRectMake(m_prv_button.frame.size.width - 10, button_size / 2, 60, button_size / 2)];
        m_prv_label.font = [UIFont systemFontOfSize:12];
        m_prv_label.textAlignment = NSTextAlignmentLeft;
        m_prv_label.adjustsFontSizeToFitWidth = true;
//        [self addSubview:m_prv_label];
        
        m_nxt_label = [[UILabel alloc] initWithFrame:CGRectMake(m_nxt_button.frame.origin.x - 60 + 10, button_size / 2, 60, button_size / 2)];
        m_nxt_label.font = [UIFont systemFontOfSize:12];
        m_nxt_label.textAlignment = NSTextAlignmentRight;
        m_nxt_label.adjustsFontSizeToFitWidth = true;
//        [self addSubview:m_nxt_label];
        
        m_prv_button.tintColor = [UIColor whiteColor];
        m_nxt_button.tintColor = [UIColor whiteColor];
        
//        m_prv_label.textColor  = textColor;
//        m_nxt_label.textColor  = textColor;
        
        current_date = 0;
    }
    return self;
}


/// 选择之前的日期
- (void)selectPreviousDate {
    
    if ((max_date_count > 0) == false || (current_date == max_date_count - 1)) return;
    
    current_date ++;
    
    [self getTitle];
    [self.delegate changeCurrentDate];
}

/// 选择之后的日期
- (void)selectNextDate {
    
    if ((max_date_count > 0) == false || (current_date == 0)) return;
    
//    current_date --;
    
    current_date = 0;
    
    [self getTitle];
    [self.delegate changeCurrentDate];
}

- (void)setSelectDateArray:(NSArray *)dateArray {
    
    current_date = 0;
    self.dateArray = dateArray;
    
    max_date_count = (int)self.dateArray.count;
    [self getTitle];
}

/// 获取当前 Title
- (void)getTitle {
    
    m_nxt_label.text = @"——";
    m_prv_label.text = @"——";
    
    if (max_date_count > 0) {
        
//        NSArray *nxtArray = [[NSString stringWithFormat:@"%@", self.dateArray[0]] componentsSeparatedByString:@"_"];
//        
//        if (nxtArray.count == 4) {
//            m_nxt_label.text = [NSString stringWithFormat:@"%@-%@-%@", nxtArray[1], nxtArray[2], nxtArray[3]];
//        }
//        
//        if (current_date + 1 <= max_date_count - 1) {
//            
//            NSArray *prvArray = [[NSString stringWithFormat:@"%@", self.dateArray[current_date + 1]] componentsSeparatedByString:@"_"];
//            
//            if (prvArray.count == 4) {
//                m_prv_label.text = [NSString stringWithFormat:@"%@-%@-%@", prvArray[1], prvArray[2], prvArray[3]];
//            }
//        }
        
        NSArray  *prvArray = [[NSString stringWithFormat:@"%@", self.dateArray[current_date]] componentsSeparatedByString:@"_"];
        self.currentDataStr = [NSString stringWithFormat:@"%@-%@-%@", prvArray[1], prvArray[2], prvArray[3]];
    }
}

- (NSString *)getCurrentTableName {
    
    NSString *tableName = @"nil";
    
    if (max_date_count > 0) {
        tableName = [NSString stringWithFormat:@"%@", self.dateArray[current_date]];
    }
    
    return tableName;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
//*/


@end
