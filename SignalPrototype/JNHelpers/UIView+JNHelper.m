//
//  UIView+JNHelper.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 15/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "UIView+JNHelper.h"
#import "UIColor+JNHelper.h"

CGFloat const kHBViewAnimationFastDuration = 0.3;

@implementation UIView (JNHelper)

+ (void)hideAndRemoveView:(UIView*)view
{
    [UIView animateWithDuration:kHBViewAnimationFastDuration animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [view performBlock:^{
            [view removeFromSuperview];
        } afterDelay:kHBViewAnimationFastDuration];
    }];
}

+ (void)animateWithBlock:(void (^)(void))animations
{
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:animations];
}

+ (void)animateLayoutConstraintsWithContainerView:(UIView*)containerView
                                        childView:(UIView*)childView
                                         duration:(NSTimeInterval)duration
                                       animations:(void (^)(void))animations
{
    [self.class animateLayoutConstraintsWithContainerView:containerView
                                                childView:childView
                                                 duration:duration
                                               animations:animations
                                               completion:nil];
}

+ (void)animateLayoutConstraintsWithContainerView:(UIView*)containerView
                                        childView:(UIView*)childView
                                         duration:(NSTimeInterval)duration
                                       animations:(void (^)(void))animations
                                       completion:(void (^)(BOOL finished))completion
{
    [containerView layoutIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        if (animations) animations();
        [childView setNeedsUpdateConstraints];
        [containerView layoutIfNeeded];
    } completion:completion];
}

+ (void)transformViewFlipHorizontally:(UIView*)view
{
    view.transform = CGAffineTransformMakeRotation(M_PI);
}

+ (void)transformViewRotate180:(UIView*)view
{
    view.transform = CGAffineTransformMakeRotation(-M_PI);
}

- (void)fadeInAnimated:(BOOL)animated
{
    [self fadeInAnimated:animated complete:nil];
}

- (void)fadeOutAnimated:(BOOL)animated
{
    [self fadeOutAnimated:animated complete:nil];
}

- (void)fadeInAnimated:(BOOL)animated complete:(HBViewComplete)complete
{
    if (self.hidden) {
        [self toggleAnimated:animated complete:complete];
    } else {
        if (complete)
            complete(YES);
    }
}

- (void)fadeOutAnimated:(BOOL)animated complete:(HBViewComplete)complete
{
    if (!self.hidden) {
        [self toggleAnimated:animated complete:complete];
    } else {
        if (complete)
            complete(YES);
    }
}

- (void)toggleAnimated:(BOOL)animated complete:(HBViewComplete)complete
{
    if (!animated) {
        self.hidden = !self.hidden;
        if (complete)
            complete(YES);
        return;
    }
    self.alpha = (self.hidden) ? 0.0 : 1.0;
    [UIView animateWithDuration:kHBViewAnimationFastDuration
                     animations:^{
                         self.alpha = (self.alpha == 0.0) ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = !self.hidden;
                         if (complete)
                             complete(finished);
                     }];
}

- (void)setCircleLayerMask
{
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.layer.masksToBounds = YES;
}

- (void)applyDarkShadowLayer
{
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 0.5;
}

- (void)applyDarkerShadowLayer
{
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 2.0;
    self.layer.shadowRadius = 1.0;
}

- (void)applyDarkBottomShadowLayer
{
    self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 1.0;
}

- (void)applyGradientBackgroundWithTopColor:(UIColor*)topColor bottomColor:(UIColor*)bottomColor
{
    self.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradientLayer = [UIColor gradientWithTopColor:topColor bottomColor:bottomColor];
    gradientLayer.bounds = self.bounds;
    gradientLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)removeAllSublayers
{
    self.layer.sublayers = nil;
}

#pragma mark - Rounded Corner

- (void)applyRoundedCornerWithRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)removeRoundedCorner
{
    self.layer.cornerRadius = 0.0;
    self.layer.masksToBounds = NO;
}

@end

#pragma mark - CALayer

@implementation CALayer (JNHelper)

+ (CALayer*)circleLayerWithSize:(CGSize)circleSize
                    strokeColor:(UIColor*)strokeColor
                      fillColor:(UIColor*)fillColor
                      lineWidth:(CGFloat)lineWidth
{
    CGPoint position = CGPointMake(circleSize.width/2, circleSize.height/2);
    return [[self class] circleLayerWithSize:circleSize
                                    position:position
                                 strokeColor:strokeColor
                                   fillColor:fillColor
                                   lineWidth:lineWidth];
}

+ (CALayer*)circleLayerWithSize:(CGSize)circleSize
                       position:(CGPoint)position
                    strokeColor:(UIColor*)strokeColor
                      fillColor:(UIColor*)fillColor
                      lineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.bounds = (CGRect){CGPointZero, circleSize};
    circleLayer.position = position;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){CGPointZero, circleSize}];
    circleLayer.path = [path CGPath];
    if (strokeColor) {
        circleLayer.strokeColor = strokeColor.CGColor;
    }
    if (fillColor) {
        circleLayer.fillColor = fillColor.CGColor;
    }
    circleLayer.lineWidth = lineWidth;
    
    return circleLayer;
}

@end




#pragma mark - HBViewWithTouchableSubviews

@implementation HBViewWithTouchableSubviews : UIView

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

@end








#pragma mark - CALayer (RoundedCorners)

@implementation CALayer (RoundedCorners)

+ (void)maskRoundCorners:(UIRectCorner)corners radius:(CGFloat)radius view:(UIView*)view
{
    // To round all corners, we can just set the radius on the layer
    if ( corners == UIRectCornerAllCorners ) {
        view.layer.cornerRadius = radius;
        view.layer.masksToBounds = YES;
    } else {
        view.layer.cornerRadius = 0.0;
        view.layer.mask = [CALayer maskLayerWithCorners:corners radii:CGSizeMake(radius, radius) frame:view.bounds];
    }
}

+ (id)maskLayerWithCorners:(UIRectCorner)corners radii:(CGSize)radii frame:(CGRect)frame
{
    // Create a CAShapeLayer
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = frame;
    mask.path = [UIBezierPath bezierPathWithRoundedRect:mask.bounds byRoundingCorners:corners cornerRadii:radii].CGPath;
    mask.fillColor = [UIColor whiteColor].CGColor;
    return mask;
}

@end









#pragma mark - UITextField (JNHelper)

@implementation UITextField (JNHelper)

- (void)awakeFromNib
{
    [self applyPadding];
}

- (void)applyPadding
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    
    self.rightView = paddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)addToolBarItem:(NSString*)title target:(id)target action:(SEL)action
{   
    if (!jn_toolbar) {
        jn_toolbar = [[UIToolbar alloc] init];
        [jn_toolbar setBarStyle:UIBarStyleDefault];
        [jn_toolbar sizeToFit];
    } else {
        jn_toolbar.items = nil;
    }
    
    NSMutableArray *items = [@[] mutableCopy];
    if ([NSArray isEmptyArray:jn_toolbar.items]) {
        // Flex
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [items addObject:flexButton];
        // Done
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
        [items addObject:button];
        
        jn_toolbar.items = items;
    }
}

static UIToolbar *jn_toolbar;

- (void)addToolbarWithDoneTarget:(id)doneTarget doneAction:(SEL)doneAction
prevTarget:(id)prevTarget prevAction:(SEL)prevAction
nextTarget:(id)nextTarget nextAction:(SEL)nextAction
{
    if (!jn_toolbar) {
        jn_toolbar = [[UIToolbar alloc] init];
        [jn_toolbar setBarStyle:UIBarStyleDefault];
        [jn_toolbar sizeToFit];
    } else {
        jn_toolbar.items = nil;
    }
    
    NSMutableArray *items = [@[] mutableCopy];
    
    // Previous
    if (prevTarget && prevAction) {
        UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:prevTarget action:prevAction];
        [items addObject:prevButton];
    }
    // Next
    if (nextTarget && nextAction) {
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:nextTarget action:nextAction];
        [items addObject:nextButton];
    }
    
    if (doneTarget && doneAction) {
        // Flex
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [items addObject:flexButton];
        // Done
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:doneTarget action:doneAction];
        [items addObject:doneButton];
    }
    
    jn_toolbar.items = items;
    self.inputAccessoryView = jn_toolbar;
}

- (void)removeToolBarItems
{
    [jn_toolbar setItems:@[] animated:YES];
}

@end









#pragma mark - UIBarButtonItem (JNHelper)

@implementation UIBarButtonItem (JNHelper)

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action font:(UIFont*)font textColor:(UIColor*)textColor
{
    if (self == [self initWithBarButtonSystemItem:systemItem target:target action:action]) {
        [[UIBarButtonItem appearance]
         setTitleTextAttributes:@{NSFontAttributeName : font,
                                  NSForegroundColorAttributeName: textColor}
         forState:UIControlStateNormal];
    }
    return self;
}

@end
