//
//  HBRegisterViewController.m
//  HollerbackApp
//
//  Created by poprot on 10/2/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <ReactiveCocoa.h>

#import "UIColor+JNHelper.h"
#import "UIViewController+JNHelper.h"

#import "SGAPIClient.h"
#import "SGSession.h"
#import "SGContact+Service.h"

#import "HBRegisterViewController.h"
#import "HBCountryPickerViewController.h"

@interface HBRegisterViewController () <UITextFieldDelegate, HBCountryPickerViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelCollection;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UIButton *countryPickerButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneButton;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberDisclaimerLabel;

@property (nonatomic, strong) NSNumber *hasValidTextFields;
@property (nonatomic) BOOL isGoingNext;

@property (nonatomic, copy) NSString *countryCode;

@property (strong, nonatomic) HBCountryPickerViewController *countryPickerViewController;

- (IBAction)countryPickerAction:(id)sender;

@end

@implementation HBRegisterViewController

- (void)initialize
{
    _hasValidTextFields = @(NO);
    self.isGoingNext = NO;
}

- (id)initWithTitle:(NSString*)title email:(NSString*)email password:(NSString*)password delegate:(id<HBRegisterViewDelegate>)delegate
{
    self = [super initWithNib];
    if(self) {
        self.title = title;
        _email = email;
        _password = password;
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
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationBar];
    
    [self setupViews];
    
    [self setupSignals];
    
    // log metric
    [SGSession didOnboardingActivity:kSGOnboardingUsername];
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
    
    self.usernameLabel.text = self.usernameLabel.text.uppercaseString;
    
    // username text field
	self.usernameTextField.tag = 1001;
	self.usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
	self.usernameTextField.returnKeyType = UIReturnKeyDone;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//	self.usernameTextFieldInset = UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0);
	self.usernameTextField.placeholder = @"Username";
	UIImageView *person = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"person-icon.png"]];
	person.frame = CGRectMake(8.0, 8.0, 34, 34);
	[self.usernameTextField addSubview:person];
    
    [self.countryPickerButton setTitle:@"United States (USA)" forState:UIControlStateNormal];
    
    self.countryLabel.text = self.countryLabel.text.uppercaseString;
    
    // country code text field
    self.countryCodeTextField.tag = 1003;
    self.countryCodeTextField.keyboardType = UIKeyboardTypePhonePad;
    self.countryCodeTextField.textAlignment = NSTextAlignmentCenter;
    self.countryCodeTextField.text = @"+1";
    
    // phone number text field
    self.phoneTextField.tag = 1004;
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTextField.placeholder = @"(555) 555-5555";
    // format phone number dynamically
    [[self.phoneTextField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField *textField) {
        NSString *text = textField.text;
        // only format if US number
        if ([self.countryCode isEqualToString:SGDefaultRegion]) {
            NSString *formattedPhoneNumber = [SGContact formatPhoneNumberForNationalDisplay:text];
            if ([NSString isNotEmptyString:formattedPhoneNumber]) {
                textField.text = formattedPhoneNumber;
            }
        } else {
            textField.text = text;
        }
    }];
    
    // apply common stuff for textfields
    for (UITextField *textField in self.textFieldCollection) {
        textField.delegate = self;
        [textField reloadInputViews];
        textField.textColor = JNBlackTextColor;
    }
    
//    // borders
//    [self.usernameTextField applyTopBorder];
//    [self.usernameTextField applyBottomBorder];
//    [self.phoneButton applyRightBorder];
//    [self.phoneButton applyBottomBorder];
//    [self.countryCodeTextField applyRightBorder];
//    [self.countryCodeTextField applyBottomBorder];
//    [self.phoneTextField applyBottomBorder];
//    
//    // apply styles for buttons
//    for (UIButton *button in self.buttonCollection) {
//        [UIButton applyWhiteButtonStyle:button];
//        [button setHasBorders:NO];
//    }
//    
//    // borders
//    [self.countryPickerButton applyTopBorder];
//    [self.countryPickerButton applyBottomBorder];
    
    // apply styles for labels
    for (UILabel *label in self.labelCollection) {
        label.textColor = JNBlackTextColor;
        label.font = [UIFont primaryFont];
    }
    self.usernameLabel.font = [UIFont primaryFontWithSectionTitleSize];
    self.countryLabel.font = [UIFont primaryFontWithSectionTitleSize];
    
    self.phoneNumberDisclaimerLabel.font = [UIFont primaryFontWithSize:10.0];
    
    self.countryPickerViewController = [[HBCountryPickerViewController alloc] initWithNibName:@"HBCountryPickerViewController" bundle:nil];
    self.countryPickerViewController.delegate = self;
    [self addChildViewController:self.countryPickerViewController];
    
    // attempt to get country code from user's location
    [self.countryPickerViewController.diallingCode getDiallingCodeForCurrentLocation];
}

- (void)setupSignals
{
    self.hasValidTextFields = @(NO);
    NSArray *latest = @[RACObserve(self.usernameTextField, text),
                        RACObserve(self.countryCodeTextField, text),
                        RACObserve(self.phoneTextField, text)];
    RAC(self, hasValidTextFields) = [RACSignal combineLatest:latest
                                                     reduce:^(NSString *username, NSString *countryCode, NSString *phone) {
                                                         return @(
                                                         [NSString isNotEmptyString:self.usernameTextField.text]	&&
                                                         [NSString isNotEmptyString:self.countryCodeTextField.text] &&
                                                         [NSString isNotEmptyString:self.phoneTextField.text]);
                                                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.countryPickerViewController.delegate) {
        self.countryPickerViewController.delegate = self;
    }
    // re-enable view interactions
    [self enableViewInteractions];
}

- (void)viewWillDisappear:(BOOL)animated
{
    JNLog();
    [super viewWillDisappear:animated];
    
    self.countryPickerViewController.delegate = nil;
    [self finishedWithCountryPicker];
    
    [self dismissKeyboard];
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
    if (self.isGoingNext) {
        return;
    } else {
        self.isGoingNext = YES;
    }
    
    // phone
    NSString *username = self.usernameTextField.text;
    NSString *phone = self.phoneTextField.text;
    
    // validate
    if (![NSString isNotEmptyString:phone]) {
        [JNAlertView showWithTitle:@"Oops!" body:@"Phone number is required."];
        return;
    }
    NSString *fullPhone = [NSString stringWithFormat:@"%@%@", self.countryCodeTextField.text, self.phoneTextField.text];
    if ([fullPhone rangeOfString:@"+"].location == NSNotFound) {
        fullPhone = [NSString stringWithFormat:@"+%@", fullPhone];
    }
    
    [self applyNavigationBarRightButtonWithSpinner];
    // disable view interactions
    [self disableViewInteractions];
    
    [self performRegisterWithPhone:fullPhone username:username completed:^{
        // next
        [self setupNextNavBarButton];
        // re-enable view interactions
        [self enableViewInteractions];
    }];
}


- (IBAction)countryPickerAction:(id)sender
{
    JNLog();
    [self dismissKeyboard];
    
    [self showNavigationBar];
    
    [self showCountryPickerViewController];
}

static BOOL _keyboardDidShow;

- (void)UIKeyboardDidShow:(id)sender
{
    _keyboardDidShow = YES;
}

- (void)UIKeyboardDidHide:(id)sender
{
    _keyboardDidShow = NO;
    [self showCountryPickerViewController];
}

- (void)showCountryPickerViewController
{
    [self.view addSubview:self.countryPickerViewController.view];
    [self.countryPickerViewController show];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - UITextFieldDelegate

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
    // reposition view to make text fields visible
    if ([textField isEqual:self.usernameTextField]) {
        [self showNavigationBar];
    }
    if ([textField isEqual:self.countryCodeTextField] || [textField isEqual:self.phoneTextField]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [textField addToolbarWithDoneTarget:self doneAction:@selector(textFieldShouldReturn:)
                                 prevTarget:nil prevAction:nil
                                 nextTarget:nil nextAction:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    
    if ([textField isEqual:self.countryCodeTextField] || [textField isEqual:self.phoneTextField]) {
        [self showNavigationBar];
    }
    
    if (self.hasValidTextFields.boolValue &&
        !self.isGoingNext) {
        [self nextAction:nil];
    }
    
    return NO;
}

- (void)showNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - HBCountryPickerViewDelegate

- (void)didSelectCountryDiallingCode:(NSString*)countryDiallingCode name:(NSString*)name
{
    self.countryCode = [SGContact countryCodeForCountryDialingCode:countryDiallingCode];
    // remove placeholder text if not from USA
    if (![self.countryCode isEqualToString:SGDefaultRegion]) {
        self.phoneTextField.placeholder = nil;
    }
    [self finishedWithCountryPicker];
    // populate fields
    [self.countryPickerButton setTitle:name forState:UIControlStateNormal];
    self.countryCodeTextField.text = [NSString stringWithFormat:@"+%@", countryDiallingCode];
}

- (void)didNotSelectCountryDiallingCode
{
    [self finishedWithCountryPicker];
}

- (void)finishedWithCountryPicker
{
    [self.countryPickerViewController.view removeFromSuperview];
}

#pragma mark - Login/Register

- (void)willPerformAccountRequest
{
    [self.view endEditing:YES];
}

- (void)performRegisterWithPhone:(NSString*)phone username:(NSString*)username completed:(void(^)())completed
{
    [self willPerformAccountRequest];
    
    NSString *formattedPhoneNumber = [SGContact formatPhoneNumberForSending:phone];
    if ([NSString isNotEmptyString:formattedPhoneNumber]) {
        phone = formattedPhoneNumber;
    }
    
    [[SGSession sharedInstance]
     registerWithEmail:self.email
     password:self.password
     username:username
     phone:phone
     success:^(id object) {
         NSString *phoneNormalized = [((NSDictionary *)object) valueForKeyPath:@"user.phone_normalized"];
         [self.delegate didRegisterWithPhone:phoneNormalized];
         if (completed) completed();
     } fail:^(NSString *errorMessage) {
         [JNAlertView showWithTitle:@"Oops" body:errorMessage];
         if (completed) completed();
     }];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end