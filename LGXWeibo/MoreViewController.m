//
//  MoreViewController.m
//  LGXWeibo
//
//  Created by admin on 13-8-12.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "MoreViewController.h"
#import "ThemeViewController.h"
#import "UIFactory.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
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
   return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *cellIdentifier = @"Cell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
      UILabel *textLabel = [UIFactory createLabel:kThemeListLabel];
      textLabel.frame = CGRectMake(10, 10, self.view.frame.size.width - 120,30);
      textLabel.backgroundColor = [UIColor clearColor];
      textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
      textLabel.tag = 100;
      [cell.contentView addSubview:textLabel];
   }
   UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:100];
   if (indexPath.row == 0) {
      textLabel.text = @"主题";
   }
   else if (indexPath.row == 1) {
      textLabel.text = @"设置";
   }
   
   return cell;
}

#pragma mark - UITableView Delegata
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
   if (indexPath.row == 0) {
      // 创建一个切换主题的视图控制器
      ThemeViewController *themeViewController = [[ThemeViewController alloc]init];
      // 跳转到切换主题的视图控制器
      [self.navigationController pushViewController:themeViewController animated:YES];
      [themeViewController release];
   }
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
