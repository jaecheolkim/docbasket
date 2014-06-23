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


- (void)setToken:(NSString *)token
{
    [self writeObjectToDefault:token withKey:KEY_USER_TOKEN];
}

- (NSString*)token
{
    return [self readObjectFromDefault:KEY_USER_TOKEN];
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

- (NSDictionary *)findBasketWithID:(NSString *)str {
    // ivar: NSArray *myArray;
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;
    
    [self.baskets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        NSString *basketID = [dict valueForKey:@"basketID"];
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


@end
