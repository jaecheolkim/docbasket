//
//  DocbasketService.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/3/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "GlobalValue.h"
#import "Docbasket.h"
#import "DocbaketAPIClient.h"
#import "DBKLocationManager.h"
#import "PBSQLiteManager.h"

#define DBKSERVICE [DocbasketService sharedInstance]

@interface DocbasketService : NSObject

+(DocbasketService*)sharedInstance;

- (void)startmanager;
- (void)stopmanager;

- (void)pushLocalNotification:(NSString *)event;

- (void)loadBasketsOnMap;
@end
