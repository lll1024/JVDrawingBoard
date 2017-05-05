//
//  ViewController.m
//  JVDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/1.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import "ViewController.h"
#import "JVDrawingView.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *toolButton;
@property (nonatomic, strong) UIButton *trackButton;
@property (nonatomic, strong) JVDrawingView *drawingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.drawingView];
    [self.view addSubview:self.trackButton];
    [self.view addSubview:self.toolButton];
}

- (void)toolButtonAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"涂鸦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.drawingView.type = JVDrawingTypeGraffiti;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"箭头" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.drawingView.type = JVDrawingTypeArrow;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"直线" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.drawingView.type = JVDrawingTypeLine;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"双杠尺子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.drawingView.type = JVDrawingTypeRulerLine;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"双箭头尺子" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.drawingView.type = JVDrawingTypeRulerArrow;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)trackButtonAction {
    self.trackButton.hidden = [self.drawingView revoke];
}

- (JVDrawingView *)drawingView {
    if (_drawingView == nil){
        _drawingView = [[JVDrawingView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _drawingView.drawingLayerSelectedBlock = ^(BOOL isSelected){
            weakSelf.trackButton.hidden = !isSelected;
        };
    }
    return _drawingView;
}

- (UIButton *)toolButton {
    if (_toolButton == nil){
        _toolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toolButton.frame = CGRectMake(30, self.view.frame.size.height-80, 50, 50);
        _toolButton.backgroundColor = [UIColor lightGrayColor];
        _toolButton.layer.cornerRadius = 25;
        [_toolButton setTitle:@"工具" forState:UIControlStateNormal];
        [_toolButton addTarget:self action:@selector(toolButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolButton;
}

- (UIButton *)trackButton {
    if (_trackButton == nil){
        _trackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _trackButton.frame = CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-80, 50, 50);
        _trackButton.backgroundColor = [UIColor lightGrayColor];
        _trackButton.layer.cornerRadius = 25;
        [_trackButton setTitle:@"撤销" forState:UIControlStateNormal];
        [_trackButton addTarget:self action:@selector(trackButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _trackButton.hidden = YES;
    }
    return _trackButton;
}

@end
