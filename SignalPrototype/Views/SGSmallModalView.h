//
//  SGSmallModalView.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 18/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+JNHelper.h"

@class SGSmallModalView;

typedef void(^SGSmallModalViewBlock)(SGSmallModalView *alertView);

typedef enum {
    SGSmallModalViewModeNone,
    SGSmallModalViewModeSending,
    SGSmallModalViewModeSendingWithProgress,
    SGSmallModalViewModeSaved,
    SGSmallModalViewModeErrorRetry,
} SGSmallModalViewMode;

@interface SGSmallModalView : UIView

#pragma mark - Singleton

+ (SGSmallModalView*)sharedInstance;

#pragma mark -

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIImageView *alertImageView;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIButton *actionbutton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIProgressView *sendingProgressView;

@property (nonatomic) SGSmallModalViewMode mode;
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, copy) NSString *topLabelText;
@property (nonatomic, copy) NSString *bottomLabelText;
@property (nonatomic, copy) SGSmallModalViewBlock didCancelBlock;
@property (nonatomic, copy) void (^actionBlock)(id object);
@property (nonatomic) CGFloat progress;

- (id)initWithMode:(SGSmallModalViewMode)mode parentView:(UIView*)parentView;

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
          complete:(HBViewComplete)complete;

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
         tapTarget:(id)tapTarget
         tapAction:(SEL)tapAction
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete;

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
           topText:(NSString*)topText
        bottomText:(NSString*)bottomText
          animated:(BOOL)animated
         tapTarget:(id)tapTarget
         tapAction:(SEL)tapAction
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete;

- (void)showInView:(UIView*)view
              mode:(SGSmallModalViewMode)mode
          animated:(BOOL)animated
         didAction:(void (^)(id object))actionBlock
         didCancel:(SGSmallModalViewBlock)didCanceBlock
          complete:(HBViewComplete)complete;

- (void)hideAnimated:(BOOL)animated complete:(HBViewComplete)complete;

@end
