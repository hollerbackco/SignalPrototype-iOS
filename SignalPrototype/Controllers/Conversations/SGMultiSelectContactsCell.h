//
//  SGMultiSelectContactsCell.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//


@interface SGMultiSelectContactsCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL hasSignedUp;

- (void)verticallyAlignNameLabel;

@end
