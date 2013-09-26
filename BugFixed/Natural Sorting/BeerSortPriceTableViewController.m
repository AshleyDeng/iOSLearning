//
//  BeerSortPriceTableViewController.m
//  BeerPassport
//
//  Created by Matt Pearcy on 2013-01-30.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import "BeerSortPriceTableViewController.h"
#import "Beverage.h"
#import "BeverageCell.h"
#import "User.h"
#import "BeerDetailViewController.h"
#import "SubmitTabViewController.h"

@interface BeerSortPriceTableViewController ()

@property (assign, nonatomic) BOOL ascend; //controls ascending/descending sort

@end

@implementation BeerSortPriceTableViewController


- (void)viewDidLoad
{
    // Must be before call to super because it resorts us
    self.ascend = YES;
    
    // Lots of important stuff happens in here:
    [super viewDidLoad];
}

#pragma mark - BeerTableViewController methods

- (void)reloadRowData:(NSNotification *)notification
{
    Beverage *bevToReload = [[notification userInfo] valueForKey:@"beer"];
    if (!bevToReload)
        return;
    
    //Find the indexPath the beverage is located at
    NSInteger row = [self.beverages indexOfObject:bevToReload];
    if (row == NSNotFound) {
        // Don't worry about it.. we are probably due to -reloadFromCoreData on next appearance.
        // Attempting to reload this would cause a crash
        return;
    }
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
    
    //reload beer at indexPath on main table
    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    
    UITableView *searchTableView = self.searchDisplayController.searchResultsTableView;
    NSIndexPath *searchRowSelected = [searchTableView indexPathForSelectedRow];
    
    //if we can find a row selected in the search results table then we probably launched from there.  Reload that row too
    if (searchRowSelected) {
        [searchTableView reloadRowsAtIndexPaths:@[searchRowSelected] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)reloadFromCoreData
{    
    self.beverages = [Beverage MR_findAll];
    [self sortBeers];
    
    [self.tableView reloadData];
}

- (Beverage *)beverageForIndexPath:(NSIndexPath *)indexPath
{
	return [self.beverages objectAtIndex:indexPath.row];
}

#pragma mark - Price sort specific methods

- (IBAction)changeSort:(id)sender
{
    self.ascend = !self.ascend;
    [self sortBeers];
    [self.tableView reloadData];
}

- (void)sortBeers
{
    NSMutableArray *sortArray = [self.beverages mutableCopy];
    NSSortDescriptor *priceSD = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:self.ascend];
//    NSSortDescriptor *nameSD = [[NSSortDescriptor alloc] initWithKey:@"name"
//                                                           ascending:YES
//                                                            selector:@selector(localizedCaseInsensitiveCompare:)] ;
    NSSortDescriptor *nameSD =[[NSSortDescriptor alloc] initWithKey:@"name"
                                                      ascending:YES
                                                     comparator:^(id firstDocumentName, id secondDocumentName)
    {                                    
        static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch;
                                                         
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    
    [sortArray sortUsingDescriptors:@[priceSD, nameSD]];
    self.beverages = sortArray;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.beveragesSearchFiltered count];
    } else {
        return [self.beverages count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

@end
