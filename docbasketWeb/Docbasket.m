// Post.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Docbasket.h"
#import "User.h"
#import "GlobalValue.h"
#import "DocbaketAPIClient.h"

@implementation Docbasket

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
//    self.basketID = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
//    self.text = [attributes valueForKeyPath:@"text"];
//    self.user = [[User alloc] initWithAttributes:[attributes valueForKeyPath:@"user"]];
    
    
    self.basketID = [attributes valueForKeyPath:@"id"];
    self.title = [attributes valueForKeyPath:@"title"];
    self.description = [attributes valueForKeyPath:@"description"];
    self.ownerID = [attributes valueForKeyPath:@"user_id"];
    self.begin_at = [attributes valueForKeyPath:@"begin_at"];
    self.end_at = [attributes valueForKeyPath:@"end_at"];
    self.latitude = [[attributes valueForKeyPath:@"latitude"] doubleValue];
    self.longitude = [[attributes valueForKeyPath:@"longitude"] doubleValue];
    self.radius = [[attributes valueForKeyPath:@"radius"] doubleValue];
    self.poi_id = [attributes valueForKeyPath:@"poi_id"];
    self.poi_title = [attributes valueForKeyPath:@"poi_title"];
    self.url = [attributes valueForKeyPath:@"url"];
    self.image = [attributes valueForKey:@"image_small_thumb"];
    
    //self.permission = [[attributes valueForKeyPath:@"permission"] integerValue];
    self.address = [attributes valueForKeyPath:@"address"];


    
    return self;
}


- (CLCircularRegion *)region
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                                    radius:20
                                                                identifier:self.basketID];
    return newRegion;
}

#pragma mark -

+ (NSURLSessionDataTask *)getBasktesWithBlock:(void (^)(NSArray *basktes, NSError *error))block {
    double longitude = GVALUE.screenCenterCoordinate2D.longitude;
    double latitude = GVALUE.screenCenterCoordinate2D.latitude;
    NSDictionary *param = @{@"longitude":@(longitude), @"latitude":@(latitude), @"radius":@(10000)};
    return [[DocbaketAPIClient sharedClient] GET:@"baskets.json" parameters:param success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        
        NSUInteger count = 0;
        if(!IsEmpty(JSON)) {
            NSLog(@"JSON : %@", JSON);
            
            NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[JSON count]];
            for(id attributes in JSON){
                if([attributes isKindOfClass:[NSDictionary class]]) {
                    
                    Docbasket *basket = [[Docbasket alloc] initWithAttributes:attributes];
                    [mutableBaskets addObject:basket];

                    
                }
                
                count++;
            }
            
            if (block) {
                block([NSArray arrayWithArray:mutableBaskets], nil);
            }
            
        } else {
            if (block) {
                block([NSArray array], nil);
            }
        }
        
//        NSArray *basktesFromResponse = [JSON valueForKeyPath:@"data"];
//        NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[basktesFromResponse count]];
//        for (NSDictionary *attributes in basktesFromResponse) {
//            NSLog(@"attributes : %@", attributes );
//            Docbasket *basket = [[Docbasket alloc] initWithAttributes:attributes];
//            [mutableBaskets addObject:basket];
//        }

//        if (block) {
//            block([NSArray arrayWithArray:mutableBaskets], nil);
//        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
