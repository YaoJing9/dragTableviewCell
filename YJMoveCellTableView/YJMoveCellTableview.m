//
//  YJMoveCellTableview.m
//  YJMoveCellTableView
//
//  Created by cherry on 2017/9/18.
//  Copyright © 2017年 YaoJing. All rights reserved.
//

#import "YJMoveCellTableview.h"

@interface YJMoveCellTableview ()

@property (nonatomic, strong) UILongPressGestureRecognizer *gesture;
@property (nonatomic, strong) NSMutableArray *tempDataSource;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *tempView;
@property (nonatomic, strong) CADisplayLink *edgeScrollTimer;

@end

@implementation YJMoveCellTableview

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        [self yj_initData];
        [self yj_addGesture];
    }
    return self;
}
 - (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
//        [self yj_initData];
        [self yj_addGesture];
    }
    return self;
}


- (void)yj_addGesture{

    _gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(yj_processGesture:)];
    _gesture.minimumPressDuration = 1.0f;
    _edgeScrollRange = 150.f;
    [self addGestureRecognizer:_gesture];

}

- (void)yj_processGesture:(UILongPressGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan://开始
            [self yj_gestureBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged://移动
            break;
        case UIGestureRecognizerStateEnded://结束
        case UIGestureRecognizerStateCancelled://取消
            [self yj_gestureEndedOrCancelled:gesture];
            break;
            
        default:
            break;
    }
}

- (void)yj_gestureBegan:(UILongPressGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    NSIndexPath *selectedIndexPath = [self indexPathForRowAtPoint:point];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self willMoveCellAtIndexPath:selectedIndexPath];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceArrayInTableView:)]) {
        _tempDataSource = [self.dataSource dataSourceArrayInTableView:self].mutableCopy;
    }
    [self yj_startEdgeScroll];
    _selectedIndexPath = selectedIndexPath;
    UITableViewCell *cell = [self cellForRowAtIndexPath:selectedIndexPath];

    _tempView = [self yj_snapshotViewWithInputView:cell];
    
    _tempView.frame = cell.frame;
    [self addSubview:_tempView];
    //隐藏cell
    cell.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        _tempView.center = CGPointMake(cell.center.x, cell.frame.origin.y);
    }];
}

- (void)yj_gestureChanged:(UILongPressGestureRecognizer *)gesture
{
    
    CGPoint point = [gesture locationInView:gesture.view];
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:point];
    if (currentIndexPath && ![_selectedIndexPath isEqual:currentIndexPath]) {
        //交换数据源和cell
        [self yj_updateDataSourceAndCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didMoveCellFromIndexPath:toIndexPath:)]) {
            [self.delegate tableView:self didMoveCellFromIndexPath:_selectedIndexPath toIndexPath:currentIndexPath];
        }
        _selectedIndexPath = currentIndexPath;
    }
    //让截图跟随手势
    _tempView.center = CGPointMake(_tempView.center.x, point.y);
}

- (void)yj_gestureEndedOrCancelled:(UILongPressGestureRecognizer *)gesture
{
    //返回交换后的数据源
    
    [self yj_stopEdgeScroll];

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:newDataSourceArrayAfterMove:)]) {
        [self.dataSource tableView:self newDataSourceArrayAfterMove:_tempDataSource.copy];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:endMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self endMoveCellAtIndexPath:_selectedIndexPath];
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:_selectedIndexPath];
    [UIView animateWithDuration:0.25 animations:^{
        _tempView.frame = cell.frame;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [_tempView removeFromSuperview];
        _tempView = nil;
    }];
}
- (void)yj_updateDataSourceAndCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([self numberOfSections] == 1) {
        //只有一组
        [_tempDataSource exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        //交换cell
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }else {
        //有多组
        
    
        
        
        id fromData = _tempDataSource[fromIndexPath.section][fromIndexPath.row];
        id toData = _tempDataSource[toIndexPath.section][toIndexPath.row];
        
        NSMutableArray *fromArray = [_tempDataSource[fromIndexPath.section] mutableCopy];
        [fromArray replaceObjectAtIndex:fromIndexPath.row withObject:toData];
        [_tempDataSource replaceObjectAtIndex:fromIndexPath.section withObject:fromArray];

        NSMutableArray *toArray = [_tempDataSource[toIndexPath.section] mutableCopy];
        [toArray replaceObjectAtIndex:toIndexPath.row withObject:fromData];
        [_tempDataSource replaceObjectAtIndex:toIndexPath.section withObject:toArray];
        //交换cell
        
        [self beginUpdates];
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
        [self endUpdates];
    }
}



- (UIView *)yj_snapshotViewWithInputView:(UIView *)inputView
{
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    return snapshot;
}

#pragma mark EdgeScroll

- (void)yj_startEdgeScroll
{
    _edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(yj_processEdgeScroll)];
    [_edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)yj_processEdgeScroll
{
    [self yj_gestureChanged:_gesture];
    CGFloat minOffsetY = self.contentOffset.y + _edgeScrollRange;
    CGFloat maxOffsetY = self.contentOffset.y + self.bounds.size.height - _edgeScrollRange;
    CGPoint touchPoint = _tempView.center;
    //处理上下达到极限之后不再滚动tableView，其中处理了滚动到最边缘的时候，当前处于edgeScrollRange内，但是tableView还未显示完，需要显示完tableView才停止滚动
    if (touchPoint.y < _edgeScrollRange) {
        if (self.contentOffset.y <= 0) {
            return;
        }else {
            if (self.contentOffset.y - 1 < 0) {
                return;
            }
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 1) animated:NO];
            _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y - 1);
        }
    }
    if (touchPoint.y > self.contentSize.height - _edgeScrollRange) {
        if (self.contentOffset.y >= self.contentSize.height - self.bounds.size.height) {
            return;
        }else {
            if (self.contentOffset.y + 1 > self.contentSize.height - self.bounds.size.height) {
                return;
            }
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 1) animated:NO];
            _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y + 1);
        }
    }
    //处理滚动
    CGFloat maxMoveDistance = 20;
    if (touchPoint.y < minOffsetY) {
        //cell在往上移动
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - moveDistance) animated:NO];
        _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y - moveDistance);
    }else if (touchPoint.y > maxOffsetY) {
        //cell在往下移动
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/_edgeScrollRange*maxMoveDistance;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + moveDistance) animated:NO];
        _tempView.center = CGPointMake(_tempView.center.x, _tempView.center.y + moveDistance);
    }
}

- (void)yj_stopEdgeScroll
{
    if (_edgeScrollTimer) {
        [_edgeScrollTimer invalidate];
        _edgeScrollTimer = nil;
    }
}

@end
