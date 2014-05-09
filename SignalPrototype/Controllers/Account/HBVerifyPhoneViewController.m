//
//  HBVerifyPhoneViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import <ReactiveCocoa.h>

#import "UIColor+JNHelper.h"
#import "UIFont+JNHelper.h"
#import "UIViewController+JNHelper.h"
#import "UIImage+JNHelper.h"

#import "JNSimpleDataStore.h"
#import "JNAlertView.h"

#import "SGAPIClient.h"
#import "SGAppDelegate.h"
#import "SGSession.h"
#import "SGContact+Service.h"
#import "SGSmallModalView.h"

#import "HBVerifyPhoneViewController.h"

@interface HBVerifyPhoneViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelCollection;

@property (weak, nonatomic) IBOutlet UILabel *topTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *pinTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendPinButton;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;

@property (nonatomic, strong) NSNumber *hasValidPinNumber;

- (IBAction)sendPinAction:(id)sender;

@end

@implementation HBVerifyPhoneViewController

- (void)setHasValidPinNumber:(NSNumber *)hasValidPinNumber
{
    _hasValidPinNumber = hasValidPinNumber;
    runOnMainQueue(^{
//        if (hasValidPinNumber.boolValue) {
            self.navigationItem.rightBarButtonItem.customView.hidden = NO;
            [self.pinTextField addToolBarItem:JNLocalizedString(@"next.toolbar.button.text") target:self action:@selector(nextAction:)];
            [self.pinTextField setNeedsDisplay];
//        } else {
//            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
//            [self.pinTextField removeToolBarItems];
//            [self.pinTextField setNeedsDisplay];
//        }
    });
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self setupViews];
    
    [self setupSignals];
    
    NSString *formattedPhoneNumber = [SGContact formatPhoneNumberForInternationalDisplay:self.phoneNormalized];
    if ([NSString isNullOrEmptyString:formattedPhoneNumber]) {
        formattedPhoneNumber = self.phoneNormalized;
    }
    self.phoneNumberLabel.text = formattedPhoneNumber;
        
    [self.phoneNumberLabel sizeToFit];
    
    // log metric
    [SGSession didOnboardingActivity:kSGOnboardingVerifyPhone];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupNavigationBar
{
    self.title = @"Verify Number";
    
    [super setupNavigationBar];
    
    [self applyBackNavigationButtonWithTarget:self action:@selector(goBackAction:)];
    
    [self setupNextNavBarButton];
}

- (void)setupNextNavBarButton
{
    // NOTE: right bar button item is hidden initially until input has been entered
    [self applyNextNavigationButtonWithTarget:self action:@selector(nextAction:)];
}

- (void)setupViews
{
    self.view.backgroundColor = JNGrayBackgroundColor;

    // top label
    self.topTextLabel.font = [UIFont primaryFontWithTitleSize];
    self.topTextLabel.textColor = JNBlackTextColor;

    // phone label
    self.phoneNumberLabel.font = [UIFont primaryFontWithSize:25.0];
    self.phoneNumberLabel.textColor = JNBlackTextColor;
    
    // pin text field
    self.pinTextField.keyboardType = UIKeyboardTypeNumberPad;
//    self.pinTextFieldInset = UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0);
    self.pinTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.pinTextField.placeholder = @"Enter Pin # from SMS";
    [self.pinTextField becomeFirstResponder];
//    [self.pinTextField setHasBorders:NO];
//    [self.pinTextField applyTopBorder];
//    [self.pinTextField applyBottomBorder];
    
    // help label
    self.helpLabel.backgroundColor = [UIColor clearColor];
    self.helpLabel.font = [UIFont primaryFont];
    self.helpLabel.textColor = JNBlackTextColor;
    
    // resend pin button
    [self.resendPinButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.resendPinButton.titleLabel.text
                                                                         attributes:@{
                                                                NSFontAttributeName: [UIFont primaryFont],
                                                      NSUnderlineStyleAttributeName: @1,
                                                     NSForegroundColorAttributeName: JNBlackTextColor,
                                                         NSStrokeColorAttributeName: JNBlackTextColor}]
                                forState:UIControlStateNormal];
    [self.resendPinButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.resendPinButton.titleLabel.text
                                                                         attributes:@{
                                                                NSFontAttributeName: [UIFont primaryFont],
                                                      NSUnderlineStyleAttributeName: @1,
                                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSStrokeColorAttributeName: [UIColor blackColor]}]
                                forState:UIControlStateSelected|UIControlStateHighlighted];
    
    // apply common stuff for textfields
    for (UITextField *textField in self.textFieldCollection) {
        textField.delegate = self;
        [textField reloadInputViews];
        textField.textColor = JNBlackTextColor;
    }
    
    [self.pinTextField addToolBarItem:JNLocalizedString(@"next.toolbar.button.text") target:self action:@selector(nextAction:)];
}

- (void)setupSignals
{
    self.hasValidPinNumber = @(NO);
    
    RAC(self, hasValidPinNumber) = [RACSignal combineLatest:@[RACObserve(self.pinTextField, text)]
                                                     reduce:^(NSString *pin) {
                                                         return @([NSString isNotEmptyString:self.pinTextField.text]);
                                                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // re-enable view interactions
    [self enableViewInteractions];
}

- (void)enableViewInteractions
{
    self.view.userInteractionEnabled = YES;
}

- (void)disableViewInteractions
{
    self.view.userInteractionEnabled = NO;
}

#pragma mark - Actions

- (void)goBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(id)sender
{
    NSString *code = self.pinTextField.text;
    [self performVerifyWithPhone:self.phoneNormalized code:code];
}

- (IBAction)sendPinAction:(id)sender
{
    [self sendPinWithPhone:self.phoneNormalized];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [textField addToolbarWithDoneTarget:nil doneAction:nil
//                             prevTarget:nil prevAction:nil
//                             nextTarget:nil nextAction:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

#pragma mark - Verify

- (void)didVerifyPhoneForUser:(id)user
{
    // finish
    if (self.delegate)
        [self.delegate controller:self didVerifyPhoneForUser:user];
}

- (void)performVerifyWithPhone:(NSString*)phone code:(NSString*)code
{
    [self.view endEditing:YES];
    
    [[SGSmallModalView sharedInstance] showInView:self.view mode:SGSmallModalViewModeSending animated:YES complete:nil];
    [SGSmallModalView sharedInstance].bottomLabelText = @"Verifying...";
    
    [self applyNavigationBarRightButtonWithSpinner];
    
    NSString *password = [SGSession getSignUpPassword];
    
    [[SGSession sharedInstance]
     verifyWithPhone:phone
     code:code
     password:password
     success:^(id object) {
         // finish
         [self didVerifyPhoneForUser:object[@"user"]];
         
         // remove sign up password
         [SGSession storeSignUpPassword:nil];
         
         [[SGSmallModalView sharedInstance] hideAnimated:YES complete:nil];
         // next
         [self setupNextNavBarButton];
         // re-enable view interactions
         [self enableViewInteractions];
         
     } fail:^(NSString *errorMessage) {
         [[SGSmallModalView sharedInstance] hideAnimated:YES complete:nil];
         [JNAlertView showWithTitle:@"Oops" body:errorMessage];
         // next
         [self setupNextNavBarButton];
         // re-enable view interactions
         [self enableViewInteractions];
     }];
}


#pragma mark - Resend phone

- (void)sendPinWithPhone:(NSString*)phone
{
    [self.view endEditing:YES];
    
    [[SGSmallModalView sharedInstance] showInView:self.view mode:SGSmallModalViewModeSending animated:YES complete:nil];
    [SGSmallModalView sharedInstance].bottomLabelText = @"Sending Pin...";
    
    [[SGAPIClient sharedClient] sendPinWithPhone:phone success:^(id object) {
        [[SGSmallModalView sharedInstance] hideAnimated:YES complete:nil];
    } fail:^(NSString *errorMessage) {
        [[SGSmallModalView sharedInstance] hideAnimated:YES complete:nil];
        [JNAlertView showWithTitle:@"Oops" body:errorMessage];
    }];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
