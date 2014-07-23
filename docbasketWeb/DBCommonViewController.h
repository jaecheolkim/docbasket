//
//  DBCommonViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/26/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

#import "GlobalValue.h"
#import "Docbasket.h"
#import "docbasketURLInfo.h"
#import "DocbaketAPIClient.h"
#import "DBKLocationManager.h"

@interface DBCommonViewController : UIViewController


- (void)handleTakePhotoButtonPressed:(id)sender;
- (UIImage*)rescaleImage:(UIImage*)image toSize:(CGSize)newSize;
//- (void)badgeNumber:(int)badgeValue;

- (void)setNaviBarTitle:(NSString *)title;

@end
