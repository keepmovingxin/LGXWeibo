//
//  DetailViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "DetailViewController.h"
#import "WeiboModel.h"
#import "WeiboView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "UIUtils.h"
#import "RegexKitLite.h"
#import "CommentTableView.h"
#import "CommentModel.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"微博正文";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self _initView];
   
    [self loadData];
   
}

// 初始化子视图
- (void)_initView{
   UIView *tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
   tableViewHeaderView.backgroundColor = [UIColor clearColor];
   
   //--------------用户头像userImageView---------------
   NSString *userImageUrl = _weiboModel.user.profile_image_url;
   self.userImageView.layer.cornerRadius = 5;
   self.userImageView.layer.masksToBounds = YES;
   [self.userImageView setImageWithURL:[NSURL URLWithString:userImageUrl]];
   
   //--------------用户昵称nickLabel---------------
   NSString *nickName = _weiboModel.user.screen_name;
   if (nickName != nil) {
      self.nickLabel.hidden = NO;
      self.nickLabel.text = nickName;
   }else{
      self.nickLabel.hidden = YES;
   }
   
   //----------发布时间createLabel----------
   NSString *createDate = _weiboModel.createDate;
   if (createDate != nil) {
      self.createLabel.hidden = NO;
      NSString *dateString = [UIUtils fomateString:createDate];
      self.createLabel.text = dateString;
   }else{
      self.createLabel.hidden = YES;
   }

   //---------------微博来源sourceLabel---------------
   NSString *source = _weiboModel.source;
   NSString *sourceString = [self parseSource:source];
   if (sourceString != nil) {
      self.sourceLabel.hidden = NO;
      sourceString = [NSString stringWithFormat:@"来自:%@",sourceString];
      self.sourceLabel.text = sourceString;
   }else{
      self.sourceLabel.hidden = YES;
   }
    
   [tableViewHeaderView addSubview:self.userBarView];
   // 设置tableView头视图高度
   tableViewHeaderView.height += 60;
   
   //微博视图
   _weiboView = [[WeiboView alloc] initWithFrame:CGRectZero];
   _weiboView.weiboModel = _weiboModel;
   // 获取微博视图高度
   float height = [WeiboView getWeiboViewHeight:_weiboModel isRepost:NO isDetail:YES];
   _weiboView.frame = CGRectMake(10, self.userBarView.bottom+10, kWeibo_Width_Detail, height);
   _weiboView.isDetail = YES;
   
   [tableViewHeaderView addSubview:_weiboView];
 
   tableViewHeaderView.height += (height+10);
   self.tableView.tableHeaderView = tableViewHeaderView;
   self.tableView.eventDelegate = self;
   [tableViewHeaderView release];
}

// 微博来源解析
- (NSString *)parseSource:(NSString *)source{
   NSString *regex = @">\\w+<";
   NSArray *sourceArray = [source componentsMatchedByRegex:regex];
   NSString *sourceString = nil;
   if (sourceArray.count > 0) {
      //>iPhone客户端<
      NSString *ret = sourceArray[0];
      // 替换法
      sourceString = [ret stringByReplacingOccurrencesOfString:@">" withString:@""];
      sourceString = [sourceString stringByReplacingOccurrencesOfString:@"<" withString:@""];
      // 截取法
      //      NSRange range = {1,ret.length-2};
      //      sourceString = [ret substringWithRange:range];
      
      return sourceString;
   }
   return nil;
}

#pragma mark - BaseTableView delegate
// 下拉
- (void)pullDown:(BaseTableView *)tableView {

//   [tableView performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:2];
   [self pullDownData];
}
// 上拉
- (void)pullUp:(BaseTableView *)tableView {
//   [tableView performSelector:@selector(reloadData) withObject:self afterDelay:2];
   [self pullUpData];
}
// 选中cell
- (void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
   NSLog(@"选中：%@",indexPath);
}

#pragma mark - load data
// 加载网络数据
- (void)loadData {
   NSString *weiboId = [_weiboModel.weiboId stringValue];
   if (weiboId.length == 0) {
      return;
   }
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20",@"count",weiboId,@"id", nil];
   [self.sinaweibo requestWithURL:@"comments/show.json" httpMethod:@"GET" params:params block:^(NSDictionary * result) {
      [self loadDataFinish:result];
   }];
}

// 加载网路数据完成调用
- (void)loadDataFinish:(NSDictionary *)result {
   NSArray *commentArray = [result objectForKey:@"comments"];
   NSMutableArray *comments = [NSMutableArray array];
   for (NSDictionary *dic in commentArray) {
      CommentModel *commentModel = [[CommentModel alloc] initWithDataDic:dic];
      [comments addObject:commentModel];
      [commentModel release];
   }
   if (commentArray.count >= 20) {
      self.tableView.isMore = YES;
   }else{
      self.tableView.isMore = NO;
   }
   // 记录顶端评论Id topCommentId，底端评论Id lastCommentId
   if (comments.count > 0) {
      CommentModel *topComment = [comments objectAtIndex:0];
      self.topCommentId = [topComment.id stringValue];
      
      CommentModel *lastComment = [comments lastObject];
      self.lastCommentId = [lastComment.id stringValue];
   }
   self.comments = comments;
   self.tableView.data = comments;
   self.tableView.commentDic = result;
   [self.tableView reloadData];
}

// 下拉加载最新微博数据
- (void)pullDownData{
   if (self.topCommentId.length == 0) {
      NSLog(@"评论Id为空！");
      return;
   }
   
   /*
    *since_id:若指定此参数，则返回ID比since_id大的评论（即比since_id时间晚的评论），默认为0。
    *count:单页返回的记录条数，默认为50。
    */
   NSString *weiboId = [_weiboModel.weiboId stringValue];
   if (weiboId.length == 0) {
      return;
   }
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20",@"count",weiboId,@"id",self.topCommentId,@"since_id", nil];
   
   // 获取当前微博的最新评论
   [self.sinaweibo requestWithURL:@"comments/show.json"
                       httpMethod:@"GET"
                           params:params
                            block:^(id result) {
                               [self pullDownDataFinish:result];
                            }];
   
}

// 下拉加载数据完成
- (void)pullDownDataFinish:(id)result{
   
   NSArray *commentArray = [result objectForKey:@"comments"];
   NSMutableArray *comments = [NSMutableArray arrayWithCapacity:commentArray.count];
   for (NSDictionary *commentDic in commentArray) {
      CommentModel *comment = [[CommentModel alloc] initWithDataDic:commentDic];
      [comments addObject:comment];
      [comment release];
   }
   
   // 更新顶端微博Id topWeiboId
   if (comments.count > 0) {
      CommentModel *topComment = [comments objectAtIndex:0];
      self.topCommentId = [topComment.id stringValue];
   }
   
   // 将已有评论追加到刷新评论的后面
   [comments addObjectsFromArray:self.comments];
   // 更新客户端评论数组
   self.comments = comments;
   // 更新tableView数据源
   self.tableView.data = comments;
   
   // 刷新tableView
   [self.tableView reloadData];
   // 弹回下拉
   [self.tableView doneLoadingTableViewData];
}

// 上拉加载最新微博数据
- (void)pullUpData{
   if (self.lastCommentId.length == 0) {
      NSLog(@"评论Id为空！");
      return;
   }
   
   /*
    *max_id:若指定此参数，则返回ID小于或等于max_id的评论，默认为0。
    *count:单页返回的记录条数，默认为50。
    */
   NSString *weiboId = [_weiboModel.weiboId stringValue];
   if (weiboId.length == 0) {
      return;
   }
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20",@"count",weiboId,@"id",self.lastCommentId,@"max_id", nil];
   
   // 获取当前微博的早些时间评论
   [self.sinaweibo requestWithURL:@"comments/show.json"
                       httpMethod:@"GET"
                           params:params
                            block:^(id result) {
                               [self pullUpDataFinish:result];
                            }];
   
}

// 上拉加载数据完成
- (void)pullUpDataFinish:(id)result{
   
   NSArray *commentArray = [result objectForKey:@"comments"];
   NSMutableArray *comments = [NSMutableArray arrayWithCapacity:commentArray.count];
   for (NSDictionary *commentDic in commentArray) {
      CommentModel *comment = [[CommentModel alloc] initWithDataDic:commentDic];
      [comments addObject:comment];
      [comment release];
   }
   
   // 更新底端微博Id lastWeiboId
   if (comments.count > 0) {
      CommentModel *lastComment = [comments lastObject];
      self.lastCommentId = [lastComment.id stringValue];
   }
   
   // 先移除最后一个元素，避免重复
   [self.comments removeLastObject];
   // 将微博追加到微博数组的后面
   [self.comments addObjectsFromArray:comments];
   
   // 更新tableView数据源
   self.tableView.data = self.comments;
   
   // 刷新UI
   if (commentArray.count >= 20) {
      self.tableView.isMore = YES;
   }else{
      self.tableView.isMore = NO;
   }
   [self.tableView reloadData];
}

- (void)refreshComment{
   // 使UI显示下拉
   [self.tableView refreshData];
   
   // 取数据
   [self pullDownData];
}

#pragma mark - Memery Manager
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_tableView release];
   [_userImageView release];
   [_nickLabel release];
   [_createLabel release];
   [_sourceLabel release];
   [_userBarView release];
   [_nickLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
   [self setUserImageView:nil];
   [self setNickLabel:nil];
   [self setCreateLabel:nil];
   [self setSourceLabel:nil];
   [self setUserBarView:nil];
   [self setNickLabel:nil];
    [super viewDidUnload];
}
@end
