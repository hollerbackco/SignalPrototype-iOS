//
//  HBCreateAccountViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <ReactiveCocoa.h>

#import "UIColor+JNHelper.h"
#import "UIViewController+JNHelper.h"
//#import "UIButton+JNHelper.h"

#import "SGSession.h"

#import "JNAlertView.h"

#import "HBLoginViewController.h"

@interface HBLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;

@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgottenPasswordButton;

@property (weak, nonatomic) IBOutlet UILabel *disclosureLabel;
@property (weak, nonatomic) IBOutlet UIButton *privacy;
@property (weak, nonatomic) IBOutlet UIButton *terms;

@property (nonatomic, strong) NSNumber *hasValidTextFields;
@property (nonatomic) BOOL isGoingNext;
@property (nonatomic) BOOL shouldResetPasswordText;

@end

@implementation HBLoginViewController

- (void)initialize
{
    _hasValidTextFields = @(NO);
    self.isGoingNext = NO;
    self.shouldResetPasswordText = NO;
}

- (id)initWithTitle:(NSString *)title mode:(HBLoginViewControllerMode)mode delegate:(id)delegate
{
    if (self == [super initWithNib]) {
        self.title = title;
        _mode = mode;
        _delegate = delegate;
    }
    return self;
}

- (void)setHasValidTextFields:(NSNumber *)hasValidTextFields
{
    _hasValidTextFields = hasValidTextFields;
    self.navigationItem.rightBarButtonItem.customView.hidden = !hasValidTextFields.boolValue;
}

- (void) showLegal;
{
	/*
	[self presentViewController:<#(UIViewController *)#> animated:YES completion:^{
		
	}];*/
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self setupViews];
    
    [self setupSignals];
    
    // log metric if this is a register
    if (self.mode == HBLoginViewControllerRegisterMode) {
        [SGSession didOnboardingActivity:kSGOnboardingEmail];
    }
}

- (void)setupNavigationBar
{
    [super setupNavigationBar];
    
    [self applyBackNavigationButtonWithTarget:self action:@selector(goBackAction:)];

    [self setupNextNavBarButton];
}

- (void)setupNextNavBarButton
{
    // NOTE: right bar button item is hidden initially until input has been entered
    [self applyNextNavigationButtonWithTarget:self action:@selector(nextAction:)];
    self.isGoingNext = NO;
}

- (void)setupViews
{
    self.view.backgroundColor = JNGrayBackgroundColor;
    
    self.sectionLabel.font = [UIFont primaryFontWithSectionTitleSize];
    self.sectionLabel.text = self.title.uppercaseString;
    self.sectionLabel.textColor = JNBlackTextColor;
    
    self.emailTextField.tag = 1003;
    self.emailTextField.backgroundColor = JNWhiteColor;
	self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.emailTextField.placeholder = @"Email";
    
	UIImageView *envelope = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hb-email-icon.png"]];
	envelope.frame = CGRectMake(12.75, 12.75, 23.5, 23.5);
	[self.emailTextField addSubview:envelope];
	
	self.passwordTextField.tag = 1002;
    self.passwordTextField.backgroundColor = JNWhiteColor;
	self.passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
	self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.passwordTextField.secureTextEntry = YES;
	self.passwordTextField.placeholder = @"Password";
    
	UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hb-lock-icon.png"]];
	lock.frame = CGRectMake(12.75, 12.75, 23.5, 23.5);
	[self.passwordTextField addSubview:lock];
    
    self.disclosureLabel.textColor = JNBlackTextColor;
	[self.privacy addTarget:self action:@selector(goToPrivacyPolicy) forControlEvents:UIControlEventTouchUpInside];
    [self.privacy setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
    [self.privacy setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	[self.terms addTarget:self action:@selector(goToTermsOfService) forControlEvents:UIControlEventTouchUpInside];
    [self.terms setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
    [self.terms setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    if (self.mode == HBLoginViewControllerLoginMode) {
        [self.forgottenPasswordButton setTitleColor:JNBlackTextColor forState:UIControlStateNormal];
        [self.forgottenPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        self.forgottenPasswordButton.titleLabel.font = [UIFont primaryFont];
        [self.forgottenPasswordButton addTarget:self action:@selector(goToForgottenPassword) forControlEvents:UIControlEventTouchUpInside];
        // hide views
        self.disclosureLabel.hidden = YES;
        self.privacy.hidden = YES;
        self.terms.hidden = YES;
    } else {
        // hide view
        self.forgottenPasswordButton.hidden = YES;
    }
	
    // apply common stuff for textfields
    for (UITextField *textField in self.textFieldCollection) {
        textField.delegate = self;
        [textField reloadInputViews];
        textField.textColor = JNBlackTextColor;
    }
}

- (void)setupSignals
{
    self.hasValidTextFields = @(NO);
    NSArray *latest = @[RACObserve(self.emailTextField, text),
                        RACObserve(self.passwordTextField, text)];
    RAC(self, hasValidTextFields) = [RACSignal combineLatest:latest
                                                     reduce:^(NSString *email, NSString *password) {
                                                         return @(
                                                         [NSString isNotEmptyString:self.emailTextField.text] &&
                                                         [NSString isNotEmptyString:self.passwordTextField.text]);
                                                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // re-enable view interactions
    [self enableViewInteractions];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    if (self.delegate) {
        [self.delegate didCancel];
    }
}

- (void)nextAction:(id)sender
{
    if (self.isGoingNext) {
        return;
    } else {
        self.isGoingNext = YES;
    }
    
    // validate
    NSString *email = self.emailTextField.text;
    if (![NSString isNotEmptyString:email]) {
        [JNAlertView showWithTitle:@"Oops!" body:@"Email number is required."];
        return;
    }
    
    NSString *password = self.passwordTextField.text;
    if (![NSString isNotEmptyString:password]) {
        [JNAlertView showWithTitle:@"Oops!" body:@"Password is required."];
        return;
    }

    [self applyNavigationBarRightButtonWithSpinner];
    
    // disable view interactions
    [self disableViewInteractions];
    
    [self willPerformAccountRequest];
    switch (self.mode) {
        case HBLoginViewControllerLoginMode: {
            [self performLoginWithEmail:email password:password];
            break;
        } case HBLoginViewControllerRegisterMode: {
            [self performRegisterWithEmail:email password:password];
            break;
        } default:
            break;
    }
}

- (void) goToPrivacyPolicy
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hollerback.co/privacy"]];
}

- (void) goToTermsOfService
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hollerback.co/terms"]];
}

- (void)goToForgottenPassword
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hollerback.co/forgotpw"]];
}

static BOOL _keyboardDidShow;

- (void)UIKeyboardDidShow:(id)sender
{
    _keyboardDidShow = YES;
}

- (void)UIKeyboardDidHide:(id)sender
{
    _keyboardDidShow = NO;
}

#pragma mark - HBTextFieldDelegate

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (CGFloat)navBarHeight
{
    return self.navigationController.navigationBar.frame.size.height;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.shouldResetPasswordText && textField == self.passwordTextField) {
        self.passwordTextField.text = nil;
        self.shouldResetPasswordText = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    
    if (self.hasValidTextFields.boolValue &&
        !self.isGoingNext) {
        [self nextAction:nil];
    }
        
	return YES;
}

#pragma mark - Login/Register

- (void)willPerformAccountRequest
{
    [self.view endEditing:YES];
}

#pragma mark - Login mode

- (void)performLoginWithEmail:(NSString*)email password:(NSString*)password
{
    [[SGSession sharedInstance] loginWithEmail:email password:password success:^(id object) {
        [self.delegate didLogin];
        // next
        [self setupNextNavBarButton];
        // re-enable view interactions
        [self enableViewInteractions];
    } fail:^(NSString *errorMessage) {
        self.shouldResetPasswordText = YES;
        [self displayError:errorMessage];
        // next
        [self setupNextNavBarButton];
        // re-enable view interactions
        [self enableViewInteractions];
    }];
}

#pragma mark - Register mode

- (void)performRegisterWithEmail:(NSString*)email password:(NSString*)password
{
    // save password for verify screen
    [SGSession storeSignUpPassword:password];
    
    [[SGSession sharedInstance] checkEmail:email success:^(id object) {
        [self.delegate didSignUpWithEmail:email password:password];
        // next
        [self setupNextNavBarButton];
        // re-enable view interactions
        [self enableViewInteractions];
    } fail:^(NSString *errorMessage) {
        self.shouldResetPasswordText = YES;
        [self displayError:errorMessage];
        // next
        [self setupNextNavBarButton];
        // re-enable view interactions
        [self enableViewInteractions];
    }];
}

#pragma mark - 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
