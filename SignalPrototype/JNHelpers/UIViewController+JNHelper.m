//
//  UIViewController+JNHelper.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 12/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <SDWebImageManager.h>
#import <NSNotificationCenter+RACSupport.h>

#import "UIFont+JNHelper.h"
#import "UIColor+JNHelper.h"
#import "UIImage+JNHelper.h"
#import "UIViewController+JNHelper.h"
#import "JNIcon.h"

CGFloat const kJNNavigationBarTitleFontSize = 16.0;
CGFloat const kJNNavigationBarHeight = 51.0;
CGFloat const kJNStandardNavigationBarHeight = 44.0;

CGFloat const kJNNavigationBarButtonWidth = 60.0;
CGFloat const kJNNavigationBarButtonLongWidth = 92.0;

static CAShapeLayer *_navBarBottomBorderLayer;
static UIImage *_defaultNavigationBarBackgroundImage;

@implementation UIViewController (JNHelper)

- (void)applyTranslucentNavigationBarStyle
{
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = nil;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self setupDefaultNavigationBarTitleAttributes];
}

- (void)applyOpaqueNavigationBarStyle
{
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = JNWhiteColor;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupDefaultNavigationBarTitleAttributes];
}

- (void)applyOpaqueNavigationBarStyleWithNavBarColor:(UIColor*)navBarColor
{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = navBarColor;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)applyFadingNavbarShadow
{
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"nav-bar-shadow.png"];
}

- (void)applyDefaultNavbarShadow
{
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)setupDefaultNavigationBarTitleAttributes
{
    [self setupDefaultNavigationBarTitleAttributesTitleColor:JNBlackColor
                                          barButtonItemColor:JNWhiteColor];
}

- (void)setupDefaultNavigationBarTitleAttributesTitleColor:(UIColor*)titleColor
                                        barButtonItemColor:(UIColor*)barButtonItemColor
{
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName: titleColor,
      NSFontAttributeName: [UIFont primaryFontWithTitleSize]};
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: barButtonItemColor,
       NSFontAttributeName: [UIFont primaryFontWithTitleSize]} forState:UIControlStateNormal];
}

static UIImageView *_navigationBarLogoImageView;

- (void)applyNavigationBarLogo
{
    if (!_navigationBarLogoImageView) {
        UIImage *logoImage = [UIImage imageNamed:@"big-banana.png"];
        logoImage = [UIImage imageWithImage:logoImage scaledToSize:CGSizeMake(32.0, 32.0)];
        _navigationBarLogoImageView = [[UIImageView alloc] initWithImage:logoImage];
        _navigationBarLogoImageView.center =
        CGPointMake(CGRectGetMidX(self.navigationController.navigationBar.bounds),
                    CGRectGetMidY(self.navigationController.navigationBar.bounds) - 2.0);
        [self.navigationController.navigationBar addSubview:_navigationBarLogoImageView];
    }
    _navigationBarLogoImageView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        _navigationBarLogoImageView.alpha = 1.0;
    }];
}

- (void)removeNavigationBarLogo
{
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        _navigationBarLogoImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self performBlock:^{
            if (_navigationBarLogoImageView) {
                [_navigationBarLogoImageView removeFromSuperview];
                _navigationBarLogoImageView = nil;
            }            
        } afterDelay:UINavigationControllerHideShowBarDuration];
    }];
}

- (void)applyNavigationBarTitle:(NSString*)title
{
    self.title = title;
}

- (UIBarButtonItem*)createBarButtonItemWithImageNamed:(NSString*)imageName
                                          imageOffset:(CGPoint)imageOffset
                                               target:(id)target
                                               action:(SEL)action
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.height}}];
    imageView.frame = CGRectOffset(imageView.frame, imageOffset.x, imageOffset.y);
    [view addSubview:imageView];
    if (target && action) {
        // tap gesture
        UITapGestureRecognizer *settingsGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [view addGestureRecognizer:settingsGesture];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)applyNavigationBarLeftButtonWithImageNamed:(NSString*)imageName
                                       imageOffset:(CGPoint)imageOffset
                                            target:(id)target
                                            action:(SEL)action
{
    self.navigationItem.leftBarButtonItem = [self createBarButtonItemWithImageNamed:imageName imageOffset:imageOffset target:target action:action];
}

- (void)applyNavigationBarRightButtonWithImageNamed:(NSString*)imageName
                                        imageOffset:(CGPoint)imageOffset
                                             target:(id)target
                                             action:(SEL)action
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonItemWithImageNamed:imageName imageOffset:imageOffset target:target action:action];
}

- (void)applyNavigationBarRightButtonWithSpinner
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonItemWithSpinner];
}

- (UIBarButtonItem*)createBarButtonItemWithSpinner
{
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.height}}];
    UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinnerView.frame = CGRectOffset(spinnerView.frame, 20.0, 12.0);
    [spinnerView startAnimating];
    [view addSubview:spinnerView];
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (UIBarButtonItem*)createBarButtonItemWithText:(NSString*)text
                                backgroundLayer:(CALayer*)backgroundLayer
                                    strokeLayer:(CALayer*)strokeLayer
                                         target:(id)target
                                         action:(SEL)action
							   horizontalOffset:(float)horizontalOffset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
	button.bounds = CGRectMake(0.0, 0.0, kJNNavigationBarButtonWidth, self.navigationController.navigationBar.bounds.size.height);
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont primaryFontWithTitleSize];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (backgroundLayer) {
        backgroundLayer.frame = CGRectOffset(backgroundLayer.frame, horizontalOffset, 0.0);
        [button.layer insertSublayer:backgroundLayer atIndex:0];
    }
    if (strokeLayer) {
        strokeLayer.frame = CGRectOffset(strokeLayer.frame, horizontalOffset, 0.0);
        [button.layer insertSublayer:strokeLayer atIndex:1];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


- (UIBarButtonItem*)createBarButtonItemWithText:(NSString*)text
                                          width:(CGFloat)width
                                         target:(id)target
                                         action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = (CGRect) {CGPointZero, {width, self.navigationController.navigationBar.bounds.size.height}};
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont primaryFontWithTitleSize];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)applyNavigationBarLeftButtonWithText:(NSString*)text
                                      target:(id)target
                                      action:(SEL)action
{
    [self applyNavigationBarLeftButtonWithText:text
                                        target:target
                                        action:action
                              horizontalOffset:-10.0];
}

- (void)applyNavigationBarLeftButtonWithText:(NSString*)text
                                      target:(id)target
                                      action:(SEL)action
                            horizontalOffset:(CGFloat)horizontalOffset
{
    self.navigationItem.leftBarButtonItem = [self createBarButtonItemWithText:text width:kJNNavigationBarButtonWidth target:target action:action];
    ((UIButton*) self.navigationItem.leftBarButtonItem.customView).titleEdgeInsets = UIEdgeInsetsMake(0.0, horizontalOffset, 0.0, 0.0);
}

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
{
    [self applyNavigationBarRightButtonWithText:text
                                         target:target
                                         action:action
                               horizontalOffset:14.0];
}

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
                             horizontalOffset:(CGFloat)horizontalOffset
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonItemWithText:text
                                                                         width:kJNNavigationBarButtonWidth
                                                                        target:target
                                                                        action:action];
    ((UIButton*) self.navigationItem.rightBarButtonItem.customView).titleEdgeInsets = UIEdgeInsetsMake(0.0, horizontalOffset, 0.0, 0.0);
}

- (void)applyNavigationBarRightButtonWithText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
                                   edgeInsets:(UIEdgeInsets)edgeInsets
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonItemWithText:text
                                                                         width:kJNNavigationBarButtonWidth
                                                                        target:target
                                                                        action:action];
    ((UIButton*) self.navigationItem.rightBarButtonItem.customView).titleEdgeInsets = edgeInsets;
}

- (void)applyNavigationBarRightButtonWithLongText:(NSString*)text
                                       target:(id)target
                                       action:(SEL)action
                                   edgeInsets:(UIEdgeInsets)edgeInsets
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonItemWithText:text
                                                                         width:kJNNavigationBarButtonLongWidth
                                                                        target:target
                                                                        action:action];
    ((UIButton*) self.navigationItem.rightBarButtonItem.customView).titleEdgeInsets = edgeInsets;
}

- (void)applyCancelNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon cancelImageIconWithSize:44.0 color:JNWhiteColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)applyBackNavigationButtonWithTarget:(id)target action:(SEL)action
{
    [self applyBackNavigationButtonWithColor:JNWhiteColor target:target action:action];
}

- (void)applyBackNavigationButtonWithColor:(UIColor*)color target:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon chevronLeftImageIconWithSize:34.0 color:color];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)applyCameraNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon cameraImageIconWithSize:34.0 color:JNWhiteColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)applyGearNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon gearImageIconWithSize:30.0 color:JNWhiteColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = leftBarButtonItem;
}

- (void)applyNextNavigationButtonWithTarget:(id)target action:(SEL)action
{
    [self applyNavigationBarRightButtonWithText:NSLocalizedString(@"next.nav.bar.button.text", nil)
                                         target:target
                                         action:action
                                     edgeInsets:UIEdgeInsetsMake(1.0, 0.0, 0.0, -28.0)];
}

- (void)applyInfoNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon infoImageIconWithSize:30.0 color:JNWhiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)applyPersonNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon personImageIconWithSize:30.0 color:JNWhiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)applyPersonStalkerNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon personStalkerImageIconWithSize:30.0 color:JNWhiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)applyAddPersonNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon addPersonImageIconWithSize:24.0 color:JNWhiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)applyPlusNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [JNIcon plusImageIconWithSize:40.0 color:JNWhiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)applyInboxNavigationButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *cancelImage = [JNIcon inboxImageIconWithSize:30.0 color:JNGrayColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, cancelImage.size.width, cancelImage.size.height)];
    [cancelButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -14.0);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = leftBarButtonItem;
}

#pragma mark - Views

- (void)showView:(UIView*)view animated:(BOOL)animated
{
    [view fadeInAnimated:animated];
}

- (void)hideView:(UIView*)view animated:(BOOL)animated
{
    [view fadeOutAnimated:animated];
}

- (void)toggleHiddenView:(UIView*)view animated:(BOOL)animated
{
    [view toggleAnimated:animated complete:nil];
}

#pragma mark - Loading spinner

// will show loading spinner in self.view if no view specified
- (void)startLoadingSpinnner
{
    [self startLoadingSpinnnerInView:self.view];
}

static int JNLoadingSpinnerViewTag = 190283;

- (void)startLoadingSpinnnerInView:(UIView*)view
{
    UIActivityIndicatorView *loadingSpinner = (UIActivityIndicatorView*) [view viewWithTag:JNLoadingSpinnerViewTag];
    if (!loadingSpinner || ![loadingSpinner isKindOfClass:[UIActivityIndicatorView class]]) {
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingSpinner.tag = JNLoadingSpinnerViewTag;
        [view addSubview:loadingSpinner];
        [view bringSubviewToFront:loadingSpinner];
        JNLog(@"view: %@", NSStringFromCGRect(view.frame));
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        [view addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:loadingSpinner
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    }
    [loadingSpinner startAnimating];
}

- (void)stopLoadingSpinnner
{
    [self stopLoadingSpinnnerInView:self.view];
}

- (void)stopLoadingSpinnnerInView:(UIView*)view
{
    UIActivityIndicatorView *loadingSpinner = (UIActivityIndicatorView*) [view viewWithTag:JNLoadingSpinnerViewTag];
    if (loadingSpinner && [loadingSpinner isKindOfClass:[UIActivityIndicatorView class]]) {
        [loadingSpinner stopAnimating];
    }
}

#pragma mark - NSNotificationCenter observer helper

- (RACDisposable*)observeNotification:(NSString*)notificationName
                             notified:(void(^)(NSNotification *note))notified
{
    __block RACDisposable *disposable =
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:notificationName
      object:nil]
     subscribeNext:^(NSNotification *note) {
         if (notified) {
             notified(note);
         }
     }];
    return disposable;
}

#pragma mark - Motion Effects

- (void)addTiltToView:(UIView *)view
{
    [self addHorizontalTilt:kJNMotionTiltAmount verticalTilt:kJNMotionTiltAmount ToView:view];
}

- (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y ToView:(UIView *)view
{
    UIInterpolatingMotionEffect *xAxis = nil;
    UIInterpolatingMotionEffect *yAxis = nil;
    
    if (x != 0.0)
    {
        xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-x];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:x];
    }
    
    if (y != 0.0)
    {
        yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-y];
        yAxis.maximumRelativeValue = [NSNumber numberWithFloat:y];
    }
    
    if (xAxis || yAxis)
    {
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        NSMutableArray *effects = [[NSMutableArray alloc] init];
        if (xAxis)
        {
            [effects addObject:xAxis];
        }
        
        if (yAxis)
        {
            [effects addObject:yAxis];
        }
        group.motionEffects = effects;
        [view addMotionEffect:group];
    }
}

- (void)removeTiltOnView:(UIView*)view
{
    [view.motionEffects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [view removeMotionEffect:obj];
    }];
}

@end
