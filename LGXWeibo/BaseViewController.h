//
//  BaseViewController.h
//  LGXWeibo
//  基视图控制器
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@class MBProgressHUD;
@class AppDelegate;
@interface BaseViewController : UIViewController{
   // 加载提示视图
   UIView *_loadView;
}

// 是否要返回按钮
@property(nonatomic,assign)BOOL isBackButton;

// HUD加载提示视图
@property (nonatomic,retain) MBProgressHUD *hud;

// 拿到微博对象
- (SinaWeibo *)sinaweibo;
// 拿到AppDelegate对象
- (AppDelegate *)appDelegate;

// 显示提示
- (void)showLoading:(BOOL)show;
// 显示HUD提示
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim;
// 显示HUD完成提示
- (void)showCompleteHUD:(NSString *)title;
// 隐藏HUD提示
- (void)hideHUD;

@end
