//
//  UIImageView+addOn.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/18/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface UIImageView (AFNetwrok_Addon)


- (void)setImageWithURL:(NSString *)urlPath
       placeholderImage:(UIImage *)placeholderImage
             completion:(void (^)(UIImage *image))completion;


@end
