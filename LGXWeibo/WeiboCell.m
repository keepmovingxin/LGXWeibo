//
//  WeiboCell.m
//  LGXWeibo
//
//  Created by admin on 13-8-20.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "WeiboCell.h"
#import "WeiboView.h"
#import "UIFactory.h"
#import "WeiboModel.h"
#import "UIImageView+WebCache.h"
#import "UIUtils.h"
#import "RegexKitLite.h"

@implementation WeiboCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       [self _initView];
    }
    return self;
}

/*
 UIImageView     *_userImage;    //用户头像视图
 UILabel         *_nickLabel;    //昵称
 UILabel         *_repostCountLabel; //转发数
 UILabel         *_commentLabel;     //回复数
 UILabel         *_sourceLabel;      //发布来源
 UILabel         *_createLabel;      //发布时间
 */
- (void)_initView{
   // 用户头像
   _userImage = [[UIImageView alloc] initWithFrame:CGRectZero];
   _userImage.backgroundColor = [UIColor clearColor];
   // 设置圆角
   _userImage.layer.cornerRadius = 5;
   _userImage.layer.borderWidth = 0.5;
   _userImage.layer.borderColor = [UIColor grayColor].CGColor;
   _userImage.layer.masksToBounds = YES;
   [self.contentView addSubview:_userImage];
   
   // 用户昵称,使用主题Label
//   _nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   _nickLabel = [UIFactory createLabel:kThemeListLabel];
   _nickLabel.backgroundColor = [UIColor clearColor];
   _nickLabel.font = [UIFont systemFontOfSize:14.0];
   [self.contentView addSubview:_nickLabel];
   
   //转发数
   _repostCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   _repostCountLabel.backgroundColor = [UIColor clearColor];
   _repostCountLabel.font = [UIFont systemFontOfSize:10.0];
   _repostCountLabel.textColor = [UIColor lightGrayColor];
   [self.contentView addSubview:_repostCountLabel];
   
   //评论数
   _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   _commentLabel.backgroundColor = [UIColor clearColor];
   _commentLabel.font = [UIFont systemFontOfSize:10.0];
   _commentLabel.textColor = [UIColor lightGrayColor];
   [self.contentView addSubview:_commentLabel];
   
   //发布来源
   _sourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   _sourceLabel.backgroundColor = [UIColor clearColor];
   _sourceLabel.font = [UIFont systemFontOfSize:10.0];
   _sourceLabel.textColor = [UIColor lightGrayColor];
   [self.contentView addSubview:_sourceLabel];
   
   //发布时间
   _createLabel = [[UILabel alloc] initWithFrame:CGRectZero];
   _createLabel.backgroundColor = [UIColor clearColor];
   _createLabel.font = [UIFont systemFontOfSize:10.0];
   _createLabel.textColor = [UIColor lightGrayColor];
   [self.contentView addSubview:_createLabel];
   
   // 微博视图
   _weiboView = [[WeiboView alloc] initWithFrame:CGRectZero];
   [self.contentView addSubview:_weiboView];
   
   //选中时的背景颜色
   UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
   selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"statusdetail_cell_sepatator.png"]];
   self.selectedBackgroundView = selectedBackgroundView;
   [selectedBackgroundView release];
}

- (void)layoutSubviews{
   [super layoutSubviews];
   // ——————————用户头像视图_userImage——————————
   _userImage.frame = CGRectMake(5, 5, 35, 35);
   // 头像链接
   NSString *userImageUrl = _weiboModel.user.profile_image_url;
   [_userImage setImageWithURL:[NSURL URLWithString:userImageUrl]];
   
   // ——————————用户昵称视图_nickLabel——————————
   _nickLabel.frame = CGRectMake(50, 3, 200, 20);
   _nickLabel.text = _weiboModel.user.screen_name;
   
   // ——————————发布时间_createLabel——————————
   // Thu Aug 22 15:37:48 +0800 2013
   //  E M d HH:mm:ss Z yyyy
   // 目标日期字符串：8-22 15:56  
   NSString *createDate = _weiboModel.createDate;
   if (createDate != nil) {
      _createLabel.hidden = NO;
//      NSDate *date = [UIUtils dateFromFomate:createDate formate:@"E M d HH:mm:ss Z yyyy"];
//      NSString *dateString = [UIUtils stringFromFomate:date formate:@"MM-dd HH:mm"];
      
      NSString *dateString = [UIUtils fomateString:createDate];
      _createLabel.text = dateString;
      _createLabel.frame = CGRectMake(250, 4, 60, 20);
      [_createLabel sizeToFit];
   }else{
      _createLabel.hidden = YES;
   }
   
  
   // ——————————微博视图_weiboView——————————
   _weiboView.weiboModel = _weiboModel;
   //获取微博视图的高度
   float height = [WeiboView getWeiboViewHeight:_weiboModel isRepost:NO isDetail:NO];
   _weiboView.frame = CGRectMake(50, _nickLabel.bottom+10, kWeibo_Width_List, height);
   
   // ——————————微博来源_sourceLabel——————————
   // <a href="http://app.weibo.com/t/feed/9ksdit" rel="nofollow">iPhone客户端</a> 
   NSString *source = _weiboModel.source;
   NSString *sourceString = [self parseSource:source];
   if (sourceString != nil) {
      _sourceLabel.hidden = NO;
      _sourceLabel.frame = CGRectMake(50, _weiboView.bottom, 140, 20);
      sourceString = [NSString stringWithFormat:@"来自:%@",sourceString];
      _sourceLabel.text = sourceString;
      [_sourceLabel sizeToFit];
   }else{
      _sourceLabel.hidden = YES;
   }
   
   // ——————————转发数_repostCountLabel——————————
   _repostCountLabel.frame = CGRectMake(220, _weiboView.bottom, 50, 20);
   NSString *repostsCount = [NSString stringWithFormat:@"转发(%@)",_weiboModel.repostsCount];
   _repostCountLabel.text = repostsCount;
   _repostCountLabel.textAlignment = NSTextAlignmentRight;
   [_repostCountLabel sizeToFit];
   
   // ——————————评论数_commentLabel——————————
   _commentLabel.frame = CGRectMake(270, _weiboView.bottom, 50, 20);
   NSString *commentsCount = [NSString stringWithFormat:@"评论(%@)",_weiboModel.commentsCount];
   _commentLabel.text = commentsCount;
   _commentLabel.textAlignment = NSTextAlignmentLeft;
   [_commentLabel sizeToFit];
   
}

// 微博来源
- (NSString *)parseSource:(NSString *)source{
   NSString *regex = @">\\w+<";
   NSArray *sourceArray = [source componentsMatchedByRegex:regex];
   NSString *sourceString = nil;
   if (sourceArray.count > 0) {
      //>iPhone客户端<
      NSString *ret = sourceArray[0];
      // 替换法
      sourceString = [ret stringByReplacingOccurrencesOfString:@">" withString:@""];
      sourceString = [sourceString stringByReplacingOccurrencesOfString:@"<" withString:@""];
      // 截取法
//      NSRange range = {1,ret.length-2};
//      sourceString = [ret substringWithRange:range];
   
      return sourceString;
   }
   return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
