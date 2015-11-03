//
//  CommentCell.m
//  LGXWeibo
//
//  Created by admin on 13-8-24.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "CommentModel.h"
#import "UIUtils.h"
#import "NSString+URLEncoding.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
   _userImage = (UIImageView *)[self viewWithTag:100];
   _userImage.layer.cornerRadius = 5;
   _userImage.layer.masksToBounds = YES;
   _nickLabel = (UILabel *)[self viewWithTag:101];
   _createLabel = (UILabel *)[self viewWithTag:102];
   
   _contentLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
   _contentLabel.delegate = self;
   _contentLabel.font = [UIFont systemFontOfSize:14.0f];
   // 设置链接的颜色
   _contentLabel.linkAttributes = [NSDictionary dictionaryWithObject:@"#4595CB" forKey:@"color"];
   // 设置链接高亮的颜色
   _contentLabel.selectedLinkAttributes = [NSDictionary dictionaryWithObject:@"darkGray" forKey:@"color"];
   [self.contentView addSubview:_contentLabel];
}

- (void)layoutSubviews {
   [super layoutSubviews];
   
   NSString *imageUrl = self.commentModel.user.profile_image_url;
   [_userImage setImageWithURL:[NSURL URLWithString:imageUrl]];
   
   _nickLabel.text = self.commentModel.user.screen_name;
   _createLabel.text = [UIUtils fomateString:self.commentModel.created_at];
   
   _contentLabel.frame = CGRectMake(_userImage.right+10, _nickLabel.bottom+5, 240, 21);
   NSString *contentText = self.commentModel.text;
   // 解析超链接
   NSString *prarseText = [UIUtils parseLink:contentText];
   _contentLabel.text = prarseText;
   _contentLabel.height = _contentLabel.optimumSize.height;
}

+ (float)getCommentHeight:(CommentModel *)commentModel{
   RTLabel *rt = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, 240, 0)];
   rt.font = [UIFont systemFontOfSize:14.0f];
   rt.text = commentModel.text;
   return rt.optimumSize.height;
}

#pragma mark - RTLabel delegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url{
   NSString *absoluteString = [url absoluteString];
   if ([absoluteString hasPrefix:@"user"]) {
      NSString *urlString = [url host];
      urlString = [urlString URLDecodedString];
      NSLog(@"用户: %@",urlString);
   }
   else if([absoluteString hasPrefix:@"http"])
   {
      NSString *urlString = [url host];
      urlString = [urlString URLDecodedString];
      NSLog(@"链接: %@",urlString);
   }
   else if([absoluteString hasPrefix:@"topic"])
   {
      NSString *urlString = [url host];
      urlString = [urlString URLDecodedString];
      NSLog(@"话题: %@",urlString);
   }
}

@end
