//
//  CommentModel.m
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

- (void)setAttributes:(NSDictionary *)dataDic {
   // 将字典数据根据映射关系填充到当前对象相应的属性上
   [super setAttributes:dataDic];
   
   NSDictionary *statusDic = [dataDic objectForKey:@"status"];
   if (statusDic != nil) {
      WeiboModel *weibo = [[WeiboModel alloc] initWithDataDic:statusDic];
      self.weibo = weibo;
      [weibo release];
   }
   
   NSDictionary *userDic = [dataDic objectForKey:@"user"];
   if (userDic != nil) {
      UserModel *user = [[UserModel alloc] initWithDataDic:userDic];
      self.user = user;
      [user release];
   }
}

@end
