//
//  BeerSortNameTableViewController.m
//  BeerPassport
//
//  Created by Matt Pearcy on 2013-01-30.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import "BeerSortNameTableViewController.h"
#import "Beverage.h"
#import "BeverageCell.h"
#import "User.h"
#import "BeerDetailViewController.h"
#import "SubmitTabViewController.h"

@interface BeerSortNameTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *beveragesDictionary;
@property (strong, nonatomic) NSMutableDictionary *nameIndexesDictionary;
@property (strong, nonatomic) NSArray *beverageNameIndexArray;

@property (assign, nonatomic) BOOL ascend; //controls ascending/descending sort


@end

@implementation BeerSortNameTableViewController

- (void)viewDidLoad
{
    // Lots of important stuff happens in here:
    [super viewDidLoad];
    
    self.title = @"Beer List";
}

#pragma mark - BeerTableViewController methods

- (void)reloadRowData:(NSNotification *)notification
{
    Beverage *bevToReload = [[notification userInfo] valueForKey:@"beer"];
    if (!bevToReload)
        return;
    
    //Find the indexPath the beverage is located at
    NSString *firstLetter = [bevToReload.name substringToIndex:1];
    NSInteger section = [self.beverageNameIndexArray indexOfObject:firstLetter];
    NSInteger row     = [[self beveragesWithInitialLetter:firstLetter] indexOfObject:bevToReload];
    
    if (section == NSNotFound || row == NSNotFound) {
        
        // Don't worry about it.. we are probably due to -reloadFromCoreData on next appearance.
        // Attempting to reload this would cause a crash
        return;
    }

    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
    
    //reload beer at indexPath on main table
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    
    UITableView *searchTableView = self.searchDisplayController.searchResultsTableView;
    NSIndexPath *searchRowSelected = [searchTableView indexPathForSelectedRow];
    
    //if we can find a row selected in the search results table then we probably launched from there.  Reload that row too
    if (searchRowSelected) {
        [searchTableView reloadRowsAtIndexPaths:@[searchRowSelected] withRowAnimation:UITableViewRowAnimationNone];
    }
}

// trigger when backend beverages have changed for resorting
- (void)reloadFromCoreData
{
    self.beveragesDictionary = [NSMutableDictionary dictionary];
    self.nameIndexesDictionary = [NSMutableDictionary dictionary];
    
    //retrieve latest beverages from coreData
    NSMutableArray *unfiltered = [[Beverage MR_findAll] mutableCopy];

    //remove all archived beverages that aren't on the users passport
    // Sort it alphabeticall so that our filtered beers are also displayed alphabetically
    NSSortDescriptor *nameSD = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                           ascending:YES
                                                            selector:@selector(localizedCaseInsensitiveCompare:)] ;

    self.beverages = [unfiltered sortedArrayUsingDescriptors:@[nameSD]];
    
    for (Beverage *bev in self.beverages) {
        [self.beveragesDictionary setObject:bev forKey:bev.name];
        
        NSString *firstLetter = [bev.name substringToIndex:1];
		NSMutableArray *existingArray = [self.nameIndexesDictionary valueForKey:firstLetter];
		
		// if an array already exists in the name index dictionary
		// simply add the beverage to it, otherwise create an array
		// and add it to the name index dictionary with the letter as the key
        if (existingArray) {
            [existingArray addObject:bev];
		} else {
			NSMutableArray *tempArray = [NSMutableArray array];
            [tempArray addObject:bev];
            [self.nameIndexesDictionary setObject:tempArray forKey:firstLetter];
		}
        
    }
    
    //sort beverage inital letter indexes
    self.beverageNameIndexArray = [[self.nameIndexesDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *eachNameIndex in self.beverageNameIndexArray) {
		[self presortElementNamesForInitialLetter:eachNameIndex];
	}
    
    [self.tableView reloadData];
}

- (Beverage *)beverageForIndexPath:(NSIndexPath *)indexPath
{
	return [[self beveragesWithInitialLetter:[[self beverageNameIndexArray] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}


- (IBAction)changeSort:(id)sender
{
    self.ascend = !self.ascend;
    [self flipSort];
    [self.tableView reloadData];
}


- (void)flipSort
{
    NSMutableDictionary *reversedDic = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.nameIndexesDictionary) {
        NSMutableArray *array = [self.nameIndexesDictionary objectForKey:key];
        NSArray *reversedArray = [[array reverseObjectEnumerator] allObjects];
        [reversedDic setObject:reversedArray forKey:key];
    }
    self.nameIndexesDictionary = reversedDic;
    
    self.beverageNameIndexArray = [[self.beverageNameIndexArray reverseObjectEnumerator] allObjects];
}

#pragma mark - Alphabetical sort specific methods

- (NSArray *)beveragesWithInitialLetter:(NSString*)aKey
{
	return [self.nameIndexesDictionary objectForKey:aKey];
}

- (void)presortElementNamesForInitialLetter:(NSString *)aKey
{
//	NSSortDescriptor *nameSD = [[NSSortDescriptor alloc] initWithKey:@"name"
//                                                           ascending:YES
//                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
//    [[self.nameIndexesDictionary objectForKey:aKey] sortUsingDescriptors:@[nameSD]];
    
    NSSortDescriptor *sd =[[NSSortDescriptor alloc] initWithKey:@"name"
                                                      ascending:YES
                                                     comparator:^(id firstDocumentName, id secondDocumentName) {
        
        static NSStringCompareOptions comparisonOptions =
        NSCaseInsensitiveSearch | NSNumericSearch;
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
    }];
    
    [[self.nameIndexesDictionary objectForKey:aKey] sortUsingDescriptors:@[sd]];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{        
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.beveragesSearchFiltered count];
    } else {
        // the section represents the initial letter of the element
        NSString *initialLetter = [self.beverageNameIndexArray objectAtIndex:section];
        
        // get the array of elements that begin with that letter
        
        NSArray *beveragesWithInitialLetter = [self beveragesWithInitialLetter:initialLetter];
        
        // return the count
        return [beveragesWithInitialLetter count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //only 1 section for search results
        return 1;
    } else {
        // this table has multiple sections. One for each unique character that a beverage begins with
        return [self.beverageNameIndexArray count];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NULL;
    } else {
        // returns the array of section titles. There is one entry for each unique character that a beverage begins with
        return self.beverageNameIndexArray;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        // returns the array of section titles. There is one entry for each unique character that a beverage begins with
        return index;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// return the letter that represents the requested section	
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NULL;
    } else {
        // returns the array of section titles. There is one entry for each unique character that a beverage begins with
        return [self.beverageNameIndexArray objectAtIndex:section];
    }
}

@end
