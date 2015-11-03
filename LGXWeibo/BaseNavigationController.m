//
//  BaseNavigationController.m
//  LGXWeibo
//
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseNavigationController.h"
#import "ThemeManager.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotification:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
      [super viewDidLoad];
      [self loadThemeImage];
   
   //----------------------轻扫手势-------------------------
   UISwipeGestureRecognizer *swipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipAction:)];
   // 监听向右轻扫
   swipGesture.direction = UISwipeGestureRecognizerDirectionRight;
   [self.view addGestureRecognizer:swipGesture];
   
//    float version = WXHLOSVersion(); // 获得当前设备的系统版本
//    if (version >= 5.0) {
//        UIImage *image = [UIImage imageNamed:@"navigationbar_background.png"];
//        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//    }
}

// 实现向右滑返回，手势监听方法
- (void)swipAction:(UISwipeGestureRecognizer *)gesture {
   if (self.viewControllers.count > 1) {
      if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
         [self popViewControllerAnimated:YES];
      }
   }
}

#pragma mark - NSNotification Actions
- (void)themeNotification:(NSNotification *)notification
{
   [self loadThemeImage];
}

- (void)loadThemeImage
{
   float version = WXHLOSVersion(); // 获得当前设备的系统版本
   if (version >= 5.0) {
      UIImage *image = [[ThemeManager shareInstance] getThemeImage:@"navigationbar_background.png"];
      [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
   }
   else{
      // 调用setNeedsDisplay会让渲染引擎异步调用drawRect方法
      [self.navigationBar setNeedsDisplay];
   }
}

#pragma mark - Memery Manager
-(void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeDidChangeNotification object:self];
   [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
