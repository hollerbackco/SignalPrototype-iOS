//
//  SGHollerbackContactsViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 27/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGHollerbackContactsViewController.h"

@interface SGHollerbackContactsViewController ()

@end

@implementation SGHollerbackContactsViewController

- (void)didFinishBuildingContacts
{
    JNLog();
    [super didFinishBuildingContacts];
    
    if (self.noContactsLabel) {
        self.noContactsLabel.text = NSLocalizedString(@"no hollerback contacts label text", nil);
    }
}

- (void)tableView:(UITableView *)tableView configureCell:(SGMultiSelectContactsCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView configureCell:cell forRowAtIndexPath:indexPath];
    
    cell.hasSignedUp = YES;
}

@end
