//
//  ThemeManager.m
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "ThemeManager.h"

static ThemeManager *sigleton = nil;

@implementation ThemeManager

+(ThemeManager *)shareInstance{
   if (sigleton == nil) {
      @synchronized(self){
         sigleton = [[ThemeManager alloc]init];
      }
   }
   return sigleton;
}

-(id)init
{
   self = [super init];
   if (self) {
      // 获取plist文件数据
      NSString *themePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
      self.themesPlist = [NSDictionary dictionaryWithContentsOfFile:themePath];
      // 默认为nil
      self.themeName = nil;
   }
   return self;
}

// 切换主题时，会调用此方法设置主题名称
-(void)setThemeName:(NSString *)themeName{
   if (_themeName != themeName) {
      [_themeName release];
      _themeName = [themeName copy];
   }
   
   // 切换主题，重新加载当前主题下的字体配置文件
   NSString *themeDir = [self getThemePath];
   NSString *fontColorPath = [themeDir stringByAppendingPathComponent:@"fontColor.plist"];
   self.fontColorPlist = [NSDictionary dictionaryWithContentsOfFile:fontColorPath];
}

// 获取主题目录
- (NSString *)getThemePath{
   if (self.themeName == nil) {
      // 默认主题，返回根路径
      NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
      return resourcePath;
   }
   
   // 取得主题包路径 如：Skins/blue
   NSString *themePath = [self.themesPlist objectForKey:_themeName];
   // 程序包的根路径
   NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
   // 完整的主题路径
   NSString *path = [resourcePath stringByAppendingPathComponent:themePath];
   
   return path;
}

// 返回当前主题下，图片名对应的图片
- (UIImage *)getThemeImage:(NSString *)imageName{
   if (imageName.length == 0) {
      return nil;
   }
   // 获取主题目录
   NSString *themePath = [self getThemePath];
   // imageName在当前主题的路径
   NSString *imagePath =[themePath stringByAppendingPathComponent:imageName];
   
   UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
   
   return image;
}

// 根据label名称获取颜色
- (UIColor *)getColorWithName:(NSString *)name{
   if (name.length == 0) {
      return nil;
   }
   // 返回三色值 如：88,193,105
   NSString *rgb = [_fontColorPlist objectForKey:name];
   NSArray *rgbs = [rgb componentsSeparatedByString:@","];
   if (rgbs.count == 3) {
      float r = [rgbs[0] floatValue];
      float g = [rgbs[1] floatValue];
      float b = [rgbs[2] floatValue];
      UIColor *color = Color(r, g, b, 1);
      return color;
   }
   return nil;
}

#pragma mark - sigleton setting 
// 单例模式,限制当前对象创建多实例
+ (id)allocWithZone:(NSZone *)zone{
   @synchronized(self){
      if (sigleton == nil) {
         sigleton = [super allocWithZone:zone];
      }
   }
   return sigleton;
}

+ (id)copyWithZone:(NSZone *)zone{
   return self;
}

- (id)retain{
   return self;
}

- (unsigned)retainCount{
   return UINT_MAX;
}

- (oneway void)release{
}

-(id)autorelease{
   return self;
}

@end
