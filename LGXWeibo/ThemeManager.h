//
//  ThemeManager.h
//  LGXWeibo
//  主题管理类 
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kThemeDidChangeNotification @"kThemeDidChangeNotification"

@interface ThemeManager : NSObject

// 当前使用的主题名称
@property(nonatomic,retain)NSString *themeName;
//主题配置 theme.plist文件
@property(nonatomic,retain)NSDictionary *themesPlist;
// Label字体颜色配置 fontColor.plist文件
@property(nonatomic,retain)NSDictionary *fontColorPlist;

// 单例模式
+(ThemeManager *)shareInstance;

// 获取当前主题下，图片名对应的图片
-(UIImage *)getThemeImage:(NSString *)imageName;

// 获取label对应名称的颜色
- (UIColor *)getColorWithName:(NSString *)name;

@end
