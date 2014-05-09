//
//  UIViewController+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 12/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

#import "UIView+JNHelper.h"

#if IS_IOS7_OR_GREATER
    #define kJNNavBarBackNavIconImageOffset CGPointMake(-24.0, 0.0)
#else
    #define kJNNavBarBackNavIconImageOffset CGPointMake(-10.0, 0.0)
#endif

#define kUIScrollBarWidth 7.0
#define kJNMotionTiltAmount 20.0

extern CGFloat const kJNNavigationBarTitleFontSize;
extern CGFloat const kJNNavigationBarHeight;
extern CGFloat const kJNStandardNavigationBarHeight;

extern CGFloat const kJNNavigationBarButtonWidth;
extern CGFloat const kJNNavigationBarButtonLongWidth;

@interface UIViewController (Helper)

#pragma mark - NavigationBar stuff

- (void)applyTranslucentNavigationBarStyle;
- (void)applyTranslucentBlueNavigationBarStyle;
- (void)applyOpaqueNavigationBarStyle;
- (void)applyOpaqueNavigationBarStyleWithNavBarColor:(UIColor*)navBarColor;

- (void)applyFadingNavbarShadow;
- (void)applyDefaultNavbarShadow;

- (void)setupDefaultNavigationBarTitleAttributes;
- (void)setupDefaultNavigationBarTitleAttributesTitleColor:(UIColor*)titleColor
                                        barButtonItemColor:(UIColor*)barButtonItemColor;
- (void)applyNavigationBarLogo;
- (void)removeNavigationBarLogo;

- (UIBarButtonItem*)createBarButtonItemWithImageNamed:(NSString*)imageName
                                          imageOffset:(CGPoint)imageOffset
                                               target:(id)target
                                               action:(SEL)action;

- (void)applyNavigationBarLeftButtonWithImageNamed:(NSString*)imageName
                                       imageOffset:(CGPoint)imageOffset
                                            target:(id)target
                                            action:(SEL)action;

- (void)applyNavigationBarRightButtonWithImageNamed:(NSString*)imageName
                                        imageOffset:(CGPoint)imageOffset
                                             target:(id)target
                                             action:(SEL)action;

- (void)applyNavigationBarRightButtonWithSpinner;

- (void)applyNavigationBarLeftButtonWithText:(NSString*)text
                                      target:(id)target
                                      action:(SEL)action
                            horizontalOffset:(CGFloat)horizontalOffset;

- (void)applyNavigationBarLeftButtonWithText:(NSString*)text
                                      target:(id)target
                                      action:(SEL)action;

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
                             horizontalOffset:(CGFloat)horizontalOffset;

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
                                   edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)applyNavigationBarRightButtonWithLongText:(NSString*)text
                                           target:(id)target
                                           action:(SEL)action
                                       edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action;

- (void)applyNavigationBarGreenRightButtonWithText:(NSString*)text
                                            target:(id)target
                                            action:(SEL)action;

- (void)applyNavigationBarTitle:(NSString*)title;

- (void)applyCancelNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyBackNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyBackNavigationButtonWithColor:(UIColor*)color target:(id)target action:(SEL)action;

- (void)applyCameraNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyGearNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyNextNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyInfoNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyPersonNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyPersonStalkerNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyAddPersonNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyPlusNavigationButtonWithTarget:(id)target action:(SEL)action;

- (void)applyInboxNavigationButtonWithTarget:(id)target action:(SEL)action;

#pragma mark - Views

- (void)showView:(UIView*)view animated:(BOOL)animated;
- (void)hideView:(UIView*)view animated:(BOOL)animated;
- (void)toggleHiddenView:(UIView*)view animated:(BOOL)animated;

#pragma mark - Loading spinner

// will show loading spinner in self.view if no view specified
- (void)startLoadingSpinnner;
- (void)startLoadingSpinnnerInView:(UIView*)view;
- (void)stopLoadingSpinnner;
- (void)stopLoadingSpinnnerInView:(UIView*)view;

#pragma mark - NSNotificationCenter observer helper

- (RACDisposable*)observeNotification:(NSString*)notificationName
                             notified:(void(^)(NSNotification *note))notified;

#pragma mark - Motion Effects

- (void)addTiltToView:(UIView *)view;
- (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y ToView:(UIView *)view;
- (void)removeTiltOnView:(UIView*)view;

@end
