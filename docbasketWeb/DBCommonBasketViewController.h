//
//  DBCommonBasketViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalValue.h"
#import "Docbasket.h"
#import "DBBasketViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+addOn.h"
//#import "RESideMenu.h"
#import "DBCommonViewController.h"

@interface DBCommonBasketViewController : DBCommonViewController
@property (nonatomic, strong) NSArray *baskets;

//filter= created | invited | saved | public(default)
- (void)checkMyBasket:(NSString*)filter completionHandler:(void (^)(BOOL success))block;
@end
