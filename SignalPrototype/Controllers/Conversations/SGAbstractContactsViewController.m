//
//  SGAbstractContactsViewController.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 28/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import "SGAbstractContactsViewController.h"
#import "SGContact+Service.h"

@interface SGAbstractContactsViewController ()

// Selected Contacts
@property (nonatomic, strong) NSMutableArray *selectedContacts;

@end

@implementation SGAbstractContactsViewController

#pragma mark - Init

- (void)initialize
{
    self.hideNavigationBar = YES;
    
    _sections = [NSMutableArray arrayWithCapacity:1];
    _selectedContacts = [NSMutableArray arrayWithCapacity:1];
    
    self.isLoading = YES;
}

#pragma mark - Public

- (void)setContacts:(NSArray *)contacts
{
    if ([NSArray isEmptyArray:contacts]) {
        self.sections = [@[] mutableCopy];
    } else {
        self.sections = [[self partitionObjects:contacts collationStringSelector:@selector(name)] mutableCopy];
    }
    self.isLoading = NO;
    [self reloadTableView];
}

- (NSArray*)sections
{
    if (self.shouldDisplayFilteredContacts) {
        return _filteredSections;
    } else {
        return _sections;
    }
}

- (void)setPromptText:(NSString *)promptText
{
    _promptText = promptText;
    if (self.promptLabel) {
        self.promptLabel.text = promptText;
    }
}

- (void)setIsLoading:(BOOL)isLoading
{
    runOnMainQueue(^{
        if (isLoading) {
            if (!self.spinnerView) {
                self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                self.spinnerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
                [self.view addSubview:self.spinnerView];
                [self.spinnerView startAnimating];
            }
        } else {
            if (self.spinnerView) {
                [self.spinnerView stopAnimating];
            }
            [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
                    [((UIActivityIndicatorView*) obj) stopAnimating];
                }
            }];
        }
    });
}

- (void)resetView
{
    self.selectedContacts = nil;
    [self reloadTableView];
    [self resetSearch];
}

- (void)resetSearch
{
    self.searchBar.text = nil;
    self.shouldDisplayFilteredContacts = NO;
    self.searchController.active = NO;
}

- (void)reloadTableView
{
    runOnMainQueue(^{
        [self.tableView reloadData];
    });
}

- (void)didFinishBuildingContacts
{
    JNLog();
    if ([NSArray isEmptyArray:self.sections]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.noContactsLabel.alpha = 1.0;
            self.tableView.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.noContactsLabel.alpha = 0.0;
            self.tableView.alpha = 1.0;
        }];
    }
}

- (void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Helpers

- (NSUInteger)indexOfContact:(SGContact*)contact inContacts:(NSArray*)contacts
{
    __block NSUInteger index = NSNotFound;
    if ([NSArray isNotEmptyArray:contacts]) {
        [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SGContact class]]) {
                if ([NSString isNotEmptyString:((SGContact*) obj).phoneHashed]) {
                    if ([((SGContact*) obj).phoneHashed isEqualToString:contact.phoneHashed]) {
                        index = idx;
                        *stop = YES;
                    }
                } else {
                    NSArray *values1 = contact.phoneNumbers;
                    NSArray *values2 = ((SGContact*) obj).phoneNumbers;
                    if ([NSArray itemWithinArray:values1 containedInArray:values2]) {
                        index = idx;
                        *stop = YES;
                    }
                }
            } else if ([obj isKindOfClass:[RHPerson class]]) {
                NSArray *values1 = ((RHPerson*) contact).phoneNumbers.values;
                NSArray *values2 = ((RHPerson*) obj).phoneNumbers.values;
                if ([NSArray itemWithinArray:values1 containedInArray:values2]) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
    }
    return index;
}

- (NSString*)phoneNumberFromRHPerson:(RHPerson*)person
{
    NSArray *phoneNumberValues = ((RHPerson*) person).phoneNumbers.values;
    NSString *phoneNumber;
    if ([NSArray isNotEmptyArray:phoneNumberValues]) {
        if (phoneNumberValues.count == 1) {
            phoneNumber = phoneNumberValues.lastObject;
        } else {
            phoneNumber = [phoneNumberValues componentsJoinedByString:@","];
        }
    }
    return phoneNumber;
}


#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    [self setupTableView];
    
    [self setupSearch];
}

- (void)setupViews
{
    self.view.backgroundColor = JNGrayBackgroundColor;
    
    // prompt
    self.promptLabel.font = [UIFont primaryFontWithSize:12.0];
    self.promptLabel.textColor = JNBlackTextColor;
    self.promptLabel.backgroundColor = JNClearColor;
    if (self.promptText) {
        self.promptLabel.text = self.promptText;
    }
    
    // no contacts label
    self.noContactsLabel.backgroundColor = JNWhiteColor;
    self.noContactsLabel.font = [UIFont primaryFontWithSize:14.0];
    self.noContactsLabel.textColor = JNBlackColor;
    self.noContactsLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setupTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[SGMultiSelectContactsCell class] forCellReuseIdentifier:@"SGMultiSelectContactsCell"];
    self.tableView.separatorColor = JNColorWithRGB(170, 171, 171, 1.0);
}

- (void)setupSearch
{
    // search
    self.searchBar.barTintColor = JNGrayBackgroundColor;
    self.searchBar.delegate = self;
    self.searchController = [[UISearchDisplayController alloc]
                             initWithSearchBar:self.searchBar contentsController:self];
    [self.searchController.searchResultsTableView registerClass:[SGMultiSelectContactsCell class] forCellReuseIdentifier:@"SGMultiSelectContactsCell"];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
}

#pragma mark - Table view data source

- (SGContact*)contactForIndexPath:(NSIndexPath*)indexPath
{
    NSArray *contacts = [self.sections objectAtIndex:indexPath.section];
    return [contacts objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if ([NSArray isNotEmptyArray:self.sections]) {
        BOOL showSection = ((NSArray*) [self.sections objectAtIndex:section]).count != 0;
        //only show the section title if there are rows in the section
        if (showSection) {
            title = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if ([NSArray isNotEmptyArray:self.sections]) {
        NSArray *contacts = self.sections[section];
        if ([NSArray isNotEmptyArray:contacts]) {
            numberOfRows = contacts.count;
        }
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SGMultiSelectContactsCell";
    SGMultiSelectContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row <= [[self.sections objectAtIndex:indexPath.section] count] - 1) {
        [self tableView:tableView configureCell:cell forRowAtIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView configureCell:(SGMultiSelectContactsCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // reset cell
    UIView *loadingSpinnerView = [cell viewWithTag:SGLoadingSpinnerViewTag];
    if (loadingSpinnerView) {
        [loadingSpinnerView removeFromSuperview];
        cell.userInteractionEnabled = YES;
    }
    
    // Set cell details
    id contact = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([contact isKindOfClass:[SGContact class]]) {
        NSString *name = ((SGContact*) contact).name;
        NSString *username = ((SGContact*) contact).username;
        if ([NSString isNotEmptyString:name]) {
            cell.nameLabel.text = name;
            if ([NSString isNotEmptyString:username]) {
                cell.usernameLabel.text = username;
            }
        } else {
            if ([NSString isNotEmptyString:username]) {
                cell.textLabel.text = username;
            }
        }
        
    } else if ([contact isKindOfClass:[RHPerson class]]) {
        NSString *name = ((RHPerson*) contact).compositeName;
        cell.nameLabel.text = name;
        [cell verticallyAlignNameLabel];
        // not showing phone numbers
//        NSString *phoneNumber = [self phoneNumberFromRHPerson:((RHPerson*) contact)];
//        cell.usernameLabel.text = [NSString isNotEmptyString:phoneNumber] ? phoneNumber : @"-";
    }
    
    // is selected
    if ([self indexOfContact:contact inContacts:self.selectedContacts] == NSNotFound) { //[self contacts:self.selectedContacts hasMatchingContact:contact]) {
        cell.isSelected = NO;
    } else {
        cell.isSelected = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //sectionForSectionIndexTitleAtIndex: is a bit buggy, but is still useable
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - Select Contact

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id contact = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    // add to selected contacts
    NSUInteger index = [self indexOfContact:contact inContacts:self.selectedContacts];
    if (index == NSNotFound) {
        [self.selectedContacts addObject:contact];
        
        // update the cell isSelected without using tableView reloadRowsAtIndexPaths as this table changes dynamically
        [self tableView:tableView setIsSelectedOnCellForIndexPath:indexPath];
        
		// HOTFIX for known iOS7 seperator bug
		if (indexPath.row > 0) {
			NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            // update the cell display without using tableView reloadRowsAtIndexPaths as this table changes dynamically
            [self reloadSingleCellForIndexPath:path];
		}
        
        [self.searchController setActive:NO animated:YES];
    } else {
        [self.selectedContacts removeObjectAtIndex:index];
        [self tableView:tableView unselectContact:contact];
    }
    
    if (self.didSelectContact) {
        self.didSelectContact(contact);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView setIsSelectedOnCellForIndexPath:(NSIndexPath*)indexPath
{
    SGMultiSelectContactsCell *cell = (SGMultiSelectContactsCell*) [tableView cellForRowAtIndexPath:indexPath];
    if (cell && [tableView.visibleCells containsObject:cell]) {
        if (!cell.isSelected) {
            cell.isSelected = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView unselectContact:(id)contactToUnselect
{
    for (SGMultiSelectContactsCell *cell in tableView.visibleCells) {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        NSArray *allContacts = [self.sections objectAtIndex:indexPath.section];
        if ([NSArray isNotEmptyArray:allContacts]) {
            id contact = [allContacts objectAtIndex:indexPath.row];
            if ([contact isKindOfClass:SGContact.class] && [contactToUnselect isKindOfClass:SGContact.class]) {
                if ([NSString isNotEmptyString:((SGContact*) contact).phoneHashed]) {
                    if ([((SGContact*) contact).phoneHashed isEqualToString:((SGContact*) contactToUnselect).phoneHashed]) {
                        cell.isSelected = NO;
                    }
                } else {
                    if ([((SGContact*) contact).phoneNumbers isEqualToArray:((SGContact*) contactToUnselect).phoneNumbers]) {
                        cell.isSelected = NO;
                    }
                }
            } else if ([contact isKindOfClass:RHPerson.class] && [contactToUnselect isKindOfClass:RHPerson.class]) {
                if ([((RHPerson*) contact).phoneNumbers.values isEqualToArray:((RHPerson*) contactToUnselect).phoneNumbers.values]) {
                    cell.isSelected = NO;
                }
            }
        }
    }
}

- (void)reloadSingleCellForIndexPath:(NSIndexPath*)indexPath
{
    SGMultiSelectContactsCell *cell = (SGMultiSelectContactsCell*) [_tableView cellForRowAtIndexPath:indexPath];
    if (cell && [_tableView.visibleCells containsObject:cell]) {
        [cell setNeedsDisplay];
    }
}

#pragma mark - UISearchDisplayDelegate

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if ([NSString isNotEmptyString:searchText]) { // if text is empty
        self.shouldDisplayFilteredContacts = YES;
        if (!self.filteringQueue) {
            self.filteringQueue = dispatch_queue_create("FILTERING QUEUE", DISPATCH_QUEUE_SERIAL);
        }
        dispatch_sync(self.filteringQueue, ^{
            NSMutableArray *mutableFilteredSections = [NSMutableArray arrayWithCapacity:self.filteredSections.count];
            [_sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSPredicate *contactsPredicate = [NSPredicate predicateWithFormat:@"(SELF.class == %@ AND (SELF.name CONTAINS[cd] %@ OR SELF.name CONTAINS[cd] %@)) OR (SELF.class == %@ AND SELF.compositeName CONTAINS[cd] %@)", [SGContact class], searchText, searchText, [RHPerson class], searchText];
                NSArray *filteredContacts = [obj filteredArrayUsingPredicate:contactsPredicate];
                [mutableFilteredSections insertObject:filteredContacts atIndex:idx];
            }];
            self.filteredSections = mutableFilteredSections;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shouldDisplayFilteredContacts = NO;
            [self.tableView reloadData];
        });
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.shouldDisplayFilteredContacts = NO;
    [self.tableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;
{
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Indexed Sections

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}


@end
