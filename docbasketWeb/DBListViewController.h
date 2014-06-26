//
//  DBListViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/27/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCommonViewController.h"

@interface DBListViewController : DBCommonViewController
< UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
