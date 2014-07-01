//
//  PopButtonImageView.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/1/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "PopButtonImageView.h"

@interface PopButtonImageView ()
{

    UIImageView* _imageView;
}

@end


@implementation PopButtonImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame  withImage:(UIImage*)image

{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = self.bounds;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_imageView];
        
        
    }
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    NSLog(@"touch point : %@", NSStringFromCGPoint(point));
}


@end
