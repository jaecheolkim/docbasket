//
//  GlobalValue.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "GlobalValue.h"
@interface GlobalValue()
{
    NSDateFormatter *formatter;
}
@end

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
        self.baskets = [NSMutableArray array];
        self.geoFenceBaskets = [NSMutableArray array];
        self.trackingArray = [NSMutableArray array];
        self.messages = [NSMutableArray array];
        self.LogList = [NSMutableArray array];
        
        self.regionMonitoringDistance = 1;  // 1000m
        self.findBasketsRange = 10000.0; // 10000m (10km)
        self.checkInTimeFiler = 60*60*24; // 24시간 이내에 동일 지오펜스에 체크인 시도하면 체크인 안 됨.
        
        formatter = [[NSDateFormatter alloc] init];

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

- (void)setUserImage:(NSString *)userImage
{
    [self writeObjectToDefault:userImage withKey:KEY_USER_IMAGE];
}

- (NSString*)userImage
{
    return [self readObjectFromDefault:KEY_USER_IMAGE];
}


- (void)setToken:(NSString *)token
{
    [self writeObjectToDefault:token withKey:KEY_USER_TOKEN];
}

- (NSString*)token
{
    return [self readObjectFromDefault:KEY_USER_TOKEN];
}


- (void)setNotiBasketID:(NSString *)notiBasketID
{
    [self writeObjectToDefault:notiBasketID withKey:KEY_NOTIFICATION_BASKETID];
}

- (NSString*)notiBasketID
{
    return [self readObjectFromDefault:KEY_NOTIFICATION_BASKETID];
}

- (void)setBadgeValue:(int)badgeValue
{
    NSString *bv = [NSString stringWithFormat:@"%d", badgeValue];
    [self writeObjectToDefault:bv withKey:KEY_BADGE_VALUE];
    
    [self.menuButton.badgeView setPosition:MGBadgePositionTopRight];
    [self.menuButton.badgeView setBadgeValue:badgeValue];
    
    [self.messageIconView.badgeView setPosition:MGBadgePositionTopRight];
    [self.messageIconView.badgeView setBadgeValue:badgeValue];

    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeValue];
}

- (int)badgeValue
{
    return (int)[[self readObjectFromDefault:KEY_BADGE_VALUE] integerValue];
}


- (void)setPushNotificationSetting:(int)pushNotificationSetting
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",pushNotificationSetting] withKey:KEY_PUSHNOTIFICATIONSETTING];
}

- (int)pushNotificationSetting
{
    return [[self readObjectFromDefault:KEY_PUSHNOTIFICATIONSETTING] intValue];
}

- (NSString*)timestamp
{
    NSDate *today = [NSDate date];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSString *timestamp = [formatter stringFromDate:today];
    return timestamp;
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

- (Docbasket *)findBasketWithID:(NSString *)str
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basketID == %@", str];
    NSArray *filteredArray = [self.baskets filteredArrayUsingPredicate:predicate];
    if(!IsEmpty(filteredArray)){
        return filteredArray[0];
    } else {
        return nil;
    }
        
//    // ivar: NSArray *myArray; lat : 37.552869 / long : 126.968510
//    __block BOOL found = NO;
//    __block Docbasket *dict = nil;
//    
//    [self.baskets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        dict = (Docbasket *)obj;
//        NSString *basketID = dict.basketID;// [dict valueForKey:@"basketID"];
//        if ([basketID isEqualToString:str]) {
//            found = YES;
//            *stop = YES;
//        }
//    }];
// 
//    
//    if (found) {
//        return dict;
//    } else {
//        return nil;
//    }
    
}

- (Docbasket *)findGeoFenceBasketWithID:(NSString *)str
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basketID == %@", str];
    NSArray *filteredArray = [self.geoFenceBaskets filteredArrayUsingPredicate:predicate];
    if(!IsEmpty(filteredArray)){
        return filteredArray[0];
    } else {
        return nil;
    }
    
//    // ivar: NSArray *myArray;
//    __block BOOL found = NO;
//    __block Docbasket *dict = nil;
//    
//    [self.geoFenceBaskets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        dict = (Docbasket *)obj;
//        NSString *basketID = dict.basketID;// [dict valueForKey:@"basketID"];
//        if ([basketID isEqualToString:str]) {
//            found = YES;
//            *stop = YES;
//        }
//    }];
//    
//    
//    if (found) {
//        return dict;
//    } else {
//        return nil;
//    }
    
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
