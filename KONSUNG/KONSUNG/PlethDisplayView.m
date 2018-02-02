//
//  PlethDisplayView.m
//  KONSUNG
//
//  Created by Foogeez on 15/6/3.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//

#import "PlethDisplayView.h"

@interface PlethDisplayView () {
    
    float chart_sta_x;
    float chart_end_x;
    float chart_sta_y;
    float chart_end_y;
    
    float Coordinate_SpO2_Y;
    float Coordinate_Pr_Y;
    
    CGPoint old_point_Pleth;
    CGPoint new_point_Pleth;
}

@property(nonatomic) CGContextRef context;

@property(nonatomic, strong) UIBezierPath *plethPath;
@property(nonatomic, strong) CAShapeLayer *plethShapeLayer;

@property(nonatomic, strong) UIBezierPath *spo2Path;
@property(nonatomic, strong) CAShapeLayer *spo2ShapeLayer;

@property(nonatomic, strong) UIBezierPath *prPath;
@property(nonatomic, strong) CAShapeLayer *prShapeLayer;

@end

//______________________________________________________________________________________________________

@implementation PlethDisplayView

- (void)refreshThisView {
    
    self.spo2Path  = [[UIBezierPath alloc] init];
    self.prPath    = [[UIBezierPath alloc] init];
    self.plethPath = [[UIBezierPath alloc] init];
    
    self.spo2ShapeLayer.path  = self.spo2Path.CGPath;
    self.prShapeLayer.path    = self.prPath.CGPath;
    self.plethShapeLayer.path = self.plethPath.CGPath;
    
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        chart_sta_x = Data_Label_Width;
        chart_end_x = self.frame.size.width - Data_Label_Width;
        chart_sta_y = Data_Label_Height * 2 + Data_Label_Height / 2;
        chart_end_y = self.frame.size.height - Data_Label_Height;
        
        Coordinate_SpO2_Y = chart_end_y - (chart_end_y - chart_sta_y) / 2 - Data_Offset_Space / 2;
        Coordinate_Pr_Y   = chart_end_y - (chart_end_y - chart_sta_y) / 2 + Data_Offset_Space / 2;
        
        old_point_Pleth = CGPointMake(chart_sta_x, chart_end_y);
        new_point_Pleth = old_point_Pleth;
        
        //______________________________________________________________________________________________________
        // init shape layer and path
        
        self.plethPath = [[UIBezierPath alloc] init];
        
        self.plethShapeLayer = [CAShapeLayer layer];
        self.plethShapeLayer.strokeColor = [UIColor yellowColor].CGColor;
        self.plethShapeLayer.lineWidth = 1;
        [self.layer addSublayer:self.plethShapeLayer];
        
        
        self.spo2Path = [[UIBezierPath alloc] init];
        
        self.spo2ShapeLayer = [CAShapeLayer layer];
        self.spo2ShapeLayer.strokeColor = [UIColor redColor].CGColor;
        self.spo2ShapeLayer.lineWidth = 1;
        [self.layer addSublayer:self.spo2ShapeLayer];
        
        
        self.prPath = [[UIBezierPath alloc] init];
        
        self.prShapeLayer = [CAShapeLayer layer];
        self.prShapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.prShapeLayer.lineWidth = 1;
        [self.layer addSublayer:self.prShapeLayer];
    }
    return self;
}

- (void)addSubLabelWithFrame:(CGRect)frame text:(NSString *)text fontSize:(int)size color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:size];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = true;
    
    label.text = text;
    label.textColor = color;
    [self addSubview:label];
}

- (void)setPlethData:(int)data {
    
    if (data > 100) {
        data = 100;
    }
    
    new_point_Pleth = [self getNewChartPoint:data];
    
    [self.plethPath moveToPoint:old_point_Pleth];
    [self.plethPath addLineToPoint:new_point_Pleth];
    self.plethShapeLayer.path = self.plethPath.CGPath;
    
    old_point_Pleth = new_point_Pleth;
}

// x 轴自增, 到边界后, 重新刷新图表
- (CGPoint)getNewChartPoint:(int)data {
    
    float speed = (chart_end_x - chart_sta_x) / Data_Refresh_Speed;
    
    float x_SpO2 = old_point_Pleth.x + speed;
    float y_SpO2 = chart_end_y - (chart_end_y - chart_sta_y) * data / 100;
    
    if (x_SpO2 > chart_end_x) {
        x_SpO2 = chart_sta_x;
        old_point_Pleth.x = x_SpO2;
        self.plethPath = [[UIBezierPath alloc] init];
        self.plethShapeLayer.path = nil;
    }
    
    return CGPointMake(x_SpO2, y_SpO2);
}

// 设置数组并刷新视图
- (void)setSpO2_PR_DataArray:(NSArray *)dataArray {
    
    dataArray = [self getRightData:dataArray];
    
    //______________________________________________________________________________________________________
    // 绘制 SpO2 和 PR
    
    int count = (int)[dataArray[0] count];
    
    if (count <= 10) {
        Max_Line_Count = 10;
    }
    else {
        Max_Line_Count = count;
    }
    
    if (count > 0) {
        
        //______________________________________________________________________________________________________
    
        for (int i = 0; i < count - 1; i++) {
            
            int cur_spo2 = [dataArray[0][i] intValue];
            int nex_spo2 = [dataArray[0][i+1] intValue];
            int cur_pr   = [dataArray[1][i] intValue];
            int nex_pr   = [dataArray[1][i+1] intValue];
            
            //______________________________________________________________________________________________________
            // 绘制 SpO2 的圆点和连接线
            
            CGPoint spo2Point_cur = [self getSpO2Point:cur_spo2 index:i];
            CGPoint spo2Point_nxt = [self getSpO2Point:nex_spo2 index:i+1];
            
            [self.spo2Path moveToPoint:spo2Point_cur];
            [self.spo2Path addArcWithCenter:spo2Point_cur radius:2 startAngle:0 endAngle:2*M_PI clockwise:YES];
            
            [self.spo2Path moveToPoint:spo2Point_cur];
            [self.spo2Path addLineToPoint:spo2Point_nxt];
            
            //______________________________________________________________________________________________________
            // 绘制 PR 的圆点和连接线
            
            CGPoint prPoint_cur = [self getPrPoint:cur_pr index:i];
            CGPoint prPoint_nxt = [self getPrPoint:nex_pr index:i+1];
            
            [self.prPath moveToPoint:prPoint_cur];
            [self.prPath addArcWithCenter:prPoint_cur radius:2 startAngle:0 endAngle:2*M_PI clockwise:YES];
            
            [self.prPath moveToPoint:prPoint_cur];
            [self.prPath addLineToPoint:prPoint_nxt];
        }
        
        //______________________________________________________________________________________________________
        
        CGPoint spo2Point = [self getSpO2Point:[dataArray[0][count-1] intValue] index:count-1];
        CGPoint prPoint   = [self getPrPoint:[dataArray[1][count-1] intValue] index:count-1];
        
        [self.spo2Path moveToPoint:spo2Point];
        [self.spo2Path addArcWithCenter:spo2Point radius:2 startAngle:0 endAngle:2*M_PI clockwise:YES];
        
        [self.prPath moveToPoint:prPoint];
        [self.prPath addArcWithCenter:prPoint radius:2 startAngle:0 endAngle:2*M_PI clockwise:YES];
        
    }
    
    self.spo2ShapeLayer.path = self.spo2Path.CGPath;
    self.prShapeLayer.path = self.prPath.CGPath;
}

// 过滤非正常数据
- (NSArray *)getRightData:(NSArray *)dataArray {
    
    NSMutableArray *spo2DataArray = [[NSMutableArray alloc] init];
    NSMutableArray *prDataArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dataArray[0] count]; i++) {
        
        int cur_spo2 = [dataArray[0][i] intValue];
        int cur_pr   = [dataArray[1][i] intValue];
        
        if (cur_spo2 < Data_Min_SpO2
            || cur_spo2 > Data_Max_SpO2
            || cur_pr < Data_Min_Pr
            || cur_pr > Data_Max_Pr
            ) {
        }
        else {
            [spo2DataArray addObject:@(cur_spo2)];
            [prDataArray addObject:@(cur_pr)];
        }
    }
    
    return @[spo2DataArray, prDataArray];
   
}

- (CGPoint)getSpO2Point:(int)data index:(int)index {
    
//    if (data < Data_Min_SpO2) {
//        data = Data_Min_SpO2;
//    }
//    else if (data > Data_Max_SpO2) {
//        data = Data_Max_SpO2;
//    }
    
    float chart_space = (chart_end_x - chart_sta_x) / Max_Line_Count;
    float x = chart_sta_x + chart_space * (index + 1) - chart_space / 2;
    float y = 0;
    
    if (data <= Data_Standard_Pr) {
        y = chart_end_y - (chart_end_y - Coordinate_Pr_Y) * ( (data - Data_Min_Pr) / (Data_Standard_Pr - Data_Min_Pr) );
    }
    else if (data > Data_Standard_Pr && data <= Data_Standard_SpO2) {
        y = Coordinate_Pr_Y - (Coordinate_Pr_Y - Coordinate_SpO2_Y) * ( (data - Data_Standard_Pr) / (Data_Standard_SpO2 - Data_Standard_Pr) );
    }
    else {
        y = Coordinate_SpO2_Y - (Coordinate_SpO2_Y - chart_sta_y) * ( (data - Data_Standard_SpO2) / (Data_Max_SpO2 - Data_Standard_SpO2) );
    }
    
    return CGPointMake(x, y);
}

- (CGPoint)getPrPoint:(int)data index:(int)index {
    
//    if (data < Data_Min_Pr) {
//        data = Data_Min_Pr;
//    }
//    else if (data > Data_Max_Pr) {
//        data = Data_Max_Pr;
//    }
    
    float chart_space = (chart_end_x - chart_sta_x) / Max_Line_Count;
    float x = chart_sta_x + chart_space * (index + 1) - chart_space / 2;
    float y = 0;
    
    if (data <= Data_Standard_Pr) {
        y = chart_end_y - (chart_end_y - Coordinate_Pr_Y) * ( (data - Data_Min_Pr) / (Data_Standard_Pr - Data_Min_Pr) );
    }
    else if (data > Data_Standard_Pr && data <= Data_Standard_SpO2) {
        y = Coordinate_Pr_Y - (Coordinate_Pr_Y - Coordinate_SpO2_Y) * ( (data - Data_Standard_Pr) / (Data_Standard_SpO2 - Data_Standard_Pr) );
    }
    else {
        y = Coordinate_SpO2_Y - (Coordinate_SpO2_Y - chart_sta_y) * ( (data - Data_Standard_SpO2) / (Data_Max_Pr - Data_Standard_SpO2) );
    }
    
    return CGPointMake(x, y);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self clearSubLabels];
    self.context = UIGraphicsGetCurrentContext();
    
    UIColor *chartColor = [UIColor blackColor];
    
    //______________________________________________________________________________________________________
    // 边框
    
    [self drawLineWithContext:self.context
                   startPoint:CGPointMake(chart_sta_x, chart_sta_y)
                     endPoint:CGPointMake(chart_sta_x, chart_end_y)
                        width:1.5
                        color:chartColor.CGColor
                  dashedSpace:0];
    [self drawLineWithContext:self.context
                   startPoint:CGPointMake(chart_sta_x, chart_end_y)
                     endPoint:CGPointMake(chart_end_x, chart_end_y)
                        width:1.5
                        color:chartColor.CGColor
                  dashedSpace:0];
    [self drawLineWithContext:self.context
                   startPoint:CGPointMake(chart_end_x, chart_sta_y)
                     endPoint:CGPointMake(chart_end_x, chart_end_y)
                        width:1.5
                        color:chartColor.CGColor
                  dashedSpace:0];
    
    //______________________________________________________________________________________________________
    // 分隔轴线和 x 轴标签
    
    float chart_space = (chart_end_x - chart_sta_x) / Max_Line_Count;
    
    for (int i = 0; i < Max_Line_Count; i++) {
        
        float x = chart_sta_x + chart_space * i;
        
        [self drawLineWithContext:self.context
                       startPoint:CGPointMake(x, chart_sta_y)
                         endPoint:CGPointMake(x, chart_end_y)
                            width:0.5
                            color:chartColor.CGColor
                      dashedSpace:4];
        
        [self addSubLabelWithFrame:CGRectMake(x - Data_Label_Width / 2 + chart_space / 2, chart_end_y, Data_Label_Width, Data_Label_Height)
                              text:[NSString stringWithFormat:@"%d", i+1]
                          fontSize:8
                             color:[UIColor blackColor]];
    }
    
    //______________________________________________________________________________________________________
    // SpO2 和 PR 标准轴
    
    [self drawLineWithContext:self.context
                   startPoint:CGPointMake(chart_sta_x, Coordinate_SpO2_Y)
                     endPoint:CGPointMake(chart_end_x, Coordinate_SpO2_Y)
                        width:1.5
                        color:[UIColor redColor].CGColor
                  dashedSpace:2];
    
    [self drawLineWithContext:self.context
                   startPoint:CGPointMake(chart_sta_x, Coordinate_Pr_Y)
                     endPoint:CGPointMake(chart_end_x, Coordinate_Pr_Y)
                        width:1.5
                        color:[UIColor blueColor].CGColor
                  dashedSpace:2];
    
    //______________________________________________________________________________________________________
    // 左侧 Y 轴标签
    
    [self addSubLabelWithFrame:CGRectMake(0, chart_end_y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Min_Pr]
                      fontSize:8
                         color:[UIColor redColor]];
    
    [self addSubLabelWithFrame:CGRectMake(0, Coordinate_Pr_Y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Standard_Pr]
                      fontSize:8
                         color:[UIColor redColor]];
    
    [self addSubLabelWithFrame:CGRectMake(0, Coordinate_SpO2_Y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Standard_SpO2]
                      fontSize:8
                         color:[UIColor redColor]];
    
    [self addSubLabelWithFrame:CGRectMake(0, chart_sta_y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Max_SpO2]
                      fontSize:8
                         color:[UIColor redColor]];
    
    // 右侧 Y 轴标签
    
    [self addSubLabelWithFrame:CGRectMake(chart_end_x, chart_end_y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Min_Pr]
                      fontSize:8
                         color:[UIColor blueColor]];
    
    [self addSubLabelWithFrame:CGRectMake(chart_end_x, Coordinate_Pr_Y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Standard_Pr]
                      fontSize:8
                         color:[UIColor blueColor]];
    
    [self addSubLabelWithFrame:CGRectMake(chart_end_x, Coordinate_SpO2_Y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Standard_SpO2]
                      fontSize:8
                         color:[UIColor blueColor]];
    
    [self addSubLabelWithFrame:CGRectMake(chart_end_x, chart_sta_y - Data_Label_Height / 2, Data_Label_Width, Data_Label_Height)
                          text:[NSString stringWithFormat:@"%d", (int)Data_Max_Pr]
                      fontSize:8
                         color:[UIColor blueColor]];
    
    //______________________________________________________________________________________________________
    // 提示文本
    
    [self addSubLabelWithFrame:CGRectMake(chart_sta_x, Data_Label_Height / 2, 60, 20)
                          text:@"SpO2(%)"
                      fontSize:12
                         color:[UIColor redColor]];
    [self addSubLabelWithFrame:CGRectMake(chart_end_x - 60, Data_Label_Height / 2, 60, 20)
                          text:@"PR(Bpm)"
                      fontSize:12
                         color:[UIColor blueColor]];
}

- (void)clearSubLabels {
    for(id obj in self.subviews) {
        if([obj isKindOfClass:[UILabel class]]) {
            [obj removeFromSuperview];
        }
    }
}

- (void)drawLineWithContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint width:(float)width color:(CGColorRef)color dashedSpace:(CGFloat)space {
    
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, color);
    
    if (space > 0) {
        CGFloat lengths[] = {space, space};
        CGContextSetLineDash(context, 0, lengths, 2);
    }
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
}

@end
