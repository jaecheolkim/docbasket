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

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface DocbaketAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

+ (void)checkNewMessage:(void (^)(NSArray *messages))block;

+ (void)checkNewDocBaskets:(CLLocation *)currentLocation filter:(NSString*)filter completionHandler:(void (^)(NSArray *baskets))block;

+ (void)postRegionCheck:(NSDictionary *)parameters withBasketID:(NSString*)basketID;

+ (void)postTag:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *result))block;

+ (void)postComment:(NSDictionary*)params completionHandler:(void (^)(NSDictionary *result))block;

//+ (void)postUserTracking:(NSDictionary *)parameters;
+ (void)postUserTracking:(NSArray *)parameters;

+ (void)createBasket:(NSDictionary*)parameters completionHandler:(void (^)(NSDictionary *result))block;

+ (void)Login:(void (^)(BOOL success))block;

+ (void)getZipBasket:(void (^)(id result))block;

+ (void)getBasketInfo:(NSString*)basketID completionHandler:(void (^)(NSDictionary *result))block;

+ (void)saveDocBasket:(NSString*)basketID completionHandler:(void (^)(BOOL success))block;

+ (void)performDownload:(NSString *)url completionHandler:(void (^)(id result))block;



//+ (void)loadDocBaskets:(void (^)(BOOL success))block;

//+ (void)createBasket:(NSDictionary*)parameters;

//+ (void)getBaskets;

@end
