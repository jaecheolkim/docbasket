//
//  Message.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/24/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "Message.h"

@implementation Message
- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDictionary *basketInfo = [attributes valueForKeyPath:@"basket"];
    Docbasket *basket = [[Docbasket alloc] initWithAttributes:basketInfo];
    
    self.messageID = [attributes valueForKeyPath:@"id"];
    self.title = [attributes valueForKeyPath:@"verb"];
    self.description = [attributes valueForKeyPath:@"description"];
    self.created_at = [attributes valueForKeyPath:@"created_at"];
    self.basket = basket;

    return self;
}

@end
