//
//  HBWelcomeAllowPushViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 23/03/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "HBWelcomeAllowPushViewController.h"
#import "HBPushNotificationHandler.h"

@interface HBWelcomeAllowPushViewController ()

@end

@implementation HBWelcomeAllowPushViewController

#pragma mark - Init

- (id)initWithNib
{
    if (self == [super initWithNibName:@"HBBaseWelcomeViewController" bundle:nil]) {
    }
    return self;
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setupViews
{
    [super setupViews];
    
    if ([NSString isNotEmptyString:self.contentTitle]) {
        self.contentTitleLabel.text = self.contentTitle;
    } else {
        self.contentTitleLabel.text = JNLocalizedString(@"welcome.allow.push.title");
    }
    self.contentBodyLabel.attributedText = [NSAttributedString
                                            attributedStringWithParagrahLineHeight:self.contentBodyLabel.font.pointSize
                                            localizedKey:@"welcome.allow.push.body"];
    self.contentBodyLabel.numberOfLines = 0;
    [self.contentBodyLabel sizeToFit];
    self.firstButton.alpha = 0.0;
    [self.secondButton setTitle:JNLocalizedString(@"welcome.allow.push.second.button.text") forState:UIControlStateNormal];
    
    self.phoneOutlineImageView.image = [UIImage imageNamed:@"phone-outline.png"];
    self.phoneOutlineImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.phoneInnerImageView1.image = [UIImage imageNamed:@"phone-inner-push.png"];
    self.phoneInnerImageView1.contentMode = UIViewContentModeCenter;
}

#pragma mark - Actions

- (void)secondAction:(id)sender
{
    JNLog();
    // register for push
    [HBPushNotificationHandler registerForPushNotificationsCompleted:^{
        if (self.finishedViewController) {
            self.finishedViewController();
        }
    } denied:^{
        [JNAlertView
         showWithTitle:JNLocalizedString(@"welcome.allow.push.denied.alert.title")
         body:JNLocalizedString(@"welcome.allow.push.denied.alert.body")
         okAction:^{
             if (self.finishedViewController) {
                 self.finishedViewController();
             }
         }];
    }];
}

@end
