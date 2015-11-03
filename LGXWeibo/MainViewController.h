//
//  MainViewController.h
//  LGXWeibo
//  主控制器
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface MainViewController : UITabBarController<SinaWeiboDelegate,UINavigationControllerDelegate>
{
   UIView *_tabbarView;
   UIImageView *_sliderView;
   UIImageView *_badgeView;
}

// 显示或隐藏_badgeView
- (void)showBadge:(BOOL)show;

// 显示或隐藏_tabbarView
- (void)showTabbar:(BOOL)show;


@end
