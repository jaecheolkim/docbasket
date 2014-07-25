//
//  DBBasketViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/3/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Docbasket.h"

#import "EBPhotoPagesDataSource.h"
#import "EBPhotoPagesDelegate.h"

@interface DBBasketViewController : UIViewController
<EBPhotoPagesDataSource, EBPhotoPagesDelegate>

@property (nonatomic,strong) NSString *basketID;
@property (strong, nonatomic) Docbasket *basket;

@end
