//
//  JVDrawingView.h
//  JVDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/2.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVDrawingLayer.h"

@interface JVDrawingView : UIView

@property (nonatomic, copy) void (^drawingLayerSelectedBlock)(BOOL isSelected);
@property (nonatomic, assign) JVDrawingType type;

- (BOOL)revoke;

@end
