//
//  ParseHelper.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "ParseHelper.h"
@interface ParseHelper ()
{
    
}
@end


@implementation ParseHelper

#pragma mark - Class LifeCycle

+(ParseHelper*)sharedInstance
{
    static ParseHelper* serviceMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceMgr = [[ParseHelper alloc] init];
    });
    return serviceMgr;
}

-(id)init
{
    self = [super init];
    if (self){
        [Parse setApplicationId:@"4uXSfqyezD0qo8XcooiyipZqwKJzIHkMi54IlIpV"
                      clientKey:@"34UZWTxKQrmH4L3NxP7EV0nqGbla3t90BulBvIzR"];
    }
    return self;
}

- (void)dealloc
{
}


#pragma mark - Class Public Method
- (void)saveNotificationDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)subscribePushChannel:(NSString*)channel
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)unsubscribePushChannel:(NSString*)channel
{
    // When users indicate they are no longer channel, we unsubscribe them.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)handlePush:(NSDictionary *)userInfo
{
    NSLog(@"Push info = %@", userInfo);
    NSLog(@"basket_id = %@", userInfo[@"basket_id"]);
    NSLog(@"title = %@", userInfo[@"title"]);
    NSLog(@"latitude = %f", [userInfo[@"latitude"] doubleValue]);
    NSLog(@"longitude = %f", [userInfo[@"longitude"] doubleValue]);
    [PFPush handlePush:userInfo];
}

@end
