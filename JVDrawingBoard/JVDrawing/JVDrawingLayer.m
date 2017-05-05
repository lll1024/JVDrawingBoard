//
//  JVDrawingLayer.m
//  JVDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/2.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import "JVDrawingLayer.h"
#import <UIKit/UIKit.h>

#define JVDRAWINGPATHWIDTH 2
#define JVDRAWINGBUFFER 12
#define JVDRAWINGORIGINCOLOR [UIColor blackColor].CGColor
#define JVDRAWINGSELECTEDCOLOR [UIColor redColor].CGColor

@interface JVDrawingLayer ()

@property (nonatomic, assign) CGPoint startPoint;    /**< 起始坐标 */
@property (nonatomic, assign) CGPoint endPoint;    /**< 终点坐标 */
@property (nonatomic, strong) NSMutableArray *pointArray;    /**< 记录涂鸦的点 */
@property (nonatomic, strong) NSMutableArray *trackArray;    /**< 轨迹数组 */

@end

@implementation JVDrawingLayer 

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.lineJoin = kCALineJoinRound;
        self.lineCap = kCALineCapRound;
        self.strokeColor = self.fillColor = JVDRAWINGORIGINCOLOR;
        self.lineWidth = JVDRAWINGPATHWIDTH;
        self.isSelected = NO;
        self.trackArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    if (isSelected)
    {
        self.strokeColor = self.fillColor = [UIColor redColor].CGColor;
    }
    else
    {
        self.strokeColor = self.fillColor = [UIColor blackColor].CGColor;
    }
}

- (BOOL)isLocateDrawingLayerWithPoint:(CGPoint)point {
    CGFloat distanceStart = [self distanceBetweenStartPoint:point endPoint:self.startPoint];
    CGFloat distanceEnd = [self distanceBetweenStartPoint:point endPoint:self.endPoint];
    CGFloat distance = [self distanceBetweenStartPoint:self.startPoint endPoint:self.endPoint];
    CGFloat diffrence = distanceStart + distanceEnd - distance;
    if (diffrence <= JVDRAWINGBUFFER || distanceStart <= JVDRAWINGBUFFER || distanceEnd <= JVDRAWINGBUFFER) return YES;
    return NO;
}

- (NSInteger)caculateLocationWithPoint:(CGPoint)point {
    if (self.type == JVDrawingTypeGraffiti) {
        BOOL result = NO;
        for (NSValue *pointValue in self.pointArray) {
            CGPoint pathPoint = [pointValue CGPointValue];
            if ([self distanceBetweenStartPoint:pathPoint endPoint:point] < JVDRAWINGBUFFER) {
                result = YES;
            }
        }
        return result;
    } else {
        CGFloat distanceStart = [self distanceBetweenStartPoint:point endPoint:self.startPoint];
        CGFloat distanceEnd = [self distanceBetweenStartPoint:point endPoint:self.endPoint];
        CGFloat distance = [self distanceBetweenStartPoint:self.startPoint endPoint:self.endPoint];
        CGFloat diffrence = distanceStart + distanceEnd - distance;
        if (diffrence <= JVDRAWINGBUFFER || distanceStart <= JVDRAWINGBUFFER || distanceEnd <= JVDRAWINGBUFFER) {
            CGFloat min = MIN(distanceStart, distanceEnd);
            if (MIN(min, 2*JVDRAWINGBUFFER) == min) {
                if (min == distanceStart) return JVDrawingTouchHead;
                if (min == distanceEnd) return JVDrawingTouchEnd;
            } else {
                return JVDrawingTouchMid;
            }
        };
    }
    
    return NO;
}

+ (JVDrawingLayer *)createLayerWithStartPoint:(CGPoint)startPoint type:(JVDrawingType)type {
    JVDrawingLayer *layer = [[[self class] alloc] init];
    layer.startPoint = startPoint;
    layer.type = type;
    if (JVDrawingTypeGraffiti == type) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        layer.path = path.CGPath;
        layer.pointArray = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:startPoint]];
    }
    return layer;
}

- (void)movePathWithEndPoint:(CGPoint)endPoint {
    [self movePathWithEndPoint:endPoint isSelected:self.isSelected];
}

- (void)movePathWithStartPoint:(CGPoint)startPoint {
    [self movePathWithStartPoint:startPoint isSelected:self.isSelected];
}

- (void)movePathWithPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint {
    CGPoint startPoint = CGPointMake(self.startPoint.x+currentPoint.x-previousPoint.x, self.startPoint.y+currentPoint.y-previousPoint.y);
    CGPoint endPoint = CGPointMake(self.endPoint.x+currentPoint.x-previousPoint.x, self.endPoint.y+currentPoint.y-previousPoint.y);
    [self movePathWithStartPoint:startPoint endPoint:endPoint type:self.type isSelected:self.isSelected];
}

- (void)movePathWithStartPoint:(CGPoint)startPoint isSelected:(BOOL)isSelected {
    [self movePathWithStartPoint:startPoint endPoint:self.endPoint type:self.type isSelected:isSelected];
}

- (void)movePathWithEndPoint:(CGPoint)endPoint isSelected:(BOOL)isSelected{
    [self movePathWithStartPoint:self.startPoint endPoint:endPoint type:self.type isSelected:isSelected];
}

- (void)movePathWithPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint isSelected:(BOOL)isSelected {
    CGPoint startPoint = CGPointMake(self.startPoint.x+currentPoint.x-previousPoint.x, self.startPoint.y+currentPoint.y-previousPoint.y);
    CGPoint endPoint = CGPointMake(self.endPoint.x+currentPoint.x-previousPoint.x, self.endPoint.y+currentPoint.y-previousPoint.y);
    [self movePathWithStartPoint:startPoint endPoint:endPoint type:self.type isSelected:isSelected];
}

- (void)moveGrafiitiPathPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint {
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.path];
    [path applyTransform:CGAffineTransformMakeTranslation(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y)];
    self.path = path.CGPath;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSValue *pointValue in self.pointArray) {
        CGPoint pathPoint = [pointValue CGPointValue];
        pathPoint = CGPointMake(pathPoint.x + currentPoint.x - previousPoint.x, pathPoint.y + currentPoint.y - previousPoint.y);
        NSValue *newPointValue = [NSValue valueWithCGPoint:pathPoint];
        [newArray addObject:newPointValue];
    }
    self.startPoint = [[self.pointArray firstObject] CGPointValue];
    self.pointArray = newArray;
}

- (void)movePathWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint type:(JVDrawingType)type isSelected:(BOOL)isSelected {
    self.startPoint = startPoint;
    self.endPoint = endPoint;
    self.isSelected = isSelected;
    switch (type) {
        case JVDrawingTypeArrow:
            [self moveArrowPathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
            break;
            
        case JVDrawingTypeLine:
            [self moveLinePathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
            break;
            
        case JVDrawingTypeRulerLine:
            [self moveRulerLinePathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
            break;
            
        case JVDrawingTypeRulerArrow:
            [self moveRulerArrowPathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
            break;
            
        case JVDrawingTypeGraffiti:
            [self moveGraffitiPathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
            break;
            
        default:
            break;
    }
}

- (void)addToTrack {
    NSMutableDictionary *trackDic = [[NSMutableDictionary alloc] init];
    [trackDic setObject:NSStringFromCGPoint(self.startPoint) forKey:@"startPoint"];
    if (self.type == JVDrawingTypeGraffiti) {
        [trackDic setObject:NSStringFromCGPoint([self.pointArray[0] CGPointValue]) forKey:@"startPoint"];
    }
    [trackDic setObject:NSStringFromCGPoint(self.endPoint) forKey:@"endPoint"];
    [trackDic setObject:@(self.isSelected) forKey:@"isSelected"];
    [trackDic setObject:@(self.type) forKey:@"type"];
    [self.trackArray addObject:trackDic];    
}

- (BOOL)revokeUntilHidden {
    if (self.trackArray.count!=1) {
        NSMutableDictionary *trackDic = [self.trackArray objectAtIndex:self.trackArray.count-2];
        CGPoint startPoint = CGPointFromString(trackDic[@"startPoint"]);
        CGPoint endPoint = CGPointFromString(trackDic[@"endPoint"]);
        BOOL isSelected = [trackDic[@"isSelected"] boolValue];
        JVDrawingType type = [trackDic[@"type"] integerValue];
        switch (type) {
            case JVDrawingTypeArrow:
                [self moveArrowPathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
                break;
                
            case JVDrawingTypeLine:
                [self moveLinePathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
                break;
                
            case JVDrawingTypeRulerLine:
                [self moveRulerLinePathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
                break;
                
            case JVDrawingTypeRulerArrow:
                [self moveRulerArrowPathWithStartPoint:startPoint endPoint:endPoint isSelected:isSelected];
                break;
                
            case JVDrawingTypeGraffiti:
                [self moveGrafiitiPathPreviousPoint:self.startPoint currentPoint:startPoint];
                break;
                
            default:
                break;
        }
        
        self.startPoint = startPoint;
        self.endPoint = endPoint;
        self.isSelected = isSelected;
        self.type = type;
        [self.trackArray removeLastObject];
        return NO;
    }
    return YES;
}

- (void)moveArrowPathWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint isSelected:(BOOL)isSelected {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path appendPath:[self createArrowWithStartPoint:startPoint endPoint:endPoint]];
    self.path = path.CGPath;
}

- (void)moveLinePathWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                        isSelected:(BOOL)isSelected {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    self.path = path.CGPath;
}

- (void)moveRulerArrowPathWithStartPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                              isSelected:(BOOL)isSelected {
    self.path = [self createRulerArrowWithStartPoint:startPoint endPoint:endPoint length:0].CGPath;
}

- (void)moveRulerLinePathWithStartPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                             isSelected:(BOOL)isSelected {
    self.path = [self createRulerLinePathWithEndPoint:endPoint andStartPoint:startPoint length:0].CGPath;
}

- (void)moveGraffitiPathWithStartPoint:(CGPoint)startPoint
                              endPoint:(CGPoint)endPoint
                            isSelected:(BOOL)isSelected {
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.path];
    [path addLineToPoint:endPoint];
    [path moveToPoint:endPoint];
    self.path = path.CGPath;
    [self.pointArray addObject:[NSValue valueWithCGPoint:endPoint]];
}

#pragma mark **************** 创建生成双杠的Path
- (UIBezierPath *)createRulerLinePathWithEndPoint:(CGPoint)endPoint andStartPoint:(CGPoint)startPoint length:(CGFloat)length
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    CGFloat angle = [self angleWithFirstPoint:startPoint andSecondPoint:endPoint];
    CGPoint pointMiddle = CGPointMake((startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2);
    CGFloat offsetX = length*cos(angle);
    CGFloat offsetY = length*sin(angle);
    CGPoint pointMiddle1 = CGPointMake(pointMiddle.x-offsetX, pointMiddle.y-offsetY);
    CGPoint pointMiddle2 = CGPointMake(pointMiddle.x+offsetX, pointMiddle.y+offsetY);
    [bezierPath addLineToPoint:pointMiddle1];
    [bezierPath moveToPoint:pointMiddle2];
    [bezierPath addLineToPoint:endPoint];
    [bezierPath moveToPoint:endPoint];
    angle = [self angleEndWithFirstPoint:startPoint andSecondPoint:endPoint];
    CGPoint point1 = CGPointMake(endPoint.x+10*sin(angle), endPoint.y+10*cos(angle));
    CGPoint point2 = CGPointMake(endPoint.x-10*sin(angle), endPoint.y-10*cos(angle));
    [bezierPath addLineToPoint:point1];
    [bezierPath addLineToPoint:point2];
    CGPoint point3 = CGPointMake(point1.x-(endPoint.x-startPoint.x), point1.y-(endPoint.y-startPoint.y));
    CGPoint point4 = CGPointMake(point2.x-(endPoint.x-startPoint.x), point2.y-(endPoint.y-startPoint.y));
    [bezierPath moveToPoint:point3];
    [bezierPath addLineToPoint:point4];
    [bezierPath setLineWidth:4];
    
    return bezierPath;
}

- (UIBezierPath *)createRulerArrowWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint length:(CGFloat)length {
    CGFloat angle = [self angleWithFirstPoint:startPoint andSecondPoint:endPoint];
    CGPoint pointMiddle = CGPointMake((startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2);
    CGFloat offsetX = length*cos(angle);
    CGFloat offsetY = length*sin(angle);
    CGPoint pointMiddle1 = CGPointMake(pointMiddle.x-offsetX, pointMiddle.y-offsetY);
    CGPoint pointMiddle2 = CGPointMake(pointMiddle.x+offsetX, pointMiddle.y+offsetY);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:pointMiddle1];
    [path moveToPoint:pointMiddle2];
    [path addLineToPoint:endPoint];
    [path appendPath:[self createArrowWithStartPoint:pointMiddle1 endPoint:startPoint]];
    [path appendPath:[self createArrowWithStartPoint:pointMiddle2 endPoint:endPoint]];
    return path;
}

- (UIBezierPath *)createArrowWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CGPoint controllPoint = CGPointZero;
    CGPoint pointUp = CGPointZero;
    CGPoint pointDown = CGPointZero;
    CGFloat distance = [self distanceBetweenStartPoint:startPoint endPoint:endPoint];
    CGFloat distanceX = 8.0 * (ABS(endPoint.x - startPoint.x) / distance);
    CGFloat distanceY = 8.0 * (ABS(endPoint.y - startPoint.y) / distance);
    CGFloat distX = 4.0 * (ABS(endPoint.y - startPoint.y) / distance);
    CGFloat distY = 4.0 * (ABS(endPoint.x - startPoint.x) / distance);
    if (endPoint.x >= startPoint.x)
    {
        if (endPoint.y >= startPoint.y)
        {
            controllPoint = CGPointMake(endPoint.x - distanceX, endPoint.y - distanceY);
            pointUp = CGPointMake(controllPoint.x + distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x - distX, controllPoint.y + distY);
        }
        else
        {
            controllPoint = CGPointMake(endPoint.x - distanceX, endPoint.y + distanceY);
            pointUp = CGPointMake(controllPoint.x - distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x + distX, controllPoint.y + distY);
        }
    }
    else
    {
        if (endPoint.y >= startPoint.y)
        {
            controllPoint = CGPointMake(endPoint.x + distanceX, endPoint.y - distanceY);
            pointUp = CGPointMake(controllPoint.x - distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x + distX, controllPoint.y + distY);
        }
        else
        {
            controllPoint = CGPointMake(endPoint.x + distanceX, endPoint.y + distanceY);
            pointUp = CGPointMake(controllPoint.x + distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x - distX, controllPoint.y + distY);
        }
    }
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:endPoint];
    [arrowPath addLineToPoint:pointDown];
    [arrowPath addLineToPoint:pointUp];
    [arrowPath addLineToPoint:endPoint];
    return arrowPath;
}

- (CGFloat)distanceBetweenStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat xDist = (endPoint.x - startPoint.x);
    CGFloat yDist = (endPoint.y - startPoint.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (CGFloat)angleWithFirstPoint:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint
{
    CGFloat dx = secondPoint.x - firstPoint.x;
    CGFloat dy = secondPoint.y - firstPoint.y;
    CGFloat angle = atan2f(dy, dx);
    return angle;
}

- (CGFloat)angleEndWithFirstPoint:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint
{
    CGFloat dx = secondPoint.x - firstPoint.x;
    CGFloat dy = secondPoint.y - firstPoint.y;
    CGFloat angle = atan2f(fabs(dy), fabs(dx));
    if (dx*dy>0) {
        return M_PI-angle;
    }
    return angle;
}

@end
