//
//  ThemeViewController.h
//  LGXWeibo
//
//  Created by admin on 13-8-15.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "BaseViewController.h"

@interface ThemeViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
   NSArray *themes;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
