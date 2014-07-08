//
//  GlobalValue.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GVALUE              [GlobalValue sharedInstance]

#define KEY_USER_ID         @"default_user_id"
#define KEY_USER_TOKEN      @"default_user_token"

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline id ObjectOrNull(id object)
{
    return object ?: [NSNull null];
}


@interface GlobalValue : NSObject
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSArray *baskets;
@property (nonatomic) BOOL START_LOGIN;
@property (nonatomic) BOOL FIND_USERID;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@property (nonatomic, assign) CLLocationCoordinate2D screenCenterCoordinate2D;
@property (nonatomic, strong) CLLocation *screenCenterLocation;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;

+(GlobalValue*)sharedInstance;

- (void)writeObjectToDefault:(id)idValue withKey:(NSString *)strKey;
- (id)readObjectFromDefault:(NSString *)strKey;

- (NSDictionary *)findBasketWithID:(NSString *)str;
@end


