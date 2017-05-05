//
//  JVDrawingLayer.h
//  JVDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/2.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, JVDrawingType) {
    JVDrawingTypeArrow = 0,     //单箭头
    JVDrawingTypeLine,          //直线
    JVDrawingTypeRulerArrow,    //双箭头尺
    JVDrawingTypeRulerLine,     //双直线尺
    JVDrawingTypeGraffiti       //涂鸦
};

typedef NS_ENUM(NSInteger, JVDrawingTouch) {
    JVDrawingTouchHead = 1,     //点击头部
    JVDrawingTouchMid,          //点击中部
    JVDrawingTouchEnd           //点击尾部
};

@interface JVDrawingLayer : CAShapeLayer

@property (nonatomic, assign) BOOL isSelected;    /**< 是否选中 */
@property (nonatomic, assign) JVDrawingType type;

+ (JVDrawingLayer *)createLayerWithStartPoint:(CGPoint)startPoint type:(JVDrawingType)type;

- (NSInteger)caculateLocationWithPoint:(CGPoint)point;

- (void)movePathWithStartPoint:(CGPoint)startPoint;
- (void)movePathWithEndPoint:(CGPoint)EndPoint;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;

- (void)movePathWithStartPoint:(CGPoint)startPoint isSelected:(BOOL)isSelected;
- (void)movePathWithEndPoint:(CGPoint)EndPoint isSelected:(BOOL)isSelected;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint
                     currentPoint:(CGPoint)currentPoint
                       isSelected:(BOOL)isSelected;

- (void)moveGrafiitiPathPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;

- (void)addToTrack;
- (BOOL)revokeUntilHidden;

@end
