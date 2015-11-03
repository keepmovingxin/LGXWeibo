//
//  WeiboTableView.m
//  LGXWeibo
//
//  Created by admin on 13-8-22.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "WeiboTableView.h"
#import "WeiboCell.h"
#import "WeiboModel.h"
#import "WeiboView.h"

@implementation WeiboTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
    }
    return self;
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *identify = @"WeiboCell";
   WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
   if (cell == nil) {
      cell = [[[WeiboCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify] autorelease];
   }
   WeiboModel *weibo = [self.data objectAtIndex:indexPath.row];
   cell.weiboModel = weibo;
   
   return cell;
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
   WeiboModel *weibo = [self.data objectAtIndex:indexPath.row];
   // 计算微博的高度
   float height = [WeiboView getWeiboViewHeight:weibo isRepost:NO isDetail:NO];
   
   height += 50;
   
   return height;
}

@end
