//
//  ThemeLabel.m
//  LGXWeibo
//
//  Created by admin on 13-8-19.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "ThemeLabel.h"
#import "ThemeManager.h"

@implementation ThemeLabel

- (id)init{
   self = [super init];
   if (self != nil) {
      // 向通知中心注册一条通知，监听kThemeDidChangeNotification
      [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(themeNotification:)
       name:kThemeDidChangeNotification object:nil];
   }
   return self;
}

- (id)initWithColorName:(NSString *)colorName{
   self = [self init];
   if (self != nil) {
      self.colorName = colorName; //此处不能使用_colorName
   }
   return self;
}

#pragma mark - setter
// 复写set方法,使得其能设置字体颜色
- (void)setColorName:(NSString *)colorName{
   if (_colorName != colorName) {
      [_colorName release];
      _colorName = [colorName copy];
   }
   [self setColor];
}

// 设置字体颜色
- (void)setColor{
   UIColor *textColor = [[ThemeManager shareInstance] getColorWithName:_colorName];
   self.textColor = textColor;
}

#pragma mark - NSNotification Actions
// 实现通知监听方法
- (void)themeNotification:(NSNotification *)notification{
   [self setColor];
}

#pragma mark - Memery Manager
- (void)dealloc{
   // 移除通知，必须
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [_colorName release];
   [super dealloc];
}

@end
