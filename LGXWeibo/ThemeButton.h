//
//  ThemeButton.h
//  LGXWeibo
//  主题button类
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeButton : UIButton

// Normal状态下的图片名称
@property(nonatomic,copy)NSString *imageName;
// 高亮状态下的图片名称
@property(nonatomic,copy)NSString *highlightImageName;

// Normal状态下的背景图片名称
@property(nonatomic,copy)NSString *backgroundImageName;
// 高亮状态下的背景图片名称
@property(nonatomic,copy)NSString *backgroundHighlightImageName;

- (id)initWithImage:(NSString *)imageName highlighted:(NSString *)highlightImageName;

- (id)initWithBackground:(NSString *)backgroundImageName
   highlightedBackground:(NSString *)backgroundHighlightImageName;

@end
