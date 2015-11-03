//
//  WeiboView.m
//  LGXWeibo
//
//  Created by admin on 13-8-20.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "WeiboView.h"
#import "UIFactory.h"
#import "WeiboModel.h"
#import "UIImageView+WebCache.h"
#import "ThemeImageView.h"
#import "RegexKitLite.h"
#import "NSString+URLEncoding.h"
#import "UIUtils.h"

#define LIST_FONT   14.0f           //列表中文本字体
#define LIST_REPOST_FONT  13.0f;    //列表中转发的文本字体
#define DETAIL_FONT  18.0f          //详情的文本字体
#define DETAIL_REPOST_FONT 17.0f    //详情中转发的文本字体

@implementation WeiboView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self _initView];
       _parseText = [[NSMutableString alloc] init];
    }
    return self;
}

// 初始化子视图
- (void)_initView{
   // --------微博内容视图--------
   _textLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
   _textLabel.delegate = self;
   _textLabel.font = [UIFont systemFontOfSize:14.0f];
   // 设置链接的颜色
   _textLabel.linkAttributes = [NSDictionary dictionaryWithObject:@"#4595CB" forKey:@"color"];
   // 设置链接高亮的颜色
   _textLabel.selectedLinkAttributes = [NSDictionary dictionaryWithObject:@"darkGray" forKey:@"color"];
   [self addSubview:_textLabel];
   
    // --------微博图片视图--------
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = [UIImage imageNamed:@"page_image_loading.png"];
    //设置图片的内容显示模式：等比例缩/放（不会被拉伸或压缩）
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
   
   // --------转发的微博视图背景,使用主题ThemeImageView,根据主题变化-------
   _repostBackgroundView = [UIFactory createImageView:@"timeline_retweet_background.png"];
   // 拉伸图片,不改变尖角和圆角
   UIImage *image = [_repostBackgroundView.image stretchableImageWithLeftCapWidth:25 topCapHeight:10];
   _repostBackgroundView.image = image;
   // 切换主题会调用loadImage
   _repostBackgroundView.leftCapWidth = 25;
   _repostBackgroundView.topCapHeight = 10;
   _repostBackgroundView.backgroundColor = [UIColor clearColor];
   // 将背景插入到最下面
   [self insertSubview:_repostBackgroundView atIndex:0];
   
}

- (void)setWeiboModel:(WeiboModel *)weiboModel{
   if (_weiboModel != weiboModel) {
      [_weiboModel release];
      _weiboModel = [weiboModel retain];
   }
   
   // 创建转发微博视图,不能在_initView中创建会造成死循环
   if (_repostView == nil) {
      _repostView = [[WeiboView alloc] initWithFrame:CGRectZero];
      _repostView.isRepost = YES;
      // 设置转发的原微博isDetail设置成跟当前微博一样
//      _repostView.isDetail = self.isDetail;
      [self addSubview:_repostView];
   }
   
   // 替换超链接
   [self parseLink];
}

// 复写setIsDetail方法，设置的同时将转发的原微博isDetail设置成YES
- (void)setIsDetail:(BOOL)isDetail{
   if (_isDetail != isDetail) {
      _isDetail = isDetail;
   }
   if (_repostView != nil) {
      _repostView.isDetail = isDetail;
   }
}

// 解析超链接
- (void)parseLink{
   // 置空_parseText
   [_parseText setString:@""];
   
   // 判断是否是转发的微博
   if (_isRepost) {
      // 如果是将原微博作者昵称追加到微博前
      NSString *nickName = _weiboModel.user.screen_name;
      NSString *encodeName = [nickName URLEncodedString];
      [_parseText appendFormat:@"<a href='user://%@'>@%@</a>:",encodeName,nickName];
   }
   
   // 取得微博内容
   NSString *text = _weiboModel.text;
   
   // 解析替换超链接
   text = [UIUtils parseLink:text];
   
   // 追加到_parseText
   [_parseText appendString:text];
}

// layoutSubviews 展示数据、设置布局,可能被多次调用
- (void)layoutSubviews{
   [super layoutSubviews];
    
   //—————————————————微博内容_textLabel子视图——————————————————
   // 获取字体大小
   float fontSize = [WeiboView getFontSize:self.isDetail isRepost:self.isRepost];
   // 设置字体
   _textLabel.font = [UIFont systemFontOfSize:fontSize];
   _textLabel.frame = CGRectMake(0, 0, self.width, 20);
   if (self.isRepost) {
      _textLabel.frame = CGRectMake(10, 10, self.width - 20, 20);
   }

   _textLabel.text = _parseText;
   // 文本内容的尺寸
   CGSize textSize = _textLabel.optimumSize;
    // 设置label的高度为文本的高度，实现自适应高度
   _textLabel.height = textSize.height;
   
   //—————————————————转发的微博视图_repostView——————————————————
   // 转发的微博Model
    WeiboModel *repostWeibo = _weiboModel.relWeibo;
    if (repostWeibo != nil) {
        _repostView.hidden = NO;
        _repostView.weiboModel = repostWeibo;
       
       //获取微博的高度
       float height = [WeiboView getWeiboViewHeight:repostWeibo isRepost:YES isDetail:self.isDetail];
        _repostView.frame = CGRectMake(0, _textLabel.bottom, self.width, height);
    }else{
        _repostView.hidden = YES;
    }
    
    //—————————————————微博图片视图_imageView——————————————————
   if (self.isDetail) {
      // 中等图
      NSString *bmiddleImage = _weiboModel.bmiddleImage;
      if (bmiddleImage != nil && ![@"" isEqualToString:bmiddleImage]) {
         _imageView.hidden = NO;
         _imageView.frame = CGRectMake(10, _textLabel.bottom+10, 280, 200);
         
         //加载网络图片数据
         [_imageView setImageWithURL:[NSURL URLWithString:bmiddleImage]];
      }else{
         _imageView.hidden = YES;
      }
   }else{
      // 缩略图
      NSString *thumbnailImage = _weiboModel.thumbnailImage;
      if (thumbnailImage != nil && ![@"" isEqualToString:thumbnailImage]) {
         _imageView.hidden = NO;
         _imageView.frame = CGRectMake(10, _textLabel.bottom+10, 70, 80);
         
         //加载网络图片数据
         [_imageView setImageWithURL:[NSURL URLWithString:thumbnailImage]];
      }else{
         _imageView.hidden = YES;
      }
   }

    //—————————————————转发的微博视图背景_repostBackgroudView——————————————————
    if (self.isRepost) {
        _repostBackgroundView.hidden = NO;
        _repostBackgroundView.frame = self.bounds;
    }else{
        _repostBackgroundView.hidden = YES;
    }
}

#pragma mark - 计算
//获取字体大小
+ (float)getFontSize:(BOOL)isDetail isRepost:(BOOL)isRepost{
   float fontSize = 14.0f;
   
   if (!isDetail && !isRepost) {
      return LIST_FONT; //列表中文本字体
   }
   else if(!isDetail && isRepost){
      return LIST_REPOST_FONT; //列表中转发的文本字体
   }
   else if(isDetail && !isRepost){
      return DETAIL_FONT; //详情的文本字体
   }
   else if(isDetail && isRepost){
      return DETAIL_REPOST_FONT; //详情中转发的文本字体
   }
   
   return fontSize;
}

// 计算微博视图的高度
+ (CGFloat)getWeiboViewHeight:(WeiboModel *)weiboModel
                     isRepost:(BOOL)isRepost
                     isDetail:(BOOL)isDetail{
   /**
    *   实现思路：计算每个子视图的高度，然后相加。
    **/
   float height = 0;
   
   //--------------------计算微博内容text的高度------------------------
   //创建
   RTLabel *textLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
   float fontsize = [WeiboView getFontSize:isDetail isRepost:isRepost];
   textLabel.font = [UIFont systemFontOfSize:fontsize];
   //判断此微博是否显示在详情页面
   if (isDetail) {
      textLabel.width = kWeibo_Width_Detail; //微博在详情页面的宽度
   } else {
      textLabel.width = kWeibo_Width_List;  //微博在列表中的宽度
   }
   //判断此微博是否是转发的
   if (isRepost) {
      textLabel.width -= 20;
   }
   textLabel.text = weiboModel.text;
   
   height += textLabel.optimumSize.height;

   [textLabel release];
   
   //--------------------计算微博图片的高度------------------------
   if (isDetail) {
      // 中等图
      NSString *bmiddleImage = weiboModel.bmiddleImage;
      if (bmiddleImage != nil && ![@"" isEqualToString:bmiddleImage]) {
         height += (200+10);
      }
   }else{
      // 缩略图
      NSString *thumbnailImage = weiboModel.thumbnailImage;
      if (thumbnailImage != nil && ![@"" isEqualToString:thumbnailImage]) {
         height += (80+10);
      }
   }
   
   //--------------------计算转发微博视图的高度------------------------
   //转发的微博
   WeiboModel *relWeibo = weiboModel.relWeibo;
   if (relWeibo != nil) {
      //转发微博视图的高度,递归调用自己
      float repostHeight = [WeiboView getWeiboViewHeight:relWeibo isRepost:YES isDetail:isDetail];
      height += (repostHeight);
   }
   
   // 转发微博视图+40
   if (isRepost == YES) {
      height += 40;
   }
   
   return height;
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
