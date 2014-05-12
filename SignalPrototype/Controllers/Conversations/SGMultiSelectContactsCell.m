//
//  SGMultiSelectContactsCell.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/07/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "UIFont+JNHelper.h"
#import "UIColor+JNHelper.h"

#import "SGMultiSelectContactsCell.h"

#define SGMultSelectContactsCellIconImageSize 14.0
#define SGMultSelectContactsCellRightOffset 30.0
#define SGMultSelectContactsCellNameLabelHeight 20.0
#define SGMultSelectContactsCellUsernameLabelHeight 16.0
#define SGMultSelectContactsCellTopOffset 6.0

@interface SGMultiSelectContactsCell ()

@property (nonatomic, strong) UIImage *bananaIconImage;
@property (nonatomic, strong) UIImage *radioIconImage;
@property (nonatomic, strong) UIImage *selectedIconImage;
@property (nonatomic, strong) UIImageView *bananaImageView;
@property (nonatomic, strong) UIImageView *radioImageView;

@end

@implementation SGMultiSelectContactsCell

- (void)initialize
{   
    self.textLabel.font = [UIFont primaryFontWithSize:16.0];
    // pad an empty accessory view
    self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 1.0)];
    
    // name
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width - SGMultSelectContactsCellRightOffset, SGMultSelectContactsCellNameLabelHeight)];
    _nameLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - SGMultSelectContactsCellTopOffset);
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = JNColorWithRGB(2, 2, 2, 1.0);
    _nameLabel.font = [UIFont primaryFontWithSize:16.0];
    [self.contentView addSubview:_nameLabel];
    
    // username
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width - SGMultSelectContactsCellRightOffset, SGMultSelectContactsCellUsernameLabelHeight)];
    _usernameLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(_nameLabel.frame) + SGMultSelectContactsCellNameLabelHeight/2 + 4.0);
    _usernameLabel.backgroundColor = [UIColor clearColor];
    _usernameLabel.textColor = JNColorWithRGB(2, 2, 2, 1.0);
    _usernameLabel.font = [UIFont primaryFontWithSize:12.0];
    [self.contentView addSubview:_usernameLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)prepareForReuse
{
    self.textLabel.text = nil;
    self.nameLabel.text = nil;
    self.usernameLabel.text = nil;
    self.hasSignedUp = NO;
    self.isSelected = NO;
    
    self.nameLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - SGMultSelectContactsCellTopOffset);
    self.usernameLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.nameLabel.frame) + SGMultSelectContactsCellNameLabelHeight/2 + 4.0);
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected) {
        if (!_radioImageView) {
            CGFloat selectedImageOffset = 20.0;
            _radioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SGMultSelectContactsCellIconImageSize, SGMultSelectContactsCellIconImageSize)];
            if (self.bananaImageView) {
                _radioImageView.center = CGPointMake(CGRectGetMinX(self.bananaImageView.frame) - 10.0, CGRectGetMidY(self.bounds));
            } else {
                _radioImageView.center = CGPointMake(self.bounds.size.width - SGMultSelectContactsCellIconImageSize - selectedImageOffset, CGRectGetMidY(self.bounds));
            }
            [self.contentView addSubview:_radioImageView];
        }
        if (!_selectedIconImage)
            _selectedIconImage = [UIImage imageNamed:@"checkmark-icon.png"];
        _radioImageView.image = _selectedIconImage;
    } else {
        if (self.radioImageView) {
            [self.radioImageView removeFromSuperview];
            self.radioImageView = nil;
        }
    }
}

- (void)setHasSignedUp:(BOOL)hasSignedUp
{
    _hasSignedUp = hasSignedUp;
    if (_hasSignedUp) {
        if (!_bananaIconImage)
            _bananaIconImage = [UIImage imageNamed:@"small-banana.png"];
        if (!_bananaImageView) {
            CGFloat imageOffset = 20.0;
            _bananaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 21.0, 21.0)];
            _bananaImageView.center = CGPointMake(self.bounds.size.width - imageOffset - self.bananaImageView.bounds.size.width/2, self.bounds.size.height/2);
            _bananaImageView.image = _bananaIconImage;
            [self.contentView addSubview:_bananaImageView];
        }
    } else {
        if (self.bananaImageView) {
            [self.bananaImageView removeFromSuperview];
            _bananaImageView = nil;
        }
    }
}

- (void)verticallyAlignNameLabel
{
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, CGRectGetMidY(self.bounds));
}

@end
