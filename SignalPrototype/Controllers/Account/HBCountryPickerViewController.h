//
//  HBCountryPickerViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 21/04/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMDiallingCode.h"

@protocol HBCountryPickerViewDelegate

- (void)didSelectCountryDiallingCode:(NSString*)countryDiallingCode name:(NSString*)name;
- (void)didNotSelectCountryDiallingCode;

@end

@interface HBCountryPickerViewController : UIViewController

@property (weak, nonatomic) id<HBCountryPickerViewDelegate> delegate;
@property (strong, nonatomic) HMDiallingCode *diallingCode;
@property (strong, nonatomic) UIToolbar *toolbar;

- (void)show;

@end
