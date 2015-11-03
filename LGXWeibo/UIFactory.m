//
//  UIFactory.m
//  LGXWeibo
//  工厂类 
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "UIFactory.h"

@implementation UIFactory

// 创建ThemeButton的工厂方法,好处：方便修改button类型
+ (ThemeButton *)createButton:(NSString *)imageName highlighted:(NSString *)highlightImageName{
   ThemeButton *button = [[ThemeButton alloc] initWithImage:imageName highlighted:highlightImageName];
   return [button autorelease];
}

+ (ThemeButton *)createButtonWithBackground:(NSString *)backgroundImageName
                      backgroundHighlighted:(NSString *)backgroundHighlightImageName{
   ThemeButton *button = [[ThemeButton alloc] initWithBackground:backgroundImageName highlightedBackground:backgroundHighlightImageName];
   return [button autorelease];
}

// 创建ThemeImageView的工厂方法,好处：方便修改ImageView类型
+ (ThemeImageView *)createImageView:(NSString *)imageName{
   ThemeImageView *imageView = [[ThemeImageView alloc] initWithImageName:imageName];
   return [imageView autorelease];
}

// 创建ThemeLabel的工厂方法,好处：方便修改Label类型
+ (ThemeLabel *)createLabel:(NSString *)colorName{
   ThemeLabel *label = [[ThemeLabel alloc] initWithColorName:colorName];
   return [label autorelease];
}
@end
