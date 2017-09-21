//
//  YJMoveCellTableview.h
//  YJMoveCellTableView
//
//  Created by cherry on 2017/9/18.
//  Copyright © 2017年 YaoJing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YJMoveCellTableview;

@protocol yjMoveCellTableViewDataSource <UITableViewDataSource>
@required

/**
 *  获取tableView的数据源数组
 */
- (NSArray *)dataSourceArrayInTableView:(YJMoveCellTableview *)tableView;
/**
 *  返回移动之后调换后的数据源
 */
- (void)tableView:(YJMoveCellTableview *)tableView newDataSourceArrayAfterMove:(NSArray *)newDataSourceArray;

@end


@protocol yjMoveCellTableViewDelegate <UITableViewDelegate>
@optional
/**
 *  将要开始移动indexPath位置的cell
 */
- (void)tableView:(YJMoveCellTableview *)tableView willMoveCellAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  完成一次从fromIndexPath cell到toIndexPath cell的移动
 */
- (void)tableView:(YJMoveCellTableview *)tableView didMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
/**
 *  结束移动cell在indexPath
 */
- (void)tableView:(YJMoveCellTableview *)tableView endMoveCellAtIndexPath:(NSIndexPath *)indexPath;



@end

@interface YJMoveCellTableview : UITableView

@property (nonatomic, weak) id<yjMoveCellTableViewDataSource> dataSource;
@property (nonatomic, weak) id<yjMoveCellTableViewDelegate> delegate;
/**
 *  长按手势最小触发时间，默认1.0，最小0.2
 */
@property (nonatomic, assign) CGFloat gestureMinimumPressDuration;
/**
 *  自定义可移动cell的截图样式
 */
@property (nonatomic, copy) void(^drawMovalbeCellBlock)(UIView *movableCell);
/**
 *  是否允许拖动到屏幕边缘后，开启边缘滚动，默认YES
 */
@property (nonatomic, assign) BOOL canEdgeScroll;
/**
 *  边缘滚动触发范围，默认150，越靠近边缘速度越快
 */
@property (nonatomic, assign) CGFloat edgeScrollRange;


@end
