//
//  SGSmallModalView.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 18/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIFont+JNHelper.h"
#import "UIColor+JNHelper.h"
#import "UIImage+JNHelper.h"

#import "SGSmallModalView.h"

#define kHBSmallModalSuccessColor JNColorWithRGB(45,159,0,1)

CGFloat const SGSmallModalViewWhiteBackgroundAlpha = 0.8;
CGFloat const SGSmallModalViewSize = 180.0;
CGFloat const SGSmallModalViewCornerRadius = 24.0;
CGFloat const SGSmallModalViewInnerPadding = 24.0;
CGFloat const SGSmallModalViewTopFontSize = 12.0;
CGFloat const SGSmallModalViewTopLabelHeight = 20.0;
CGFloat const SGSmallModalViewBottomFontSize = 20.0;
CGFloat const SGSmallModalViewBottomLabelHeight = 32.0;
CGFloat const SGSmallModalViewAlertImageSize = 80.0;

@interface SGSmallModalView () <UIGestureRecognizerDelegate>

@end

@implementation SGSmallModalView

#pragma mark - Singleton

static SGSmallModalView *sharedInstance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedInstance = [[SGSmallModalView alloc] initWithMode:SGSmallModalViewModeNone parentView:nil];
    }
}

+ (SGSmallModalView*)sharedInstance
{
    return sharedInstance;
}

#pragma mark - Inits

- (void)initialize
{
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:SGSmallModalViewWhiteBackgroundAlpha];
    self.layer.cornerRadius = SGSmallModalViewCornerRadius;
    self.layer.masksToBounds = YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    
    // top label
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, SGSmallModalViewSize - 2 *SGSmallModalViewInnerPadding, SGSmallModalViewTopLabelHeight)];
    _topLabel.center = CGPointMake(self.bounds.size.width/2, SGSmallModalViewInnerPadding + SGSmallModalViewTopLabelHeight/2);
    _topLabel.font = [UIFont primaryFontWithSize:SGSmallModalViewTopFontSize];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_topLabel];
    
    // alert image
    _alertImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _alertImageView.center = CGPointMake(SGSmallModalViewSize/2, SGSmallModalViewSize/2);
    _alertImageView.bounds = CGRectMake(0.0, 0.0, SGSmallModalViewAlertImageSize, SGSmallModalViewAlertImageSize);
    _alertImageView.backgroundColor = [UIColor clearColor];    
    [self addSubview:_alertImageView];
    
    // bottom label
    _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(SGSmallModalViewInnerPadding, SGSmallModalViewSize - SGSmallModalViewInnerPadding - SGSmallModalViewBottomLabelHeight/2, SGSmallModalViewSize - 2 *SGSmallModalViewInnerPadding, SGSmallModalViewBottomLabelHeight)];
    _bottomLabel.font = [UIFont primaryFontWithSize:SGSmallModalViewBottomFontSize];
    _bottomLabel.backgroundColor = [UIColor clearColor];
    _bottomLabel.textAlignment = NSTextAlignmentCenter;    
    [self addSubview:_bottomLabel];
    
    // action button
    _actionbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionbutton.frame = self.bounds;
    [_actionbutton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:_actionbutton atIndex:0];
    [self bringSubviewToFront:_actionbutton];
    
    // cancel button
    CGFloat cancelButtonSize = 44.0;
    UIImage *crossCircleImage = [UIImage imageNamed:@"cross-circle.png"];
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setImage:crossCircleImage forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(SGSmallModalViewSize - cancelButtonSize - 4.0, 4.0, cancelButtonSize, cancelButtonSize);
    [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:_cancelButton atIndex:0];
    [self bringSubviewToFront:_cancelButton];
    _cancelButton.hidden = YES;
    
    // progress view
    _sendingProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _sendingProgressView.center = CGPointMake(SGSmallModalViewSize/2, SGSmallModalViewSize/2);
    _sendingProgressView.progressImage = [UIImage imageWithColor:kHBSmallModalSuccessColor];
    _sendingProgressView.trackImage = [UIImage imageWithColor:[UIColor lightGrayColor]];
    _sendingProgressView.layer.cornerRadius = _sendingProgressView.frame.size.height/2;
    _sendingProgressView.layer.masksToBounds = YES;
    
    self.alpha = 0.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithMode:(SGSmallModalViewMode)mode parentView:(UIView*)parentView
{
    CGRect frame = CGRectMake(parentView.bounds.size.width/2 - SGSmallModalViewSize/2, parentView.bounds.size.height/2 - SGSmallModalViewSize/2, SGSmallModalViewSize, SGSmallModalViewSize);
    if (self = [self initWithFrame:frame]) {
        self.mode = mode;
    }
    return self;
}

#pragma mark - Properties

- (void)setMode:(SGSmallModalViewMode)mode
{
    _topLabel.text = @"";
    _alertImageView.backgroundColor = [UIColor clearColor];
    _alertImageView.layer.cornerRadius = 0.0;
    _alertImageView.image = nil;
    _cancelButton.hidden = YES;
    for (UIView *view in _alertImageView.subviews) {
        [view removeFromSuperview];
    }
    _bottomLabel.text = @"";
    _sendingProgressView.progress = 0.0;
    [_sendingProgressView removeFromSuperview];
    switch (mode) {
        case SGSmallModalViewModeNone:
            break;
        case SGSmallModalViewModeSending: {
            _alertImageView.backgroundColor = [UIColor lightGrayColor];
            _alertImageView.layer.cornerRadius = _alertImageView.frame.size.width/2;
            _alertImageView.layer.masksToBounds = YES;
            UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinnerView.center = CGPointMake(_alertImageView.bounds.size.width/2, _alertImageView.bounds.size.height/2);
//            spinnerView.transform = CGAffineTransformMakeScale(3.0, 3.0);
            [_alertImageView addSubview:spinnerView];
            [spinnerView startAnimating];
            _bottomLabel.text = @"sending...";
            _bottomLabel.textColor = kHBSmallModalSuccessColor;
            break;
        }
        case SGSmallModalViewModeSendingWithProgress: {
            _alertImageView.backgroundColor = [UIColor clearColor];
            [self addSubview:_sendingProgressView];
            _bottomLabel.text = @"sending...";
            _bottomLabel.textColor = kHBSmallModalSuccessColor;
            break;
        }
        case SGSmallModalViewModeSaved: {
            _alertImageView.image = [UIImage imageNamed:@"alert-success-icon.png"];
            _bottomLabel.text = @"Sent";
            _bottomLabel.textColor = kHBSmallModalSuccessColor;
            break;
        }
        case SGSmallModalViewModeErrorRetry: {
            [self setupErrorRetryAlertView];
            _topLabel.text = @"Sorry, there was a problem.";
            _topLabel.numberOfLines = 2;
            [_topLabel sizeToFit];
            _topLabel.center = CGPointMake(self.bounds.size.width/2, SGSmallModalViewInnerPadding + SGSmallModalViewTopLabelHeight/2);
            _cancelButton.hidden = NO;
            break;
        }   
        default:
            break;
    }
}

- (void)setupErrorRetryAlertView
{
    _alertImageView.image = [UIImage imageNamed:@"alert-error-icon.png"];
    _topLabel.textColor = [UIColor blackColor];
    _bottomLabel.text = @"tap to resend";
    _bottomLabel.textColor = [UIColor blackColor];
}

- (void)setTopLabelText:(NSString *)topLabelText
{
    _topLabelText = topLabelText;
    _topLabel.text = _topLabelText;
}

- (void)setBottomLabelText:(NSString *)bottomLabelText
{
    _bottomLabelText = bottomLabelText;
    _bottomLabel.text = _bottomLabelText;
}

- (void)action:(id)sender
{
    if (_actionBlock) {
        _actionBlock(self);
    }
}

- (void)cancel:(id)sender
{
    if (_didCancelBlock) {
        _didCancelBlock(self);
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _sendingProgressView.progress = progress;
}

#pragma mark -

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
          complete:(HBViewComplete)complete
{
    if (view != self.superview) {
        self.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        [view insertSubview:self atIndex:0];
        [view bringSubviewToFront:self];    
    } else {
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
    self.mode = mode;
}

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
         tapTarget:(id)tapTarget
         tapAction:(SEL)tapAction
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:tapTarget action:tapAction];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
    self.didCancelBlock = didCanceBlock;
    [self showInView:view mode:mode animated:animated complete:complete];
}

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
           topText:(NSString*)topText
        bottomText:(NSString*)bottomText
          animated:(BOOL)animated
         tapTarget:(id)tapTarget
         tapAction:(SEL)tapAction
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete
{
    [self showInView:view mode:mode animated:animated tapTarget:tapTarget tapAction:tapAction didCancel:didCanceBlock complete:complete];
    self.topLabelText = topText;
    self.bottomLabelText = bottomText;
}

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
         didAction:(void (^)(id object))actionBlock
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete
{
    self.actionBlock = actionBlock;
    self.didCancelBlock = didCanceBlock;
    [self showInView:view mode:mode animated:animated complete:complete];
}

- (void)hideWithAnimation:(id)sender
{
    [self hideAnimated:YES complete:^(BOOL finished) {
    }];
}

- (void)hideAnimated:(BOOL)animated complete:(HBViewComplete)complete
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (complete)
            complete(finished);
    }];
}

@end
