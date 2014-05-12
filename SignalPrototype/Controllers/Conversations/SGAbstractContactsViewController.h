//
//  SGAbstractContactsViewController.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 28/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "JNViewController.h"
#import "SGContact.h"
#import "SGMultiSelectContactsCell.h"

@interface SGAbstractContactsViewController : JNViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> //, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noContactsLabel;

@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, copy) NSString *promptText;

// Contacts
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic) BOOL isLoading;

// Search
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

// Filtered contacts
@property (nonatomic, strong) NSMutableArray *filteredSections;
@property (nonatomic) BOOL shouldDisplayFilteredContacts;
@property(strong) dispatch_queue_t filteringQueue;

// Blocks
@property (nonatomic, copy) void(^didSelectContact)(SGContact *contact);

#pragma mark - Public

- (void)setIsLoading:(BOOL)isLoading;

- (void)resetView;

- (void)resetSearch;

- (void)reloadTableView;

- (void)didFinishBuildingContacts;

#pragma mark - Helpers

- (void)tableView:(UITableView *)tableView configureCell:(SGMultiSelectContactsCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)indexOfContact:(SGContact*)contact inContacts:(NSArray*)contacts;

- (NSString*)phoneNumberFromRHPerson:(RHPerson*)person;

@end
