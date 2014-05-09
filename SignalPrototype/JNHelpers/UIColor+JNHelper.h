//
//  UIColor+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (JNHelper)

#define JNColorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define JNColorWithHSB(h,s,b,a) [UIColor colorWithHue:h/360.0 saturation:s/100.0 brightness:b/100.0 alpha:a]

#define JNClearColor [UIColor clearColor]
#define JNWhiteColor [UIColor whiteColor]
#define JNBlackColor [UIColor blackColor]
#define JNLightGrayColor [UIColor lightGrayColor]
#define JNGrayColor [UIColor grayColor]

#define JNGrayBackgroundColor JNColorWithRGB(228,228,228,1)
#define JNBlackTextColor JNColorWithRGB(8,8,8,1)

#pragma mark Gradient

+ (CAGradientLayer*)gradientWithTopColor:(UIColor*)topColor bottomColor:(UIColor*)bottomColor;

@end
