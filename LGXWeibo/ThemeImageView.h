//
//  ThemeImageView.h
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeImageView : UIImageView

//图片名称
@property(nonatomic,copy)NSString *imageName;

// 拉伸图片的左边距和上边距
@property(nonatomic,assign)int leftCapWidth;
@property(nonatomic,assign)int topCapHeight;

- (id)initWithImageName:(NSString *)imageName;

@end
