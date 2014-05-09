//
//  UIFont+JNHelper.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "UIFont+JNHelper.h"

NSString * const kJNPrimaryFontName = @"Helvetica";
NSString * const kJNPrimaryBoldFontName = @"Helvetica-Bold";
CGFloat const kJNPrimaryFontSize = 14.0;
CGFloat const kJNTitleFontSize = 15.0;
CGFloat const kJNSectionTitleFontSize = 12.0;
CGFloat const kJNPrimaryFontLineHeight = 20.0;

@implementation UIFont (JNHelper)

+ (UIFont*)primaryFont
{   
    return [UIFont primaryFontWithSize:kJNPrimaryFontSize];
}

+ (UIFont*)primaryFontWithTitleSize
{
    return [UIFont fontWithName:kJNPrimaryFontName size:kJNTitleFontSize];
}

+ (UIFont*)primaryFontWithSectionTitleSize
{
    return [UIFont fontWithName:kJNPrimaryFontName size:kJNSectionTitleFontSize];
}

+ (UIFont*)primaryFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:kJNPrimaryFontName size:fontSize];
}

+ (UIFont*)primaryBoldFont
{
    return [UIFont primaryBoldFontWithSize:kJNPrimaryFontSize];
}

+ (UIFont*)primaryBoldFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:kJNPrimaryBoldFontName size:fontSize];
}

@end

@implementation NSAttributedString (JNHelper)

+ (NSDictionary*)paragraphStyleForLineHeight
{
    return [self.class paragraphStyleForLineHeight:kJNPrimaryFontSize];
}

+ (NSDictionary*)paragraphStyleForLineHeight:(CGFloat)lineHeight
{
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = lineHeight;
    style.maximumLineHeight = lineHeight;
    return @{NSParagraphStyleAttributeName: style};
}

+ (NSAttributedString*)attributedStringWithParagrahStyleForLocalizedKey:(NSString*)localizedKey
{
    return [self.class attributedStringWithParagrahLineHeight:kJNPrimaryFontSize localizedKey:localizedKey];
}

+ (NSAttributedString*)attributedStringWithParagrahLineHeight:(CGFloat)lineHeight
                                                 localizedKey:(NSString*)localizedKey
{
    return [[NSAttributedString alloc] initWithString:JNLocalizedString(localizedKey)
                                    attributes:[self.class paragraphStyleForLineHeight:lineHeight]];
}

+ (NSAttributedString*)attributedStringWithParagrahLineHeight:(CGFloat)lineHeight
                                                       string:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:[self.class paragraphStyleForLineHeight:lineHeight]];
}

@end



