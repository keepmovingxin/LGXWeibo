//
//  HomeViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "HomeViewController.h"
#import "MainViewController.h"
#import "WeiboModel.h"
#import "UIFactory.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "DetailViewController.h"


@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"微博";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //绑定按钮
    UIBarButtonItem *bindItem = [[UIBarButtonItem alloc]initWithTitle:@"绑定账号" style:UIBarButtonItemStyleBordered target:self action:@selector(bindAction:) ];
    self.navigationItem.rightBarButtonItem = [bindItem autorelease];
    
    //注销按钮
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutAction:) ];
    self.navigationItem.leftBarButtonItem = [logoutItem autorelease];
   
   // 微博列表视图
   _tableView = [[WeiboTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44-49) style:UITableViewStylePlain];
   _tableView.eventDelegate = self;
   _tableView.hidden = YES;
   [self.view addSubview:_tableView];
    
    // 判断是否认证
    if (self.sinaweibo.isAuthValid) {
        // 加载微博列表数据
        [self loadWeiboData];
    }
   
   /*
   // -------模拟发送微博提示-------
   // 显示正在发送提示
   [super showHUD:@"正在发送" isDim:YES];
   // 发送成功提示
   [self performSelector:@selector(showCompleteHUD:) withObject:@"发送成功" afterDelay:2];
   */
   
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   
   // 开启DDmenu左滑、右滑菜单
   [self.appDelegate.menuCtrl setEnableGesture:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
   
   // 禁用DDmenu左滑、右滑菜单
   [self.appDelegate.menuCtrl setEnableGesture:NO];
}

#pragma mark - UI 操作
// 显示刷新的微博数视图
- (void) showNewWeiboCount:(int) count {
   if (barView == nil) {
      //创建视图
      barView = [[UIFactory createImageView:@"timeline_new_status_background.png"] retain];
      // 设置图片拉伸的位置
      UIImage *image = [barView.image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
      barView.image = image;
      barView.leftCapWidth = 5;
      barView.topCapHeight = 5;
      barView.frame = CGRectMake(5, -40, ScreenWidth-10, 40);
      [self.view addSubview:barView];
      
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
      label.tag = 102;
      label.backgroundColor = [UIColor clearColor];
      label.font = [UIFont systemFontOfSize:16.0f];
      label.textColor = [UIColor whiteColor];
      [barView addSubview:label];
      [label release];
   }
   
   if (count > 0) {
      // 设置内容
      UILabel *label = (UILabel *)[barView viewWithTag:102];
      label.text = [NSString stringWithFormat:@"%d条新微博",count];
      [label sizeToFit];
      label.origin = CGPointMake((barView.width - label.width)/2, (barView.height - label.height)/2);
      
      // 添加动画
      [UIView animateWithDuration:0.6 animations:^{
         barView.top = 5;
      } completion:^(BOOL finished) {
         if (finished) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:1];
            [UIView setAnimationDuration:0.6];
            barView.top = -40;
            [UIView commitAnimations];
         }
      }];
      
      // --------播放提示声音-------
      // 初始化本地文件url
      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
      NSURL *url = [NSURL fileURLWithPath:filePath];
      // 创建一个音频ID标示音频
      SystemSoundID soundId;
      // 为url地址注册系统声音
      AudioServicesCreateSystemSoundID((CFURLRef)url, &soundId);
      // 播放系统声音
      AudioServicesPlaySystemSound(soundId);
      // 播放震动
//      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
      
   }
   
   // 刷新完成后，隐藏未读微博视图_badgeView
   MainViewController *mainCtrl = (MainViewController *)self.tabBarController;   
//   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//   MainViewController *mainCtrl = (MainViewController *)appDelegate.mainCtrl;
   [mainCtrl showBadge:NO];
}

#pragma mark - UITableViewEvent delegate
- (void)pullDown:(BaseTableView *)tableView{
//   NSLog(@"加载网络数据！");
   [self pullDownData];
//   [tableView performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (void)pullUp:(BaseTableView *)tableView{
//   NSLog(@"上拉");
   [self pullUpData];
}

- (void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   NSLog(@"选中：%@",indexPath);
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
   // 跳转下一级
   WeiboModel *weiboModel = [self.weibos objectAtIndex:indexPath.row];
   DetailViewController *detailViewController = [[DetailViewController alloc] init];
   detailViewController.weiboModel = weiboModel;
   [self.navigationController pushViewController:detailViewController animated:YES];
   [detailViewController release];
}

#pragma mark - load Data

- (void)loadWeiboData{
   //显示加载提示视图
   [super showLoading:YES];
//   [super showHUD:@"加载中..." isDim:YES];
   
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"20" forKey:@"count"];
   
   // 获取当前登录用户及其所关注用户的最新微博
   [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                           params:params httpMethod:@"GET" delegate:self];
}

// 下拉加载最新微博数据
- (void)pullDownData{
   if (self.topWeiboId.length == 0) {
      NSLog(@"微博Id为空！");
      return;
   }
   
   /*
    *since_id:若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    *count:单页返回的记录条数，最大不超过100，默认为20。
    */
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20",@"count",self.topWeiboId,@"since_id", nil];
   
   // 获取当前登录用户及其所关注用户的最新微博
   // 使用带block的请求方法 跟首次请求区分
   [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                  httpMethod:@"GET"
                  params:params
                  block:^(id result) {
                     [self pullDownDataFinish:result];
                  }];

}

// 下拉加载数据完成
- (void)pullDownDataFinish:(id)result{
   
   NSArray *statuses = [result objectForKey:@"statuses"];
   NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:statuses.count];
   for (NSDictionary *statusesDic in statuses) {
      WeiboModel *weibo = [[WeiboModel alloc] initWithDataDic:statusesDic];
      [newArray addObject:weibo];
      [weibo release];
   }
   
   // 更新顶端微博Id topWeiboId
   if (newArray.count > 0) {
      WeiboModel *topWeibo = [newArray objectAtIndex:0];
      self.topWeiboId = [topWeibo.weiboId stringValue];
   }
   
   // 将已有微博追加到刷新微博的后面
   [newArray addObjectsFromArray:self.weibos];
   // 更新客户端微博数组
   self.weibos = newArray;
   // 更新tableView数据源
   self.tableView.data = newArray;
   
   // 刷新tableView
   [self.tableView reloadData];
   // 弹回下拉
   [self.tableView doneLoadingTableViewData];
   
   // 显示刷新的微博数
   int updateCount = statuses.count;
   [self showNewWeiboCount:updateCount];
}

// 上拉加载最新微博数据
- (void)pullUpData{
   if (self.lastWeiboId.length == 0) {
      NSLog(@"微博Id为空！");
      return;
   }
   
   /*
    *max_id:若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    *count:单页返回的记录条数，最大不超过100，默认为20。
    */
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20",@"count",self.lastWeiboId,@"max_id", nil];
   
   // 获取当前登录用户及其所关注用户的旧微博
   // 使用带block的请求方法 跟首次请求区分
   [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                       httpMethod:@"GET"
                           params:params
                            block:^(id result) {
                               [self pullUpDataFinish:result];
                            }];
   
}

// 上拉加载数据完成
- (void)pullUpDataFinish:(id)result{
   
   NSArray *statuses = [result objectForKey:@"statuses"];
   NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:statuses.count];
   for (NSDictionary *statusesDic in statuses) {
      WeiboModel *weibo = [[WeiboModel alloc] initWithDataDic:statusesDic];
      [newArray addObject:weibo];
      [weibo release];
   }
   
   // 更新底端微博Id lastWeiboId
   if (newArray.count > 0) {
      WeiboModel *lastWeibo = [newArray lastObject];
      self.lastWeiboId = [lastWeibo.weiboId stringValue];
   }
   
   // 先移除最后一个元素，避免重复
   [self.weibos removeLastObject];
   // 将微博追加到微博数组的后面
   [self.weibos addObjectsFromArray:newArray];

   // 更新tableView数据源
   self.tableView.data = self.weibos;
   
   // 刷新UI
   if (statuses.count >= 20) {
      self.tableView.isMore = YES;
   }else{
      self.tableView.isMore = NO;
   }
   [self.tableView reloadData];
}

- (void)refreshWeibo{
   // 使UI显示下拉
   [self.tableView refreshData];
   
   // 取数据
   [self pullDownData];
}

#pragma mark - SinaWeiboRequest Delegate
// 网络加载失败
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error{
   NSLog(@"网络加载失败:%@",error);
}

// 网络加载完成
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{
   
   //隐藏加载提示视图
   [super showLoading:NO];
//   [super hideHUD];
   self.tableView.hidden = NO;
   
   NSArray *statuses = [result objectForKey:@"statuses"];
   NSMutableArray *weibos = [NSMutableArray arrayWithCapacity:statuses.count];
   for (NSDictionary *statusesDic in statuses) {
      WeiboModel *weibo = [[WeiboModel alloc] initWithDataDic:statusesDic];
      [weibos addObject:weibo];
      [weibo release];
   }
   self.tableView.data = weibos;
   self.weibos = weibos;
   
   // 记录顶端微博Id topWeiboId，底端微博Id lastWeiboId
   if (weibos.count > 0) {
      WeiboModel *topWeibo = [weibos objectAtIndex:0];
      self.topWeiboId = [topWeibo.weiboId stringValue];
      
      WeiboModel *lastWeibo = [weibos lastObject];
      self.lastWeiboId = [lastWeibo.weiboId stringValue];
   }
   
   // 刷新tableView
   [self.tableView reloadData];
}


#pragma mark - Target Action
// 绑定微博
-(void)bindAction:(UIBarButtonItem *)buttonItem
{
    [self.sinaweibo logIn];
}

// 注销
-(void)logoutAction:(UIBarButtonItem *)buttonItem
{
    [self.sinaweibo logOut];
}

#pragma mark - Memery Manager
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
   [_tableView release];
    [super dealloc];
}

- (void) viewDidUnload
{
   [self setTableView:nil];
    
}
@end
