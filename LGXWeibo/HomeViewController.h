//
//  HomeViewController.h
//  LGXWeibo
//  首页控制器
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseViewController.h"
#import "WeiboTableView.h"

@class ThemeImageView;
@interface HomeViewController : BaseViewController<UITableViewEventDelegate,SinaWeiboRequestDelegate>{
   // 刷新微博数视图
   ThemeImageView *barView;
}

@property (retain, nonatomic) WeiboTableView *tableView;

// 最顶上的微博Id,上次刷新的最后一条微博Id
@property (nonatomic,copy) NSString *topWeiboId;

// 最底下的微博Id,该页最早一条微博Id
@property (nonatomic,copy) NSString *lastWeiboId;

//客户端所有微博
@property (nonatomic, retain) NSMutableArray *weibos;

// 刷新微博
- (void)refreshWeibo;

@end
