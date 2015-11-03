//
//  MainViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "MessageViewController.h"
#import "ProfileViewController.h"
#import "DiscoverViewController.h"
#import "MoreViewController.h"
#import "BaseNavigationController.h"
#import "UIFactory.h"
#import "ThemeButton.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBar setHidden:YES];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	
   //初始化子视图控制器
    [self _initViewController];
   
   // 初始化自定义TabBar
    [self _initTabbarView];
   
   // 每60秒调用一次请求未读微博数据
   [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerActoin:) userInfo:nil repeats:YES];
}

// 显示或隐藏_badgeView
- (void)showBadge:(BOOL)show {
   _badgeView.hidden = !show;
}

// 显示或隐藏_tabbarView
- (void)showTabbar:(BOOL)show{
   [UIView animateWithDuration:0.35 animations:^{
      if (show) {
         _tabbarView.left = 0;
      }else{
         _tabbarView.left = -ScreenWidth;
      }
   }];
   [self _resizeView:show];
}

#pragma mark - Memery Manager
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
// 根据TabbarView显示以否，重新设置子视图的高度
- (void)_resizeView:(BOOL)showTabbar {
   // 遍历子视图
   for (UIView *subView in self.view.subviews) {
      if ([subView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
         if (showTabbar) {
            subView.height = ScreenHeight-49-20;
         }else{
            // DDMenu坐标从20开始
            subView.height = ScreenHeight-20;
         }
      }
   }
}

//初始化子视图控制器
- (void) _initViewController{
    HomeViewController *home = [[[HomeViewController alloc]init] autorelease];
    MessageViewController *message = [[[MessageViewController alloc]init] autorelease];
    ProfileViewController *profile = [[[ProfileViewController alloc]init] autorelease];
    DiscoverViewController *discover = [[[DiscoverViewController alloc]init] autorelease];
    MoreViewController *more = [[[MoreViewController alloc]init] autorelease];
    
    NSArray *views = @[home,message,profile,discover,more];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:5];
    for (UIViewController *viewController in views) {
        BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:viewController];
        [viewControllers addObject:nav];
        [nav release];
        nav.delegate = self;
    }
    self.viewControllers = viewControllers;
}

// 初始化自定义TabBar
- (void) _initTabbarView{
    // -20 是因为使用DDMenuController的View坐标下移20
    _tabbarView = [[UIView alloc]initWithFrame:(CGRect){0,ScreenHeight-49-20,320,49}];
//    [_tabbarView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]]];
   [self.view addSubview:_tabbarView];
   
   // 使用ThemeImageView实现tabbarView的主题切换
   UIImageView *tabbarGroundImage = [UIFactory createImageView:@"tabbar_background.png"];
   tabbarGroundImage.frame = _tabbarView.bounds;
   [_tabbarView addSubview:tabbarGroundImage];
   
    NSArray *background = @[@"tabbar_home.png",@"tabbar_message_center.png",@"tabbar_profile.png",@"tabbar_discover.png",@"tabbar_more.png"];
    
    NSArray *highlightBackground = @[@"tabbar_home_highlighted.png",@"tabbar_message_center_highlighted.png",@"tabbar_profile_highlighted.png",@"tabbar_discover_highlighted.png",@"tabbar_more_highlighted.png"];
    
    for (int i = 0 ; i < background.count ; i++ ) {
        NSString *backImage = background[i];
        NSString *highlightImage = highlightBackground[i];
        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
       
       // 使用自定义主题button替换UIButton
//       ThemeButton *button = [[ThemeButton alloc] initWithImage:backImage highlighted:heightImage];
       
       //使用工厂方法创建button
        UIButton *button = [UIFactory createButton:backImage highlighted:highlightImage];
        // 点击后高亮闪光
        button.showsTouchWhenHighlighted = YES;
        button.frame = CGRectMake((64-30) / 2 + (i * 64), (49 - 30) / 2, 30, 30);
        button.tag = i;
//        [button setImage:[UIImage imageNamed: backImage] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed: highlightImage] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        
        [_tabbarView addSubview:button];
    }
   // tabbar底下的滑动视图
   _sliderView = [[UIFactory createImageView:@"tabbar_slider.png"] retain];
   _sliderView.backgroundColor = [UIColor clearColor];
   _sliderView.frame = CGRectMake((64-15)/2, 5, 15, 44);
   [_tabbarView addSubview:_sliderView];
}

// 请求数据完成后调用
- (void)refreshUnReadView:(NSDictionary *)result{
   //未读微博数
   NSNumber *status = [result objectForKey:@"status"];
   
   // 创建视图
   if (_badgeView == nil) {
      _badgeView = [UIFactory createImageView:@"main_badge.png"];
      _badgeView.frame = CGRectMake(64-25, 5, 20, 20);
      [_tabbarView addSubview:_badgeView];
      
      UILabel *badgeLabel = [[UILabel alloc] initWithFrame:_badgeView.bounds];
      badgeLabel.backgroundColor = [UIColor clearColor];
      badgeLabel.textColor = [UIColor purpleColor];
      badgeLabel.textAlignment = NSTextAlignmentCenter;
      badgeLabel.font = [UIFont boldSystemFontOfSize:10.0f];
      badgeLabel.tag = 105;
      [_badgeView addSubview:badgeLabel];
      [badgeLabel release];
   }
   // 判断并填充内容
   int count = [status intValue];
   if (count > 0) {
      UILabel *badgeLabel = (UILabel *)[_badgeView viewWithTag:105];
      if (count > 99) {
         count = 99;
      }
      badgeLabel.text = [NSString stringWithFormat:@"%d",count];
      [badgeLabel sizeToFit];
      badgeLabel.origin = CGPointMake((_badgeView.width - badgeLabel.width)/2, (_badgeView.height - badgeLabel.height)/2);
      _badgeView.hidden = NO;
   }else{
      _badgeView.hidden = YES;
   }
}

#pragma mark - data
// 请求未读微博数目的方法
- (void)loadUnReadData{
   // 取得微博对象
   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   SinaWeibo *sinaweibo = appDelegate.sinaweibo;
   // 请求未读微博数据
   [sinaweibo requestWithURL:@"remind/unread_count.json"
                  httpMethod:@"GET"
                      params:nil
                       block:^(NSDictionary *result) {
                          [self refreshUnReadView:result];
                  }];
}

#pragma mark - 
#pragma  mark  Target Action
// 控制TabBarItem跳转
- (void) selectTab:(UIButton *) button{
    
   float x = button.left + (button.width - _sliderView.width)/2;
   // 动画
   [UIView animateWithDuration:0.2 animations:^{
      _sliderView.left = x;
   }];
   
   // 判断是否重复点击tab按钮
   if (button.tag == self.selectedIndex && button.tag == 0) {
      UINavigationController *homeNav = [self.viewControllers objectAtIndex:0];
      HomeViewController *home = [homeNav.viewControllers objectAtIndex:0];
      // 刷新微博
      [home refreshWeibo];
   }
   
   self.selectedIndex = button.tag;
}

- (void)timerActoin:(NSTimer *)timer{
   // 调用请求未读微博数目的方法
   [self loadUnReadData];
}

#pragma mark - UINavigationController delegate
// 监听NavigationController是否push到子视图控制器，是则隐藏TabbarView，否就显示TabbarView
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
   // 取得导航控制器子控制器的个数
   int count = navigationController.viewControllers.count;
   if (count == 2) {
      [self showTabbar:NO];
   }else if(count == 1){
      [self showTabbar:YES];
   }
}

#pragma mark - 
#pragma mark  SinaWeiboDelegate
// 微博绑定成功后调用
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    // 保存认证数据到本地
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 微博注销后调用
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    // 移除本地认证数据
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"logInDidFailWithError");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"accessTokenInvalidOrExpired");
}

@end
