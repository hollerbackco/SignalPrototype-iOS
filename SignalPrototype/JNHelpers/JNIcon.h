//
//  JNIcon.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 22/11/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNIcon : NSObject

#pragma mark - UIImages

+ (UIImage*)cancelImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)chevronLeftImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)cameraImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)gearImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)infoImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)addPersonImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)personStalkerImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)personImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)plusImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)microphoneImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)peopleImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)lockedImageIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (UIImage*)inboxImageIconWithSize:(CGFloat)size color:(UIColor*)color;

#pragma mark - NSAttributedString

+ (NSAttributedString*)cancelIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)chevronLeftIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)chevronRightIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)menuIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)personIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)playIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)flipIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)checkMarkIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)reloadIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)addPersonIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)muteIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)unmuteIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)eyeIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)trashOutlineIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)plusIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)personStalkerIconWithSize:(CGFloat)size color:(UIColor*)color;
+ (NSAttributedString*)earthIconWithSize:(CGFloat)size color:(UIColor*)color;

@end
