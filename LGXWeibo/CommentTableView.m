//
//  CommentTableView.m
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CommentTableView.h"
#import "CommentCell.h"
#import "CommentModel.h"

@implementation CommentTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
    }
    return self;
}

#pragma mark  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *identify = @"CommentCell";
   CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
   if (cell == nil) {
      cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] lastObject];
   }
   CommentModel *commentModel = [self.data objectAtIndex:indexPath.row];
   cell.commentModel = commentModel;
   
   return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   CommentModel *commentModel = [self.data objectAtIndex:indexPath.row];
   float height = [CommentCell getCommentHeight:commentModel];
   return height+40;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
   view.backgroundColor = [UIColor whiteColor];
   
   UILabel *commentCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
   commentCount.backgroundColor = [UIColor clearColor];
   commentCount.font = [UIFont boldSystemFontOfSize:16.0f];
   commentCount.textColor = [UIColor blueColor];
   NSNumber *total = [self.commentDic objectForKey:@"total_number"];
   commentCount.text = [NSString stringWithFormat:@"评论:%@",total];
   
   [view addSubview:commentCount];
   [commentCount release];
   
//   _repostCount = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
//   _repostCount.backgroundColor = [UIColor clearColor];
//   _repostCount.font = [UIFont boldSystemFontOfSize:16.0f];
//   _repostCount.textColor = [UIColor blueColor];
//   // 设置转发数的内容
//   NSNumber *count = [[[[self.commentDic objectForKey:@"comments"] objectAtIndex:0] objectForKey:@"status"] objectForKey:@"reposts_count"];
//   _repostCount.text = [NSString stringWithFormat:@"转发:%@",count];
//   [view addSubview:_repostCount];
   
   UIImageView *separeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, tableView.width, 1)];
   separeView.image = [UIImage imageNamed:@"userinfo_header_separator.png"];
   [view addSubview:separeView];
   [separeView release];
   
   return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   return 40;
}

@end
