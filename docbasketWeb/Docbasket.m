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

//2014-07-15 18:35:23.136 docbasketWeb[16788:60b] JSON: {
//    "begin_at" = "<null>";
//    comments =     (
//    );
//    "created_at" = "2014-07-10T14:11:44.778Z";
//    description = "\Ubb38\Uc11c \Ud14c\Uc2a4\Ud2b8\Uc6a9";
//    documents =     (
//                     {
//                         id = "64ae39ca-48f2-40b3-885e-6d895d183895";
//                         image = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//                         title = "<null>";
//                         "total_pages" = 21;
//                         "trans_done" = 1;
//                         url = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//                     }
//                     );
//    "end_at" = "<null>";
//    id = "b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b";
//    image = "http://0c86568b33ba49994159-f6bbd63f18dffb4beb7359283894d4fe.r82.cf6.rackcdn.com/Adobe-PDF-Document-icon.png";
//    "is_public" = 1;
//    latitude = "37.5618353639392";
//    longitude = "126.989598870277";
//    permission =     (
//    );
//    "poi_id" = "<null>";
//    "poi_title" = "<null>";
//    range = "<null>";
//    tags =     (
//    );
//    title = "\Ubb38\Uc11c \Uc0d8\Ud50c";
//    "updated_at" = "2014-07-10T14:11:44.778Z";
//    "user_id" = "bb5774c9-2c4e-41d0-b792-530e295e1ca6";
//}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.basketID = [attributes valueForKeyPath:@"id"];
    self.title = [attributes valueForKeyPath:@"title"];
    self.description = [attributes valueForKeyPath:@"description"];
    self.ownerID = [attributes valueForKeyPath:@"user_id"];
    self.begin_at = [attributes valueForKeyPath:@"begin_at"];
    self.end_at = [attributes valueForKeyPath:@"end_at"];
    self.latitude = [[attributes valueForKeyPath:@"latitude"] doubleValue];
    self.longitude = [[attributes valueForKeyPath:@"longitude"] doubleValue];
    //self.radius = [[attributes valueForKeyPath:@"range"] doubleValue];
    self.poi_id = [attributes valueForKeyPath:@"poi_id"];
    self.poi_title = [attributes valueForKeyPath:@"poi_title"];
    self.url = [attributes valueForKeyPath:@"url"];
    self.image = [attributes valueForKey:@"image"];
    
    
    self.address = [attributes valueForKeyPath:@"address"];
    
    
    self.is_public = (!IsEmpty([attributes valueForKeyPath:@"is_public"]))?[[attributes valueForKeyPath:@"is_public"] integerValue] : 1 ;
    self.created_at = [attributes valueForKeyPath:@"created_at"];

    self.permission = [attributes valueForKeyPath:@"permission"];
    self.updated_at = [attributes valueForKeyPath:@"updated_at"];
    
    self.documents = [attributes valueForKeyPath:@"documents"];
    self.tags = [attributes valueForKeyPath:@"tags"];
    self.comments = [attributes valueForKeyPath:@"comments"];
    
    
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

//+ (NSURLSessionDataTask *)getBasktesWithBlock:(void (^)(NSArray *basktes, NSError *error))block {
//    double longitude = GVALUE.screenCenterCoordinate2D.longitude;
//    double latitude = GVALUE.screenCenterCoordinate2D.latitude;
//    NSDictionary *param = @{@"longitude":@(longitude), @"latitude":@(latitude), @"radius":@(10000)};
//    return [[DocbaketAPIClient sharedClient] GET:@"baskets.json" parameters:param success:^(NSURLSessionDataTask * __unused task, id JSON) {
//        
//        
//        NSUInteger count = 0;
//        if(!IsEmpty(JSON)) {
//            NSLog(@"JSON : %@", JSON);
//            
//            NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[JSON count]];
//            for(id attributes in JSON){
//                if([attributes isKindOfClass:[NSDictionary class]]) {
//                    
//                    Docbasket *basket = [[Docbasket alloc] initWithAttributes:attributes];
//                    [mutableBaskets addObject:basket];
//
//                    
//                }
//                
//                count++;
//            }
//            
//            if (block) {
//                block([NSArray arrayWithArray:mutableBaskets], nil);
//            }
//            
//        } else {
//            if (block) {
//                block([NSArray array], nil);
//            }
//        }
//        
////        NSArray *basktesFromResponse = [JSON valueForKeyPath:@"data"];
////        NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[basktesFromResponse count]];
////        for (NSDictionary *attributes in basktesFromResponse) {
////            NSLog(@"attributes : %@", attributes );
////            Docbasket *basket = [[Docbasket alloc] initWithAttributes:attributes];
////            [mutableBaskets addObject:basket];
////        }
//
////        if (block) {
////            block([NSArray arrayWithArray:mutableBaskets], nil);
////        }
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//        if (block) {
//            block([NSArray array], error);
//        }
//    }];
//}

@end
