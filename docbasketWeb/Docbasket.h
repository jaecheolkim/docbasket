// Post.h
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
#import <CoreLocation/CoreLocation.h>

@class User;

@interface Docbasket : NSObject

@property (nonatomic, strong) NSString *basketID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) NSString *begin_at;
@property (nonatomic, strong) NSString *end_at;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double radius;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *poi_id;
@property (nonatomic, strong) NSString *poi_title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) NSUInteger permission;

@property (nonatomic, strong) User *user;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

- (CLCircularRegion *)region;


+ (NSURLSessionDataTask *)getBasktesWithBlock:(void (^)(NSArray *basktes, NSError *error))block;

@end
