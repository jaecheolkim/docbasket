//
//  DBSavedBasketViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DBCommonViewController.h"

@interface DBSavedBasketViewController : UIViewController
< UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
