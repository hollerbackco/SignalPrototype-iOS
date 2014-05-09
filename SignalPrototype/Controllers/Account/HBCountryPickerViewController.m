//
//  HBCountryPickerViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 21/04/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <CountryPicker.h>

#import "HBCountryPickerViewController.h"

@interface HBCountryPickerViewController () <CountryPickerDelegate, UIActionSheetDelegate, HMDiallingCodeDelegate>

@property (strong, nonatomic) CountryPicker *countryPicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (copy, nonatomic) NSString *selectedCountryName;

@end

@implementation HBCountryPickerViewController

- (void)initialize
{
    // diallingCode
    _diallingCode = [[HMDiallingCode alloc] initWithDelegate:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    
    // toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hide)];
    [toolbar setItems:@[flexButton, doneButton] animated:YES];
    [_actionSheet addSubview:toolbar];
    
    // country picker
    CGRect pickerFrame = CGRectMake(0, toolbar.frame.size.height, 0, 0);
    _countryPicker = [[CountryPicker alloc] initWithFrame:pickerFrame];
    _countryPicker.showsSelectionIndicator = YES;
    _countryPicker.delegate = self;
    [_actionSheet addSubview:_countryPicker];
}

#pragma mark - Public methods

- (void)show
{
    [_actionSheet showInView:self.view];
    [_actionSheet setBounds:CGRectMake(0, 0, 320, 44 + 415)];
}

- (void)hide
{
    [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [_delegate didNotSelectCountryDiallingCode];
}

#pragma mark - CountryPickerDelegate

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    _selectedCountryName = name;
    [_diallingCode getDiallingCodeForCountry:code];
}

#pragma mark - HMDiallingCodeDelegate

- (void)failedToGetDiallingCode
{
    [_delegate didNotSelectCountryDiallingCode];
}

- (void)didGetDiallingCode:(NSString *)diallingCode forCountry:(NSString *)countryCode
{
    if (!_selectedCountryName) {
        _selectedCountryName = [[CountryPicker countryNamesByCode] objectForKey:countryCode.uppercaseString];
    }
    [_delegate didSelectCountryDiallingCode:diallingCode name:_selectedCountryName];
}

- (void)didGetCountries:(NSArray *)countries forDiallingCode:(NSString *)diallingCode
{
//    
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
