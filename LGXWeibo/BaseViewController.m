//
//  BaseViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "UIFactory.h"
#import "MBProgressHUD.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.isBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   NSArray *viewControllers = [self.navigationController viewControllers];
   // 判断是不是跟控制器
   if (viewControllers.count > 1 && self.isBackButton) {
      // 如不是，创建backButton
      UIButton *button = [UIFactory createButton:@"navigationbar_back.png"
                                     highlighted:@"navigationbar_back_highlighted.png"];
      button.frame = CGRectMake(0, 0, 24, 24);
      // 点击后高亮闪光
      button.showsTouchWhenHighlighted = YES;
      [button addTarget:self action:@selector(backAction)
               forControlEvents:UIControlEventTouchUpInside];
      UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
      self.navigationItem.leftBarButtonItem = [backItem autorelease];
   }
}

- (void)showLoading:(BOOL)show{
   if (_loadView == nil) {
      _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight/2 - 80, ScreenWidth, 20)];
      
      // loading视图
      UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      [activityView startAnimating];
      
      // 正在加载的Label
      UILabel *loadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      loadLabel.backgroundColor = [UIColor clearColor];
      loadLabel.text = @"正在加载...";
      loadLabel.font = [UIFont systemFontOfSize:16.0f];
      loadLabel.textColor = [UIColor blackColor];
      [loadLabel sizeToFit];
      
      loadLabel.left = (ScreenWidth - loadLabel.width)/2;
      activityView.right = loadLabel.left - 5;
      
      [_loadView addSubview:loadLabel];
      [_loadView addSubview:activityView];
      [loadLabel release];
      [activityView release];
   }
   
   if (show) {
      if (![_loadView superview]) {
         [self.view addSubview:_loadView];
      }
   }
   else{
      if ([_loadView superview]) {
         [_loadView removeFromSuperview];
      }
   }
}

// 显示HUD提示
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim{
   // 创建并显示HUD提示视图
   self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   // 设置提示文字
   self.hud.labelText = title;
   // 显示灰色背景笼罩
   self.hud.dimBackground = isDim;
}

// 显示HUD完成提示
- (void)showCompleteHUD:(NSString *)title{
   // 创建要显示的提示视图
   self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
   // 设置显示模式为显示CustomView
   self.hud.mode = MBProgressHUDModeCustomView;
   // 设置提示文字
   self.hud.labelText = title;
   // 延时1秒后隐藏
   [self.hud hide:YES afterDelay:1];
}

// 隐藏HUD提示
- (void)hideHUD{
   [self.hud hide:YES];
}

// 拿到微博对象
- (SinaWeibo *)sinaweibo
{
   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   SinaWeibo *sinaweibo = appDelegate.sinaweibo;
   return sinaweibo;
}

- (AppDelegate *)appDelegate {
   AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   return appDelegate;
}

#pragma mark - Target Action
- (void)backAction{
   [self.navigationController popViewControllerAnimated:YES];
}

// override 复写setTitle方法设置导航栏的标题样式
-(void) setTitle:(NSString *)title
{
   [super setTitle:title];
   
   //    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   //    titleLabel.textColor = [UIColor blackColor];
   UILabel *titleLabel = [UIFactory createLabel:kNavigationBarTitleLabel];
   titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
   titleLabel.backgroundColor = [UIColor clearColor];
   titleLabel.text = title;
   [titleLabel sizeToFit];
   

//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    titleLabel.textColor = [UIColor blackColor];
//    titleLabel.font = [UIFont systemFontOfSize:18.0f];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.text = title;
//    [titleLabel sizeToFit];

    
    self.navigationItem.titleView = titleLabel;// 工厂方法创建的无需release
   
}

#pragma mark - Memery Manager
- (void)dealloc {
   [super dealloc];
}
// 内存不足时调用，ios6.0之后或之前都会调用
- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   if (WXHLOSVersion() >= 6.0) {
      // 判断当前视图控制器的视图是否显示，windoow!=nil 显示，window==nil不显示
      if (self.view.window == nil) {
         self.view = nil;
         //兼容ios6.0之前的内存管理
         [self viewDidUnload];
      }
   }
}

// 6.0之前。内存不足时调用
- (void)viewDidUnload {
   [super viewDidUnload];
}

@end
