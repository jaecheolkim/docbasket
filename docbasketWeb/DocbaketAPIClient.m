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
    
    //[UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    //    [self.refreshControl setRefreshingWithStateOfTask:task];
    
    
    // [self getJSONFromAFHTTP];
}


- (void)getJSONFromAFHTTP
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"bearer" password:@"61410252b906e22f2fdbbc06e43ea1ec10ce472eb92c1cdcc2c5c1bbfe5ad752"];

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

+ (void)getBaskets
{
    NSString *token = GVALUE.token;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(!IsEmpty(token)) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"bearer" password:token];
    }
    
    [manager GET:@"http://docbasket.com/baskets.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if(!IsEmpty(responseObject)) {
             
             NSLog(@"JSON: %@", responseObject);
          }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

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

+ (void)createBasket {
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *UserID = @"bb5774c9-2c4e-41d0-b792-530e295e1ca6";
    NSDictionary *parameters = @{@"user_id": UserID, @"basket[title]": @"테스트", @"basket[longitude]": @(127.00000001), @"basket[latitude]": @(37.0000001)};
    
    //NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    [manager POST:@"http://docbasket.com/baskets.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         //[formData appendPartWithFileURL:filePath name:@"image" error:nil];
         
         NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"RemoveRegion"]);
         
         [formData appendPartWithFileData:imageData name:@"documents[file][]" fileName:[NSString stringWithFormat:@"upload.png"] mimeType:@"image/png"];
         [formData appendPartWithFileData:imageData name:@"documents[file][]" fileName:[NSString stringWithFormat:@"abc%d.png",1] mimeType:@"image/png"];
         [formData appendPartWithFileData:imageData name:@"documents[file][]" fileName:[NSString stringWithFormat:@"abc%d.png",2] mimeType:@"image/png"];
 
         NSError* err;
         NSURL *movieURL = [NSURL URLWithString:@"http://movietrailers.apple.com/movies/disney/planesfireandrescue/planesandrescue-tlr4_480p.mov"];
         
         [formData appendPartWithFileURL:movieURL name:@"documents[file][]" fileName:[NSString stringWithFormat:@"video.mov"] mimeType:@"video/quicktime" error:&err];
         
         NSLog(@"video error : %@", err);
//          NSError* err;
//          [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePathToUpload] name:[fileInfo objectForKey:@"fileName"] error:&err];

     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"Success: %@", responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    
    
    
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

+ (void)Login
{
    // TODO : WebView 형태의 로그인 거친 후 Login
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // [manager setParameterEncoding:AFJSONParameterEncoding];
    //http://docbasket.com/users/32ea57d6-6f0e-4902-817a-544cae7cc189/heartbeat.json
    
    NSString *UserID = [[GlobalValue sharedInstance] userID];
    
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
 
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];

}

@end
