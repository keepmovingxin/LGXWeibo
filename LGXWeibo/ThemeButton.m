//
//  ThemeButton.m
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "ThemeButton.h"
#import "ThemeManager.h"

@implementation ThemeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithImage:(NSString *)imageName highlighted:(NSString *)highlightImageName{
   self = [self init];
   if (self) {
      self.imageName = imageName;
      self.highlightImageName = highlightImageName;
   }
   return self;
}

- (id)initWithBackground:(NSString *)backgroundImageName
   highlightedBackground:(NSString *)backgroundHighlightImageName{
   self = [self init];
   if (self) {
      self.backgroundImageName = backgroundImageName;
      self.backgroundHighlightImageName = backgroundHighlightImageName;
   }
   return self;
}

- (id)init{
   self = [super init];
   if (self) {
      // 向通知中心注册一条通知，监听kThemeDidChangeNotification切换主题通知
      [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(themeNotification:)
       name:kThemeDidChangeNotification object:nil];
   }
   return self;
}

#pragma mark - NSNotification Actions
// 实现通知监听方法
- (void)themeNotification:(NSNotification *)notification{
   [self loadThemeImage];
}

// 加载图片到button上
- (void)loadThemeImage{
   // 如果imageName为空，直接返回
   if (self.imageName == nil) {
      return;
   }
   
   // 拿到主题管理类对象
   ThemeManager *themeManager = [ThemeManager shareInstance];
   // 通过主题管理类的getImage方法获取图片
   UIImage *image = [themeManager getThemeImage:_imageName];
   UIImage *highlightImage = [themeManager getThemeImage:_highlightImageName];
   // 设置图片
   [self setImage:image forState:UIControlStateNormal];
   [self setImage:highlightImage forState:UIControlStateHighlighted];
   
   UIImage *backImage = [themeManager getThemeImage:_backgroundImageName];
   UIImage *backHighlightImage = [themeManager getThemeImage:_backgroundHighlightImageName];
   
   [self setBackgroundImage:backImage forState:UIControlStateNormal];
   [self setBackgroundImage:backHighlightImage forState:UIControlStateHighlighted];
}

#pragma mark - setter
// 复写set方法,使得其能设置图片
- (void)setImageName:(NSString *)imageName{
   if (_imageName != imageName) {
      [_imageName release];
      _imageName = [imageName copy];
   }
   // 重新加载图片
   [self loadThemeImage];
}

- (void)setHighlightImageName:(NSString *)highlightImageName{
   if (_highlightImageName != highlightImageName) {
      [_highlightImageName release];
      _highlightImageName = [highlightImageName copy];
   }
   [self loadThemeImage];
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName{
   if (_backgroundImageName != backgroundImageName) {
      [_backgroundImageName release];
      _backgroundImageName = [backgroundImageName copy];
   }
   [self loadThemeImage];
}

- (void)setBackgroundHighlightImageName:(NSString *)backgroundHighlightImageName{
   if (_backgroundHighlightImageName != backgroundHighlightImageName) {
      [_backgroundHighlightImageName release];
      _backgroundHighlightImageName = [backgroundHighlightImageName copy];
   }
   [self loadThemeImage];
}

#pragma mark - Memery Manager
- (void)dealloc{
   // 移除通知
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeDidChangeNotification object:nil];
   [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
