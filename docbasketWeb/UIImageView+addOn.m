//
//  UIImageView+addOn.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/18/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "UIImageView+addOn.h"

@implementation UIImageView (AFNetwrok_Addon)

- (void)setImageWithURL:(NSString *)urlPath
       placeholderImage:(UIImage *)placeholderImage
             completion:(void (^)(UIImage *image))completion
{
    
    NSURL *url = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        completion(image);
    }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        completion(nil);
    }];

    
}

@end
