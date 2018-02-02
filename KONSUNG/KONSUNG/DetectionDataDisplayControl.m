//
//  DetectionDataDisplayControl.m
//  KONSUNG
//
//  Created by SpaceTime on 15/6/6.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "DetectionDataDisplayControl.h"

@implementation DetectionDataDisplayControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)];
    if (self) {
        float size = frame.size.width;
        
        UIColor *borderColor = [UIColor colorWithRed:0.39 green:0.67 blue:0.21 alpha:1];
        
        self.layer.cornerRadius = size / 2;
        self.layer.masksToBounds = true;
        self.layer.borderWidth = 3;
        self.layer.borderColor = borderColor.CGColor;
        
        float space  = 15;
        float width  = frame.size.width - space * 2;
        float height = frame.size.width - space * 2;
        
        self.dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(space,
                                                                       space,
                                                                       width,
                                                                       height * 0.6)];
        self.dataLabel.adjustsFontSizeToFitWidth = true;
        self.dataLabel.font = [UIFont systemFontOfSize:24];
        self.dataLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.dataLabel];
        
        self.unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(space,
                                                                       CGRectGetMaxY(self.dataLabel.frame),
                                                                       width,
                                                                       height * 0.4)];
        self.unitLabel.adjustsFontSizeToFitWidth = true;
        self.unitLabel.font = [UIFont systemFontOfSize:12];
        self.unitLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.unitLabel];
    }
    return self;
}



@end
