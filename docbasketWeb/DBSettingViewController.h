//
//  DBSettingViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/10/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalValue.h"
#import "DBCommonViewController.h"

@interface DBSettingViewController : DBCommonViewController
< UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
