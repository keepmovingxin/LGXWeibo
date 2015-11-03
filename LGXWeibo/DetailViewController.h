//
//  DetailViewController.h
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseViewController.h"
#import "CommentTableView.h"

@class WeiboModel;
@class WeiboView;
@interface DetailViewController : BaseViewController<UITableViewEventDelegate>{
   WeiboView *_weiboView;
}

@property (nonatomic,retain) WeiboModel *weiboModel;
@property (retain, nonatomic) IBOutlet CommentTableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *userBarView;
@property (retain, nonatomic) IBOutlet UIImageView *userImageView;
@property (retain, nonatomic) IBOutlet UILabel *nickLabel;
@property (retain, nonatomic) IBOutlet UILabel *createLabel;
@property (retain, nonatomic) IBOutlet UILabel *sourceLabel;

// 最顶上的评论Id,上次刷新的最后一条评论Id
@property (nonatomic,copy) NSString *topCommentId;

// 最底下的评论Id,该页最早一条评论Id
@property (nonatomic,copy) NSString *lastCommentId;

//客户端所有评论
@property (nonatomic, retain) NSMutableArray *comments;

// 刷新评论
- (void)refreshComment;

@end
