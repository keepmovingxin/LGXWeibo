//
//  UIFactory.h
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeButton.h"
#import "ThemeImageView.h"
#import "ThemeLabel.h"

@interface UIFactory : NSObject

+ (ThemeButton *)createButton:(NSString *)imageName highlighted:(NSString *)highlightImageName;

+ (ThemeButton *)createButtonWithBackground:(NSString *)backgroundImageName
                      backgroundHighlighted:(NSString *)backgroundHighlightImageName;

+ (ThemeImageView *)createImageView:(NSString *)imageName;

+ (ThemeLabel *)createLabel:(NSString *)colorName;

@end
