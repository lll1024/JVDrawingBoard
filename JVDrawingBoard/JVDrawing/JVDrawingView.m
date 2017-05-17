//
//  JVDrawingView.m
//  JVDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/2.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import "JVDrawingView.h"

@interface JVDrawingView ()

@property (nonatomic, assign) BOOL isFirstTouch;//区分点击与滑动手势
@property (nonatomic, assign) JVDrawingTouch isMoveLayer;//区分移动还是创建path 如果移动 移动哪里
@property (nonatomic, strong) JVDrawingLayer *drawingLayer;//当前创建的path
@property (nonatomic, strong) JVDrawingLayer *selectedLayer;//当前选中的path
@property (nonatomic, strong) NSMutableArray *layerArray;//当前创建的path集合

@end

@implementation JVDrawingView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.frame = [UIScreen mainScreen].bounds;
        self.layerArray = [[NSMutableArray alloc] init];
        self.type = JVDrawingTypeGraffiti;
    }
    return self;
}

- (BOOL)revoke {
    BOOL status = [self.selectedLayer revokeUntilHidden];
    if (status) {
        [self.selectedLayer removeFromSuperlayer];
        [self.layerArray removeObject:self.selectedLayer];
        self.selectedLayer = nil;
    }
    return status;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isFirstTouch = YES;//是否第一次点击屏幕
    self.isMoveLayer = NO;//是否移动layer
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    if (self.isFirstTouch) {
        if (self.selectedLayer && [self.selectedLayer caculateLocationWithPoint:currentPoint]) {
            self.isMoveLayer = [self.selectedLayer caculateLocationWithPoint:currentPoint];//计算当前point是否在已绘制的shapes里边
        } else {
            self.drawingLayer = [JVDrawingLayer createLayerWithStartPoint:previousPoint type:self.type];//创建相应的layer
            [self.layer addSublayer:self.drawingLayer];
        }
    } else {
        if (self.isMoveLayer) {
            if (self.selectedLayer.type == JVDrawingTypeGraffiti) {
                [self.selectedLayer moveGrafiitiPathPreviousPoint:previousPoint currentPoint:currentPoint];//平移涂鸦shape
            } else {
                switch (self.isMoveLayer) {
                    case JVDrawingTouchHead:
                        [self.selectedLayer movePathWithStartPoint:currentPoint];
                        break;
                    case JVDrawingTouchMid:
                        [self.selectedLayer movePathWithPreviousPoint:previousPoint currentPoint:currentPoint];
                        break;
                    case JVDrawingTouchEnd:
                        [self.selectedLayer movePathWithEndPoint:currentPoint];
                        break;
                        
                    default:
                        break;
                }
            }
        } else {
            [self.drawingLayer movePathWithEndPoint:currentPoint];//绘制新创建的shape
        }
    }
    
    self.isFirstTouch = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.layerArray containsObject:self.drawingLayer] && !self.isFirstTouch) {
        [self.layerArray addObject:self.drawingLayer];
        [self.drawingLayer addToTrack];
    } else {
        if (self.isMoveLayer) {
            [self.selectedLayer addToTrack];
        }
        if (self.isFirstTouch) {
            self.selectedLayer.isSelected = NO;
            self.selectedLayer = nil;
            
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self];
            for (JVDrawingLayer *layer in self.layerArray) {
                if ([layer caculateLocationWithPoint:currentPoint]) {
                    self.selectedLayer = layer;
                    self.selectedLayer.isSelected = YES;
                    [self.layerArray removeObject:self.selectedLayer];
                    [self.layerArray addObject:self.selectedLayer];
                    break;
                }
            }
            
            self.drawingLayerSelectedBlock(self.selectedLayer);
        }
    }
}

@end
