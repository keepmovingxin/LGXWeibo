//
//  ThemeLabel.h
//  LGXWeibo
//
//  Created by admin on 13-8-19.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeLabel : UILabel

@property(nonatomic,copy)NSString *colorName;

- (id)initWithColorName:(NSString *)colorName;

@end
