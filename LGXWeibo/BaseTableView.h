//
//  BaseTableView.h
//  LGXWeibo
//  基表视图
//  Created by admin on 13-8-22.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class BaseTableView;
@protocol UITableViewEventDelegate <NSObject>
@optional
// 下拉
- (void)pullDown:(BaseTableView *)tableView;
// 上拉
- (void)pullUp:(BaseTableView *)tableView;
// 选中cell
- (void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BaseTableView : UITableView<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>{
   
   // 下拉刷新控件
   EGORefreshTableHeaderView *_refreshHeaderView;
   
   BOOL _reloading;
   
   UIButton *_moreButton;
   
}

// 是否需要下拉刷新
@property(nonatomic,assign)BOOL refreshHeader;
// 为tableView提供数据
@property(nonatomic,retain) NSArray *data;
// 声明事件代理
@property(nonatomic,assign)id<UITableViewEventDelegate>eventDelegate;
// 是否还有下一页(更多)
@property(nonatomic,assign)BOOL isMore;

// 下拉回弹方法
- (void)doneLoadingTableViewData;

// 刷新数据
- (void)refreshData;

@end
