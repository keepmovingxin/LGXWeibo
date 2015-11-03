//
//  CommentCell.h
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class CommentModel;
@interface CommentCell : UITableViewCell<RTLabelDelegate>{
   
   UIImageView *_userImage;
   UILabel *_nickLabel;
   UILabel *_createLabel;
   RTLabel *_contentLabel;
}

// 计算评论单元格的高度
+ (float)getCommentHeight:(CommentModel *)commentModel;

@property(nonatomic,retain)CommentModel *commentModel;

@end
