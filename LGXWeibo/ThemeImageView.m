//
//  ThemeImageView.m
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "ThemeImageView.h"
#import "ThemeManager.h"

@implementation ThemeImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// 使用Xib创建后，调用的初始化方法
- (void)awakeFromNib{
   [super awakeFromNib];
   
   // 向通知中心注册一条通知，监听kThemeDidChangeNotification
   [[NSNotificationCenter defaultCenter]
    addObserver:self
    selector:@selector(themeNotification:)
    name:kThemeDidChangeNotification object:nil];
}

- (id)initWithImageName:(NSString *)imageName{
   self = [self init];
   if (self != nil) {
      self.imageName = imageName;
   }
   return self;
}

-(id)init{
   self = [super init];
   if (self) {
      // 向通知中心注册一条通知，监听kThemeDidChangeNotification
      [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(themeNotification:)
       name:kThemeDidChangeNotification object:nil];
   }
   return self;
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

#pragma mark - NSNotification Actions
// 实现通知监听方法
- (void)themeNotification:(NSNotification *)notification{
   [self loadThemeImage];
}

// 加载图片到imageView上
- (void)loadThemeImage{
   // 如果imageName为空，直接返回
   if (self.imageName == nil) {
      return;
   }
   
   // 拿到主题管理类对象
   ThemeManager *themeManager = [ThemeManager shareInstance];
   // 通过主题管理类的getImage方法获取图片
   UIImage *image = [themeManager getThemeImage:_imageName];
   // 设置图片拉伸的点
   image = [image stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
   // 设置图片
   self.image = image;
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
