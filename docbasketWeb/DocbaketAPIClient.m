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
#import "Message.h"

#import "AFHTTPRequestOperationManager.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

#import "AFDownloadRequestOperation.h"

#import "DBUtil.h"


static NSString * const DocbasketAPIBaseURLString = @"http://docbasket.com/";

@implementation DocbaketAPIClient

+ (instancetype)sharedClient {
    static DocbaketAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DocbaketAPIClient alloc] initWithBaseURL:[NSURL URLWithString:DocbasketAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
//            [_af_defaultImageCache removeAllObjects];
//        }];
    });
    
    return _sharedClient;
}

//+ (void)loadDocBaskets:(void (^)(BOOL success))block {
//    //self.navigationItem.rightBarButtonItem.enabled = NO;
//    
//    NSURLSessionTask *task = [Docbasket getBasktesWithBlock:^(NSArray *basktes, NSError *error) {
//        if (!error) {
//            [GVALUE setBaskets:basktes];
//            block(YES);
//        } else {
//            block(NO);
//        }
//    }];
//    
//    //[UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
//    //    [self.refreshControl setRefreshingWithStateOfTask:task];
//    
//    
//    // [self getJSONFromAFHTTP];
//}




//    NSDictionary *param = nil;
//    
//    // 위치값이 없을 때는 전체 닥바스켓 리스트 가져온다.
//    if(!IsEmpty(currentLocation)){
//        double longitude = currentLocation.coordinate.longitude;
//        double latitude = currentLocation.coordinate.latitude;
//        double radius = GVALUE.findBasketsRange; // 단위 = 미터 : 디폴트 10000 (10km)
//        param = @{@"longitude":@(longitude), @"latitude":@(latitude), @"radius":@(radius), @"limit":@(100), @"offset":@(0)};  //offset = (pagecount-1) * limit  
//    }
//    
//    [[DocbaketAPIClient sharedClient] GET:@"api/baskets" parameters:param success:^(NSURLSessionDataTask * __unused task, id JSON) {
//        //NSUInteger count = 0;
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
//                }
//                
//                //count++;
//            }
//
//            if (block) {
//                [GVALUE setBaskets:mutableBaskets];
//                
//                block(YES);
//            }
//
//        } else {
//            if (block) {
//                block(NO);
//            }
//        }
//        
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//        if (block) {
//            block(NO);
//        }
//    }];

    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"bearer" password:@"61410252b906e22f2fdbbc06e43ea1ec10ce472eb92c1cdcc2c5c1bbfe5ad752"];
//
//    double longitude = currentLocation.coordinate.longitude;
//    double latitude = currentLocation.coordinate.latitude;
//    
//    NSDictionary *param = nil;//@{@"longitude":@(longitude), @"latitude":@(latitude), @"radius":@(1000)};
//    [manager GET:@"http://docbasket.com/baskets.json" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSUInteger count = 0;
//        if(!IsEmpty(responseObject)) {
//            NSLog(@"JSON : %@", responseObject);
//            
//            NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[responseObject count]];
//            for(id attributes in responseObject){
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
//                [GVALUE setBaskets:mutableBaskets];
//                
//                block(YES);
//            }
//            
//        } else {
//            if (block) {
//               block(NO);
//            }
//        }
//        
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
//}

//- (void)getJSONFromNSData
//{
//    NSError *error = nil;
//    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://docbasket.com/baskets.json"]];
//    
//    if (jsonData) {
//        
//        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
//        
//        if (error) {
//            NSLog(@"error is %@", [error localizedDescription]);
//            // Handle Error and return
//            return;
//        }
//        
//        NSLog(@"Class name : %@  || count = %d", NSStringFromClass([jsonObjects class]), (int)[jsonObjects count]);
//        
//        NSUInteger count = 0;
//        if(!IsEmpty(jsonObjects)){
//            for(id basket in jsonObjects){
//                if([basket isKindOfClass:[NSDictionary class]]) {
//                    NSLog(@"basket %d : %@", (int)count, basket);
//                }
//                
//                count++;
//            }
//        }
//        
//        
//        //        NSArray *keys = [jsonObjects allKeys];
//        //
//        //        // values in foreach loop
//        //        for (NSString *key in keys) {
//        //            NSLog(@"%@ is %@",key, [jsonObjects objectForKey:key]);
//        //        }
//        
//    } else {
//        // Handle Error
//    }
//    
//}

//+ (void)getBaskets
//{
//    NSString *token = GVALUE.token;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    if(!IsEmpty(token)) {
//        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"bearer" password:token];
//    }
//    
//    [manager GET:@"http://docbasket.com/baskets.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//         if(!IsEmpty(responseObject)) {
//             
//             NSLog(@"JSON: %@", responseObject);
//          }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//
//}

//- /baskets/:id/checkin    POST    trans_id, user_id, checkin_at, checkout_at (ISO8601)
//[_faceAssets addObject:@{@"Asset": photoAsset, @"UserID" : @(UserID), @"PhotoID" : @(PhotoID)}];
+ (void)postRegionCheck:(NSDictionary *)parameters withBasketID:(NSString*)basketID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/api/baskets/", basketID, @"/checkin"];
    
    //NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"2014-06-19 07:37:29 +0000", @"checkout_at":@""};
    //[manager POST:@"http://docbasket.com/baskets/377b7268-a653-486e-9f37-390ecc51029b/checkin.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [manager POST:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//+ (void)postRegionCheck:(NSDictionary *)parameters withBasketID:(NSString*)basketID
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/baskets/", basketID, @"/checkin.json"];
//    
//    //NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"2014-06-19 07:37:29 +0000", @"checkout_at":@""};
//    //[manager POST:@"http://docbasket.com/baskets/377b7268-a653-486e-9f37-390ecc51029b/checkin.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

//+ (void)postUserLocation:(NSDictionary *)parameters withBasketID:(NSString*)basketID {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/baskets/", basketID, @"/checkin.json"];
//    
//    //NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"2014-06-19 07:37:29 +0000", @"checkout_at":@""};
//    //[manager POST:@"http://docbasket.com/baskets/377b7268-a653-486e-9f37-390ecc51029b/checkin.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

+ (void)saveDocBasket:(NSString*)basketID completionHandler:(void (^)(BOOL success))block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *URL = [NSString stringWithFormat:@"%@%@%@", @"http://docbasket.com/api/baskets/", basketID, @"/save"];
    [manager POST:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"JSON: %@", responseObject);
        block(YES);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
        int statusCode = (int)[operation.response statusCode];
        if(statusCode == 401){
            NSLog(@"Token expired");
            
            [DocbaketAPIClient  Login:^(BOOL success) {
                if(success){
                    block(YES);
                }else {
                    block(NO);
                }
                NSLog(@"Token refreshed");
            }];
        }
        
    }];
}

///api/tags      POST  (header: token), basket_id, document_id, page, description, cord_x, cord_y
// NSDictionary *param = @{@"basket_id":basket_id,@"document_id":document_id, @"page":@(page), @"description":description, @"cord_x":cord_x, @"cord_y":cord_y };
+ (void)postTag:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *result))block
{
    //    /api/comments      POST  (header: token), basket_id, document_id, page, description
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *URL = @"http://docbasket.com/api/tags";
    
    [manager POST:URL parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON: %@", responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         
         int statusCode = (int)[operation.response statusCode];
         if(statusCode == 401){
             NSLog(@"Token expired");
             
             [DocbaketAPIClient  Login:^(BOOL success) {
                 
                 NSLog(@"Token refreshed");
             }];
         }
     }];
}

//NSDictionary *param = @{@"basket_id":basket_id,@"document_id":document_id, @"page":@(page), @"description":description};
+ (void)postComment:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *result))block
{
    //    /api/comments      POST  (header: token), basket_id, document_id, page, description
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *URL = @"http://docbasket.com/api/comments";
    
    [manager POST:URL parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON: %@", responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
         NSLog(@"Error: %@", error);
         
         int statusCode = (int)[operation.response statusCode];
         if(statusCode == 401){
             NSLog(@"Token expired");
             
             [DocbaketAPIClient  Login:^(BOOL success) {
                 
                 NSLog(@"Token refreshed");
             }];
         }
     }];
}

//+ (void)postUserTracking:(NSDictionary *)parameters
+ (void)postUserTracking:(NSArray *)parameters
{
    
    NSString *UserID = GVALUE.userID;
    
    if(!IsEmpty(UserID) && !IsEmpty(parameters))
    {

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
        
        if(!IsEmpty(token)) {
            [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        }

        //NSDictionary *params = @{@"trackings" : @[parameters,parameters,parameters] };
        NSDictionary *params = @{@"trackings" : parameters };
        
        NSString *URL = @"http://docbasket.com/api/heartbeat";
        
        [manager POST:URL parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [GVALUE.trackingArray removeAllObjects];
             
             NSLog(@"JSON: %@", responseObject);
         }
              failure:
         ^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             
             int statusCode = (int)[operation.response statusCode];
             if(statusCode == 401){
                 NSLog(@"Token expired");
                 
                 [DocbaketAPIClient  Login:^(BOOL success) {
                     
                     NSLog(@"Token refreshed");
                 }];
             }
             
         }];
     }
}


+ (void)checkNewMessage:(void (^)(NSArray *messages))block
{
//    http://docbasket.com/api/activities
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }

    NSDictionary *param = @{@"limit":@(20), @"offset":@(0)};  //offset = (pagecount-1) * limit

    [manager GET:@"http://docbasket.com/api/activities" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!IsEmpty(responseObject)) {
            NSLog(@"result = %@", responseObject);
            NSArray *result = responseObject[@"activities"];
            
            NSMutableArray *mutableMessages = [NSMutableArray arrayWithCapacity:[result count]];
            for(id attributes in result){
                if([attributes isKindOfClass:[NSDictionary class]]) {
                    
                    Message *message = [[Message alloc] initWithAttributes:attributes];
                    [mutableMessages addObject:message];
                    
                }
            }
            
            if (block) {
                //[GVALUE setBaskets:mutableBaskets];
                block(mutableMessages);
            }

        }
        else {
            block([NSArray array]);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        int statusCode = (int)[operation.response statusCode];
        if(statusCode == 401){
            NSLog(@"Token expired");
            
            [DocbaketAPIClient  Login:^(BOOL success) {
                block([NSArray array]);
            }];
        }
    }];
    
}

//filter= created | invited | saved | public(default)
+ (void)checkNewDocBaskets:(CLLocation *)currentLocation filter:(NSString*)filter completionHandler:(void (^)(NSArray *baskets))block
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }

    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    // 위치값이 없을 때는 전체 닥바스켓 리스트 가져온다.
    if(!IsEmpty(currentLocation)){
        double longitude = currentLocation.coordinate.longitude;
        double latitude = currentLocation.coordinate.latitude;
        double radius = GVALUE.findBasketsRange; // 단위 = 미터 : 디폴트 10000 (10km)
        param = [NSMutableDictionary dictionaryWithDictionary:@{@"longitude":@(longitude), @"latitude":@(latitude), @"radius":@(radius), @"limit":@(50), @"offset":@(0)}];  //offset = (pagecount-1) * limit

    }
    
    if(!IsEmpty(filter)){
        [param setObject:filter forKey:@"filter"];
    }
    
    [manager GET:@"http://docbasket.com/api/baskets" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!IsEmpty(responseObject)) {
            id baskets = responseObject[@"baskets"];
            
            //            id count = responseObject[@"count"];
            //            id limit = responseObject[@"limit"];
            //            id offset = responseObject[@"offset"];
            //            id total = responseObject[@"total"];
            
            if([baskets isKindOfClass:[NSArray class]] && !IsEmpty(baskets))
            {
                NSLog(@"New Baskets count : %d", (int)[baskets count]);
                //NSLog(@"New Baskets = %@", baskets);
                NSMutableArray *mutableBaskets = [NSMutableArray arrayWithCapacity:[baskets count]];
                for(id attributes in baskets){
                    if([attributes isKindOfClass:[NSDictionary class]]) {
                        
                        Docbasket *basket = [[Docbasket alloc] initWithAttributes:attributes];
                        [mutableBaskets addObject:basket];
                        NSLog(@"Basket = %@", basket.title);
                        
                    }
                }
                
                if (block) {
                    //[GVALUE setBaskets:mutableBaskets];
                    block(mutableBaskets);
                }
            } else {
                block([NSArray array]);
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        int statusCode = (int)[operation.response statusCode];
        if(statusCode == 401){
            NSLog(@"Token expired");
            
            [DocbaketAPIClient  Login:^(BOOL success) {
                block([NSArray array]);
            }];
        }
    }];
}

//NSDictionary *parameters = @{@"user_id": UserID, @"basket[title]": @"테스트", @"basket[longitude]": @(127.00000001), @"basket[latitude]": @(37.0000001), @"files" : arrayFilesData};

+ (void)getBasketInfo:(NSString*)basketID completionHandler:(void (^)(NSDictionary *result))block
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];

    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }

    NSString *baseURL = [NSString stringWithFormat:@"http://docbasket.com/api/baskets/%@", basketID];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(!IsEmpty(responseObject))
        {
            NSLog(@"JSON: %@", responseObject);
            block(responseObject);
        }
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
        int statusCode = (int)[operation.response statusCode];
        if(statusCode == 401){
            NSLog(@"Token expired");
            
            [DocbaketAPIClient  Login:^(BOOL success) {
                if(success){
                    block([NSDictionary new]);
                } else {
                    block([NSDictionary new]);
                }
            }];
        }
        
    }];
}


//+ (void)getZipBasket
//{
//     NSString *url = @"http://d93564098306bf104b0a-08a7db9a8bc7bb0993d1bb9ea1fa4fbb.r55.cf6.rackcdn.com/Seoul.zip";
    //[DocbaketAPIClient performDownload:url];
    
//    NSString *token = GVALUE.token;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    if(!IsEmpty(token)) {
//        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"bearer" password:token];
//    }
//    
//    //http://docbasket.com/baskets/a5741eba-d943-4c07-970f-dfc6f86df0d1.json
//    
//    NSString *baseURL = @"http://d93564098306bf104b0a-08a7db9a8bc7bb0993d1bb9ea1fa4fbb.r55.cf6.rackcdn.com/Seoul.zip";
//    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         if(!IsEmpty(responseObject))
//         {
//             NSLog(@"response: %@", responseObject);
//             //block(responseObject);
//         }
//     }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"Error: %@", error);
//         //block(nil);
//     }];

//}


#pragma mark - download & unzip

+ (void)performDownload:(NSString *)url completionHandler:(void (^)(id result))block
{
    
    //다운로드 Path
    NSString *downloadPath = [[DBUtil getCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"temp.zip"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFDownloadRequestOperation *fileDownOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                 targetPath:downloadPath
                                                               shouldResume:NO];
    
    //__weak id weakSelf = self;
    [fileDownOperation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation,
                                                             NSInteger bytesRead,
                                                             long long totalBytesRead,
                                                             long long totalBytesExpected,
                                                             long long totalBytesReadForFile,
                                                             long long totalBytesExpectedToReadForFile) {
        //code
        NSLog(@"bytesRead : %d", (int)bytesRead);
        NSLog(@"totalBytesRead : %lld", totalBytesRead);
        NSLog(@"totalBytesExpected : %lld", totalBytesExpected);
        NSLog(@"totalBytesReadForFile : %lld", totalBytesReadForFile);
        NSLog(@"totalBytesExpectedToReadForFile : %lld", totalBytesExpectedToReadForFile);
        
        //        CGFloat progress = ((CGFloat)totalBytesRead / (CGFloat)[fileSize floatValue]) * 100.0f;
        CGFloat progress = ((CGFloat)totalBytesRead / (CGFloat)totalBytesExpected) * 100.0f;
        NSLog(@">>>progress : %f",progress);
        
        //[weakSelf setProgress:progress animated:YES];
        
    }];
    
    [fileDownOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"다운로드 성공 : %@", responseObject);
        
        block(responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"다운로드 실패 : %@", error);
        
        block(nil);
        
    }];

    [fileDownOperation start];
}


+ (void)getZipBasket:(void (^)(id result))block
{

    double latitude = GVALUE.currentLocation.coordinate.latitude; // 37.5446;// GVALUE.latitude;
    double longitude = GVALUE.currentLocation.coordinate.longitude; //126.9722;// GVALUE.longitude;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }

    NSString *baseURL = [NSString stringWithFormat:@"http://docbasket.com/api/packages.json?latitude=%f&longitude=%f", latitude, longitude];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if(!IsEmpty(responseObject))
         {
             NSLog(@"response: %@", responseObject);
             // 도시가 나를 중심으로 여러개 걸칠 수 있으므로 배열로 시티정보가 넘어오면
             // 이를 하나씩 url 추출해서 DB에 저장
             
             NSMutableArray *array = [NSMutableArray array];
             __block int counter = (int)[responseObject count];
             for(NSDictionary *city in responseObject)
             {
                 
                 NSString *url = city[@"url"];  //왜 배열로 넘어오지?
                 
                 [DocbaketAPIClient performDownload:url completionHandler:^(id result) {
                     
                     if(!IsEmpty(result)){
                         
                         if([result isKindOfClass:[NSString class]] ) {
                             
                             NSString *downPath = (NSString*)result;
                             
                             NSString *cacheDir =[DBUtil getCacheFilePath:@"temp"];
                             [DBUtil unzip:downPath withUnzipPath:cacheDir];
                             [DBUtil deleteZipFile:downPath];
                             
                             NSString *fileName = [[url lastPathComponent] stringByDeletingPathExtension];
                             //NSString *extention = [url pathExtension];
                             //NSString *dataPath = [NSString stringWithFormat:@"%@/Seoul.json",cacheDir];
                             NSString *dataPath = [NSString stringWithFormat:@"%@/%@.json",cacheDir, fileName];

                             NSData* data = [NSData dataWithContentsOfFile:dataPath];
                             __autoreleasing NSError* error = nil;
                             NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:kNilOptions error:&error];

                             [array addObject:jsonData];
                         }
                         
                     } else {

                     }
                     
                     counter--;
                     if(counter == 0) {
                         block(array);
                     }
                     
                 }];

             }
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         block(nil);
     }];

    
    
    
    
//    //http://docbasket.com/api/packages.json?latitude=37.56863031268756&longitude=126.98216915130615
//    
//    NSString *url = @"http://d93564098306bf104b0a-08a7db9a8bc7bb0993d1bb9ea1fa4fbb.r55.cf6.rackcdn.com/Seoul.zip";
//    
//    [DocbaketAPIClient performDownload:url completionHandler:^(id result) {
//        
//        if(!IsEmpty(result)){
//            
//            if([result isKindOfClass:[NSString class]] ) {
//                
//                NSString *downPath = (NSString*)result;
//                
//                NSString *cacheDir =[DBUtil getCacheFilePath:@"temp"];
//                [DBUtil unzip:downPath withUnzipPath:cacheDir];
//                [DBUtil deleteZipFile:downPath];
//                
//                NSData* data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/Seoul.json",cacheDir]];
//                __autoreleasing NSError* error = nil;
//                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
//                                                                       options:kNilOptions error:&error];
//                
//                
//                
//                block(jsonData);
//            }
//
//            
//        } else {
//            
//            block(nil);
//        }
//    }];
}

+ (void)deleteBasket:(NSString*)basketID completionHandler:(void (^)(BOOL success))block
{
    //delete api/baskets/:id
    NSString *token = GVALUE.token;
    if(!IsEmpty(token)){
        NSString *apiURL = [NSString stringWithFormat:@"http://docbasket.com/api/baskets/%@", basketID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        if(!IsEmpty(token)) {
            [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        }
        
        [manager DELETE:apiURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(YES);
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(NO);
            NSLog(@"Error: %@", error);
        }];

    }
}


+ (void)createBasket:(NSDictionary*)parameters completionHandler:(void (^)(NSDictionary *result))block
{
    
    NSString *UserID = parameters[@"user_id"]; // GVALUE.userID ||  @"bb5774c9-2c4e-41d0-b792-530e295e1ca6";
    if(!IsEmpty(UserID)){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSString *token = [NSString stringWithFormat:@"Bearer %@",GVALUE.token];
        
        if(!IsEmpty(token)) {
            [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"doc" password:@"basket"];
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        }
        
        [manager POST:@"http://docbasket.com/api/baskets" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
        {

            NSArray *files = parameters[@"files"];
            if(!IsEmpty(files)){
                int count = 0;
                for(id file in files){
                    if ([file isKindOfClass:[UIImage class]])
                    {
                        //NSData *imageData = UIImagePNGRepresentation((UIImage *)file);
                        NSData *imageData = UIImageJPEGRepresentation((UIImage *)file, 0.82);
                        NSString *fileName = [NSString stringWithFormat:@"Image%d.jpg", count];
                        [formData appendPartWithFileData:imageData name:@"documents[file][]" fileName:fileName mimeType:@"image/jpeg"];
                        count++;
                    }
                }
                
//                NSError* err;
//                NSURL *movieURL = [NSURL URLWithString:@"http://movietrailers.apple.com/movies/disney/planesfireandrescue/planesandrescue-tlr4_480p.mov"];
//                
//                [formData appendPartWithFileURL:movieURL name:@"documents[file][]" fileName:[NSString stringWithFormat:@"video.mov"] mimeType:@"video/quicktime" error:&err];
//                
//                NSLog(@"video error : %@", err);
            }

            
            
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             block(responseObject);
             NSLog(@"Success: %@", responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             block(nil);
             NSLog(@"Error: %@", error);
         }];
        

    } else {
        
        // Alert no user information.
        NSLog(@"Error: no user information");
    }
    
    
    
    //Video
    
//    httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.mysite.com"]];
//    
//    NSMutableURLRequest *afRequest = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload.php" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
//                                      {
//                                          [formData appendPartWithFileData:videoData name:@"file" fileName:@"filename.mov" mimeType:@"video/quicktime"];
//                                      }];
//    
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
//    
//    [operation setUploadProgressBlock:^(NSInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
//     {
//         
//         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//         
//     }];
//    
//    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {NSLog(@"Success");}
//                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {NSLog(@"error: %@",  operation.responseString);}];
//    [operation start];

    
//////////////////////////////////////////////////////
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"basket[title]": @"테스트", @"basket[longitude]": @(127.00000001), @"basket[latitude]": @(37.0000001)};
//    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
//    [manager POST:@"http://docbasket.com/baskets" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
//    {
//        [formData appendPartWithFileURL:filePath name:@"image" error:nil];
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    
//////////////////////////////////////////////////////
    
//    NSArray *imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"close_button.png"],[UIImage imageNamed:@"done_button.png"], nil];
//    __block int i=1;
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:@"yoururl"];
//    NSMutableURLRequest *request=nil;
//    request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"yoururl" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData)
//               {
//                   for(UIImage *eachImage in imageArray)
//                   {
//                       NSData *imageData = UIImagePNGRepresentation(eachImage);
//                       [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i] fileName:[NSString stringWithFormat:@"abc%d.png",i] mimeType:@"image/png"];
//                       i++;
//                   }
//                   
//               }];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         NSData *data = (NSData *)responseObject;
//         NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//         NSLog(@"Response -> %@",str);
//         
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"Error -> %@",[error localizedDescription]);
//     }];
    
}

+ (void)Login:(void (^)(BOOL success))block
{
    // TODO : WebView 형태의 로그인 거친 후 Login
    NSString *UserID = [[GlobalValue sharedInstance] userID];
    
    if(IsEmpty(UserID)) {
        
        block(NO);
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // [manager setParameterEncoding:AFJSONParameterEncoding];
        //http://docbasket.com/users/32ea57d6-6f0e-4902-817a-544cae7cc189/heartbeat.json
        
        
        
        NSString *URL = @"http://docbasket.com/oauth/token";
        
        NSDictionary *OAuthInfo = @{ @"grant_type" : @"password",
                                     @"username" : UserID,
                                     @"password" : @"sekret",
                                     @"client_id" : @"16f1cfc9121c9e923db62aa9db69bfd6ef507313fb55337563b2ffef07df269a",
                                     @"client_secret" : @"232a36d50361f926bae965057170250226caca32fbb0817ed602a54ecdac3d32"};
        
        [manager POST:URL parameters:OAuthInfo
              success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"JSON: %@", responseObject);
             
             //         NSLog(@"access_token = %@", responseObject[@"access_token"]);
             //         NSLog(@"expires_in = %@", responseObject[@"expires_in"]);
             //         NSLog(@"token_type = %@", responseObject[@"token_type"]);
             
             [GVALUE setToken:responseObject[@"access_token"]];
             
             NSLog(@" token saved = %@", GVALUE.token);
             
             block(YES);
             
         }
              failure:
         ^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             block(NO);
         }];

    }

}

@end
