//
//  BaseTableView.m
//  LGXWeibo
//
//  Created by admin on 13-8-22.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
       [self _initView];
       self.isMore = YES;
    }
    return self;
}

// 使用Xib创建
- (void)awakeFromNib{
   [self _initView];
}

// 初始化子视图
- (void)_initView{
   
   _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
   _refreshHeaderView.delegate = self;
   _refreshHeaderView.backgroundColor = [UIColor clearColor];
   
   self.dataSource = self;
   self.delegate = self;
   self.refreshHeader = YES;
   
   _moreButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
   _moreButton.backgroundColor = [UIColor clearColor];
   _moreButton.frame = CGRectMake(0, 0, ScreenWidth, 40);
   _moreButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
   [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   [_moreButton setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
   [_moreButton addTarget:self action:@selector(loadMoreAction) forControlEvents:UIControlEventTouchUpInside];
   
   UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   activityView.frame = CGRectMake(100, 10, 20, 20);
   activityView.tag = 101;
   [activityView stopAnimating];
   [_moreButton addSubview:activityView];
   
   self.tableFooterView = _moreButton;
}

// 刷新数据
- (void)refreshData{
   //调用下拉显示加载方法
   [_refreshHeaderView initLoading:self];
}

// 复写setRefreshHeader方法
- (void)setRefreshHeader:(BOOL)refreshHeader{
   _refreshHeader = refreshHeader;
   if (_refreshHeader) {
      [self addSubview:_refreshHeaderView];
      [_refreshHeaderView release];
   }else{
      if ([_refreshHeaderView superview]) {
         [_refreshHeaderView removeFromSuperview];
      }
   }
}

// 开始加载提示
- (void)_startLoadMore {
   [_moreButton setTitle:@"正在加载..." forState:UIControlStateNormal];
   // 加载中禁用moreButton
   _moreButton.enabled = NO;
   UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[_moreButton viewWithTag:101];
   [activityView startAnimating];
}

// 停止加载提示
- (void)_stopLoadMore {
   if (self.data.count > 0) {
      _moreButton.hidden = NO;
      [_moreButton setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
      // 加载完启用moreButton
      _moreButton.enabled = YES;
      UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[_moreButton viewWithTag:101];
      [activityView stopAnimating];
      if (!self.isMore) {
         [_moreButton setTitle:@"没有更多了" forState:UIControlStateNormal];
         _moreButton.enabled = NO;
      }
   }else{
      _moreButton.hidden = YES;
   } 
}

// 复写reloadData方法，更新上拉加载提示
- (void)reloadData {
   [super reloadData];
   // 停止加载更多 提示
   [self _stopLoadMore];
}

#pragma mark - Actions
- (void)loadMoreAction {
   if ([self.eventDelegate respondsToSelector:@selector(pullUp:)]) {
      // 调用事件代理协议方法
      [self.eventDelegate pullUp:self];
      [self _startLoadMore];
   }
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return self.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
   return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   if ([self.eventDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
      
      [self.eventDelegate tableView:self didSelectRowAtIndexPath:indexPath];
   }
}

#pragma mark - 下拉刷新相关
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
   _reloading = YES;
   
}

// 停止加载，弹回下拉
- (void)doneLoadingTableViewData{
   _reloading = NO;
   [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

// 当滑动时，实时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
   [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
   
}

// 手指停止拖拽时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
   
   [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
   
   if (!self.isMore) {
      return;
   }
   CGFloat offset = scrollView.contentOffset.y;
   CGFloat contentHeight = scrollView.contentSize.height;
   // 当刚好滑至底部时，offset和contentHeight的差值是scrollView的高度
   float sub = contentHeight - offset;
   // 如果向上拉大于30，调用代理刷新方法
   if (scrollView.height - sub>30) {
      [self _startLoadMore];
      if ([self.eventDelegate respondsToSelector:@selector(pullUp:)]) {
         // 调用事件代理协议方法,上拉刷新
         [self.eventDelegate pullUp:self];
      }
   }
   
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉到一定距离，手指放开时调用
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
   
   [self reloadTableViewDataSource];
   
   //停止加载，弹回下拉
//   [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
   
   if ([self.eventDelegate respondsToSelector:@selector(pullDown:)]) {
      // 调用事件代理协议方法，下拉刷新
      [self.eventDelegate pullDown:self];
   }

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
   
   return _reloading;
   
}

//取得下拉刷新的时间
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
   
   return [NSDate date];   
}

@end
