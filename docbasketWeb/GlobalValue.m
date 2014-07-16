//
//  GlobalValue.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "GlobalValue.h"

@implementation GlobalValue

+(GlobalValue*)sharedInstance
{
    static GlobalValue* gValue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gValue = [[GlobalValue alloc] init];
    });
    return gValue;
}

-(id)init
{
    self = [super init];
    if (self){
        self.baskets = [NSArray array];
        self.geoFenceBaskets = [NSMutableArray array];
        self.LogList = [NSMutableArray array];
        self.regionMonitoringDistance = 0.1;  // 100m
        self.findBasketsRange = 10000.0; // 10000m (10km)

    }
    return self;
}


#pragma mark - public Methods

- (void)setUserID:(NSString *)UserID
{
    [self writeObjectToDefault:UserID withKey:KEY_USER_ID];
}

- (NSString*)userID
{
    return [self readObjectFromDefault:KEY_USER_ID];
}

- (void)setUserName:(NSString *)userName
{
    [self writeObjectToDefault:userName withKey:KEY_USER_NAME];
}

- (NSString*)userName
{
    return [self readObjectFromDefault:KEY_USER_NAME];
}


- (void)setToken:(NSString *)token
{
    [self writeObjectToDefault:token withKey:KEY_USER_TOKEN];
}

- (NSString*)token
{
    return [self readObjectFromDefault:KEY_USER_TOKEN];
}


- (void)setBadgeValue:(int)badgeValue
{
    if(badgeValue){
        NSString *bv = [NSString stringWithFormat:@"%d", badgeValue];
        [self writeObjectToDefault:bv withKey:KEY_BADGE_VALUE];
    }
}

- (int)badgeValue
{
    return (int)[[self readObjectFromDefault:KEY_BADGE_VALUE] integerValue];
}

- (void)writeObjectToDefault:(id)idValue withKey:(NSString *)strKey
{
    [[NSUserDefaults standardUserDefaults] setObject:idValue forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)readObjectFromDefault:(NSString *)strKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
}

- (Docbasket *)findBasketWithID:(NSString *)str {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block Docbasket *dict = nil;
    
    [self.baskets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (Docbasket *)obj;
        NSString *basketID = dict.basketID;// [dict valueForKey:@"basketID"];
        if ([basketID isEqualToString:str]) {
            found = YES;
            *stop = YES;
        }
    }];
 
    
    if (found) {
        return dict;
    } else {
        return nil;
    }
    
}

- (Docbasket *)findGeoFenceBasketWithID:(NSString *)str {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block Docbasket *dict = nil;
    
    [self.geoFenceBaskets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (Docbasket *)obj;
        NSString *basketID = dict.basketID;// [dict valueForKey:@"basketID"];
        if ([basketID isEqualToString:str]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    
    if (found) {
        return dict;
    } else {
        return nil;
    }
    
}

- (void)addLog:(NSString*)log
{
    [self.LogList addObject:log];
    NSLog(@"%@", log);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DebugLogEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"logAdded"}];
}

@end
