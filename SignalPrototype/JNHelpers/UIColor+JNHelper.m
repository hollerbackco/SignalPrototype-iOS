//
//  UIColor+JNHelper.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "UIColor+JNHelper.h"

@implementation UIColor (JNHelper)

#pragma mark Gradient

+ (CAGradientLayer*)gradientWithTopColor:(UIColor*)topColor bottomColor:(UIColor*)bottomColor
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)topColor.CGColor,
                            (id)bottomColor.CGColor,
                            nil];
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    return gradientLayer;
}

@end
