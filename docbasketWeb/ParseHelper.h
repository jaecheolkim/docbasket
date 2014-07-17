//
//  ParseHelper.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#define PARSE [ParseHelper sharedInstance]


@interface ParseHelper : NSObject
+(ParseHelper*)sharedInstance;

- (void)saveNotificationDeviceToken:(NSData *)deviceToken;
- (void)subscribePushChannel:(NSString*)channel;
- (void)unsubscribePushChannel:(NSString*)channel;

- (void)handlePush:(NSDictionary *)userInfo;

@end
