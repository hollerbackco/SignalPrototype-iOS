//
//  UIFont+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kHBPrimaryFontName;
extern NSString * const kHBprimaryFontName;
extern CGFloat const kHBPrimaryFontSize;
extern CGFloat const kHBTitleFontSize;

@interface UIFont (JNHelper)

+ (UIFont*)primaryFont;
+ (UIFont*)primaryFontWithTitleSize;
+ (UIFont*)primaryFontWithSectionTitleSize;
+ (UIFont*)primaryFontWithSize:(CGFloat)fontSize;

+ (UIFont*)primaryBoldFont;
+ (UIFont*)primaryBoldFontWithSize:(CGFloat)fontSize;

@end

@interface NSAttributedString (JNHelper)

+ (NSDictionary*)paragraphStyleForLineHeight;

+ (NSDictionary*)paragraphStyleForLineHeight:(CGFloat)lineHeight;

+ (NSAttributedString*)attributedStringWithParagrahStyleForLocalizedKey:(NSString*)localizedKey;

+ (NSAttributedString*)attributedStringWithParagrahLineHeight:(CGFloat)lineHeight
                                                 localizedKey:(NSString*)localizedKey;

+ (NSAttributedString*)attributedStringWithParagrahLineHeight:(CGFloat)lineHeight
                                                       string:(NSString*)string;

@end