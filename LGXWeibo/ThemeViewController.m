//
//  ThemeViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "ThemeViewController.h"
#import "ThemeManager.h"
#import "UIFactory.h"

@interface ThemeViewController ()

@end

@implementation ThemeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.title = @"主题切换";
       // 通过主题管理类对象获取主题名称
       themes = [[ThemeManager shareInstance].themesPlist allKeys];
       [themes retain];
       // 注意retain一下，theme为对象属性，通过retain拿到它的对象所有权
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return [themes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *cellIdentifier = @"themeCell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
      UILabel *textLabel = [UIFactory createLabel:kThemeListLabel];
      textLabel.frame = CGRectMake(10, 10, self.view.frame.size.width - 120,30);
      textLabel.backgroundColor = [UIColor clearColor];
      textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
      textLabel.tag = 101;
      [cell.contentView addSubview:textLabel];
   }
//   cell.textLabel.text = [themes objectAtIndex:indexPath.row];
   UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:101];
   NSString *theme = themes[indexPath.row];
   textLabel.text = theme;
   
   // 拿到当前主题名称
   NSString *themeName = [ThemeManager shareInstance].themeName;
   if (themeName == nil) {
      themeName = @"默认";
   }
   if ([themeName isEqualToString:theme]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
   }
   else{
      cell.accessoryType = UITableViewCellAccessoryNone;
   }
   return cell;
}

#pragma mark - UITableView Delegata
// 切换主题
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
   NSString *themeName = [themes objectAtIndex:indexPath.row];
   if ([themeName isEqualToString:@"默认"]) {
      themeName = nil;
   }
   
   // 保存当前选择的主题到本地
   [[NSUserDefaults standardUserDefaults] setObject:themeName forKey:kThemeName];
   [[NSUserDefaults standardUserDefaults] synchronize];
   
   // 为主题管理类设置当前主题名
   [ThemeManager shareInstance].themeName = themeName;
   
   // 发送一个kThemeDidChangeNotification的通知，切换主题
   [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangeNotification object:themeName];
   // 刷新列表
   [tableView reloadData];
}

#pragma mark - Memery Manager
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
