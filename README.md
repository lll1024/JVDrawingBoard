# JVDrawingBoard
___
## 效果图
![](https://github.com/lll1024/JVDrawingBoard/blob/master/gif/2017-05-05%2009.57.45.gif)

## 说明
这是一个简洁的小画板 可以画双箭头、单箭头、涂鸦等 还可以编辑和撤销。总共包含两个类：

* `JVDrawingLayer`: 继承自`CAShapeLayer`，根据传入的枚举值type基于贝塞尔曲线而绘制不同的形状。
* `JVDrawingView`: 负责显示以及手势逻辑

下面是对`JVDrawingLayer`里边方法的说明：

	+ (JVDrawingLayer *)createLayerWithStartPoint:(CGPoint)startPoint type:(JVDrawingType)type;
当手在屏幕上开始移动的时候便会调用这个方法，会根据起始点和传入的枚举值type创建不同的形状的path，目前只有五种形状，分别是单箭头、双箭头、双杠、直线和涂鸦。

	- (NSInteger)caculateLocationWithPoint:(CGPoint)point;
当点击屏幕时用这个方法来判断点击位置是否在绘制线条上，如果在则返回具体的位置：`JVDrawingTouch`枚举值头部、中部和尾部（涂鸦除外）。

```objc
- (void)movePathWithStartPoint:(CGPoint)startPoint;
- (void)movePathWithEndPoint:(CGPoint)EndPoint;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;

- (void)movePathWithStartPoint:(CGPoint)startPoint isSelected:(BOOL)isSelected;
- (void)movePathWithEndPoint:(CGPoint)EndPoint isSelected:(BOOL)isSelected;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint
                     currentPoint:(CGPoint)currentPoint
                       isSelected:(BOOL)isSelected;
```
对于非涂鸦线条来说，编辑可以是平移也可以拖拽头部和尾部，以上6个方法分别对应选中和非选中状态下的三种编辑方法。

	- (void)moveGrafiitiPathPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;
这是对涂鸦的平移方法，涂鸦只能平移。

	- (void)addToTrack;
	- (BOOL)revokeUntilHidden;
这是添加轨迹和撤销的方法，当没有操作可供撤销时撤销操作就成了删除方法了。

上面只是简单介绍了这些方法是干什么的，但知道怎么用是不够的，你的需求可能跟我绘制的形状有出入，这样就只能对具体绘制的方法做一些修改或者添加了。我接下来也会对这些shape做一些添加和修改，比如在双箭头和双杠中间添加文字，旋转的时候也能跟着转。

以上如有帮助欢迎右上角star