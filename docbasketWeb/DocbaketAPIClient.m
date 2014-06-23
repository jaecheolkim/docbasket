// AFAppDotNetAPIClient.h
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

#import "DocbaketAPIClient.h"
#import "GlobalValue.h"
#import "Docbasket.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"


static NSString * const DocbasketAPIBaseURLString = @"http://docbasket.com/";

@implementation DocbaketAPIClient

+ (instancetype)sharedClient {
    static DocbaketAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DocbaketAPIClient alloc] initWithBaseURL:[NSURL URLWithString:DocbasketAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

+ (void)loadDocBaskets:(void (^)(BOOL success))block {
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSURLSessionTask *task = [Docbasket getBasktesWithBlock:^(NSArray *basktes, NSError *error) {
        if (!error) {
            [GVALUE setBaskets:basktes];
            block(YES);
        } else {
            block(NO);
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    //    [self.refreshControl setRefreshingWithStateOfTask:task];
    
    
    // [self getJSONFromAFHTTP];
}


- (void)getJSONFromAFHTTP
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://docbasket.com/baskets.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSUInteger count = 0;
        if(!IsEmpty(responseObject)) {
            for(id basket in responseObject){
                if([basket isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"basket %d : %@", (int)count, basket);
                    NSLog(@"begin_at : %@", NSStringFromClass([basket[@"begin_at"] class]));
                    NSLog(@"end_at : %@", NSStringFromClass([basket[@"end_at"] class]));
                    NSLog(@"description : %@", NSStringFromClass([basket[@"description"] class]));
                    NSLog(@"id : %@", NSStringFromClass([basket[@"id"] class]));
                    NSLog(@"latitude : %@", NSStringFromClass([basket[@"latitude"] class]));
                    NSLog(@"longitude : %@", NSStringFromClass([basket[@"longitude"] class]));
                    NSLog(@"permission : %@", NSStringFromClass([basket[@"permission"] class]));
                    NSLog(@"poi_id : %@", NSStringFromClass([basket[@"poi_id"] class]));
                    NSLog(@"poi_title : %@", NSStringFromClass([basket[@"poi_title"] class]));
                    NSLog(@"range : %@", NSStringFromClass([basket[@"range"] class]));
                    NSLog(@"title : %@", NSStringFromClass([basket[@"title"] class]));
                    NSLog(@"url : %@", NSStringFromClass([basket[@"url"] class]));
                    NSLog(@"user_id : %@", NSStringFromClass([basket[@"user_id"] class]));
                    
                }
                
                count++;
            }
        }
        
        //NSLog(@"Class name : %@  || count = %d", NSStringFromClass([responseObject class]), (int)[responseObject count]);
        //NSLog(@"JSON : %@ ",  responseObject[0] );
        //NSLog(@"id: %@ ",  responseObject[0][@"id"] );
        //NSLog(@"JSON: %@", responseObject);
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)getJSONFromNSData
{
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://docbasket.com/baskets.json"]];
    
    if (jsonData) {
        
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"error is %@", [error localizedDescription]);
            // Handle Error and return
            return;
        }
        
        NSLog(@"Class name : %@  || count = %d", NSStringFromClass([jsonObjects class]), (int)[jsonObjects count]);
        
        NSUInteger count = 0;
        if(!IsEmpty(jsonObjects)){
            for(id basket in jsonObjects){
                if([basket isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"basket %d : %@", (int)count, basket);
                }
                
                count++;
            }
        }
        
        
        //        NSArray *keys = [jsonObjects allKeys];
        //
        //        // values in foreach loop
        //        for (NSString *key in keys) {
        //            NSLog(@"%@ is %@",key, [jsonObjects objectForKey:key]);
        //        }
        
    } else {
        // Handle Error
    }
    
}

//- /baskets/:id/checkin    POST    trans_id, user_id, checkin_at, checkout_at (ISO8601)
//[_faceAssets addObject:@{@"Asset": photoAsset, @"UserID" : @(UserID), @"PhotoID" : @(PhotoID)}];

+ (void)postRegionCheck:(NSDictionary *)parameters withBasketID:(NSString*)basketID {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/baskets/", basketID, @"/checkin.json"];
    
    //NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"2014-06-19 07:37:29 +0000", @"checkout_at":@""};
    //[manager POST:@"http://docbasket.com/baskets/377b7268-a653-486e-9f37-390ecc51029b/checkin.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)postUserLocation:(NSDictionary *)parameters withBasketID:(NSString*)basketID {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/baskets/", basketID, @"/checkin.json"];
    
    //NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"2014-06-19 07:37:29 +0000", @"checkout_at":@""};
    //[manager POST:@"http://docbasket.com/baskets/377b7268-a653-486e-9f37-390ecc51029b/checkin.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)postUserTracking {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
   // [manager setParameterEncoding:AFJSONParameterEncoding];
    //http://docbasket.com/users/32ea57d6-6f0e-4902-817a-544cae7cc189/heartbeat.json
    NSString *UserID = @"bb5774c9-2c4e-41d0-b792-530e295e1ca6";
    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/users/", UserID, @"/heartbeat.json"];
    
    NSDictionary *trackingInfo = @{@"longitude":@(127.00000001), @"latitude": @(37.0000001), @"tracked_at": @"2014-06-23 02:12:36.502347"};
    
    NSDictionary *params = @{@"trackings" : @[trackingInfo,] };
    [manager POST:URL parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON: %@", responseObject);
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];

}

@end
