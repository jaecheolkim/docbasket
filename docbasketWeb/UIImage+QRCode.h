//
//  UIImage+QRCode.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/4/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

- (UIImage*)drawQRImage:(NSString*)msg;

@end
