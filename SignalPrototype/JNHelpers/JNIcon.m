//
//  JNIcon.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 22/11/2013.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <FAKIonIcons.h>

#import "JNIcon.h"

@implementation JNIcon

#pragma mark - UIImages

+ (UIImage*)cancelImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7CloseEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)chevronLeftImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7ArrowLeftIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)cameraImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7CameraIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)gearImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7GearOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)infoImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7InformationIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)addPersonImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personAddIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)personStalkerImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personStalkerIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)personImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)plusImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7PlusEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)microphoneImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7MicOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)peopleImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7PeopleOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)lockedImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7LockedOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)inboxImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7FilingOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

+ (UIImage*)composeImageIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons composeIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon imageWithSize:CGSizeMake(size, size)];
}

#pragma mark - NSAttributedString

+ (NSAttributedString*)cancelIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7CloseEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)chevronLeftIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7ArrowLeftIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)chevronRightIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7ArrowRightIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)menuIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons naviconRoundIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)personIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)playIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons playIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)flipIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7ReloadbeforeionIos7ReloadingIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)checkMarkIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7CheckmarkEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)reloadIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7RefreshEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)addPersonIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personAddIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)muteIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons volumeMuteIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)unmuteIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons volumeMediumIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)eyeIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7EyeIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)trashOutlineIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7TrashOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)plusIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7PlusEmptyIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)plusOutlineIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons ios7PlusOutlineIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)personStalkerIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons personStalkerIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

+ (NSAttributedString*)earthIconWithSize:(CGFloat)size color:(UIColor*)color
{
    FAKIonIcons *icon = [FAKIonIcons earthIconWithSize:size];
    if (color) {
        [icon addAttribute:NSForegroundColorAttributeName value:color];
    }
    return [icon attributedString];
}

@end
