//
//  BeerTableViewController.m
//  BeerPassport
//
//  Created by Jeremy Gale on 2013-02-21.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import <Flurry.h>
#import "BeerTableViewController.h"
#import "Beverage.h"
#import "BeverageCell.h"
#import "User.h"
#import "BeerDetailViewController.h"
#import "SubmitTabViewController.h"
#import "BeerPassportAPI.h"


@interface BeerTableViewController ()

@property (assign, nonatomic) BOOL visible;
@property (assign, nonatomic) BOOL reloadOnNextAppearance;

@end

NSString *const kSingleBeerChangedNotification = @"SingleBeerChangedNotification";

@implementation BeerTableViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRowData:)
                                                 name:kSingleBeerChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRowData:)
                                                 name:kTabChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadViewData)
                                                 name:kUserLoadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMyTabButtonEnabledState)
                                                 name:kUserLoadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadViewData)
                                                 name:kBeveragesLoadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMyTabButtonEnabledState)
                                                 name:kTabChangedNotification
                                               object:nil];
    
    [self reloadFromCoreData];
    
    [self updateMyTabButtonEnabledState];
    
    self.refreshView = [[BeerPullToRefreshView alloc] initWithScrollView:self.tableView];
    [self.refreshView setDelegate:self];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITableView *activeTable = self.tableView;
    if (self.searchDisplayController.active)
        activeTable = self.searchDisplayController.searchResultsTableView;
    
    [self.tableView deselectRowAtIndexPath:[activeTable indexPathForSelectedRow] animated:NO];
}

#pragma mark - BeerSortTableContainerDelegate methods

- (void)childIsNowActive:(BOOL)active
{
    self.visible = active;
    
    if (self.reloadOnNextAppearance && self.visible) {
        [self reloadFromCoreData];
        self.reloadOnNextAppearance = NO;
    }
}

#pragma mark - Delayed Loading and Reloading Methods

- (void)reloadViewData
{    
    //if we're visible reload the table data immediately, otherwise delay till next time we become visible
    if (self.visible) {
        [self reloadFromCoreData];
    } else {
        self.reloadOnNextAppearance = YES;
    }
}

- (void)reloadFromCoreData
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)reloadRowData:(NSNotification *)notification
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (Beverage *)beverageForIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (void)updateMyTabButtonEnabledState
{
    self.myTabButton.enabled = ([[User sharedInstance].tab count] > 0);
}

#pragma mark - Actions

- (IBAction)presentMyTab:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SubmitTabStoryboard" bundle:nil];
    
    SubmitTabViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"submitTab"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stvc];
    [self presentViewController:navController animated:YES completion:nil];
    [Flurry logEvent:@"TabButtonPressed" withParameters:@{@"from": @"BeerTableViewController"}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] rangeOfString:@"showBeerDetailFrom"].location == 0) {
        BeerDetailViewController *detailViewController = [segue destinationViewController];
        
        Beverage *bev;
        NSIndexPath *indexPath;
        
         if (self.searchDisplayController.active) {
             indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
             bev = [self.beveragesSearchFiltered objectAtIndex:indexPath.row];
         } else {
             indexPath = [self.tableView indexPathForSelectedRow];
             bev = [self beverageForIndexPath:indexPath];
         }
        
        [detailViewController setBeer:bev];
    }
}


#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BeverageCell *cell = (BeverageCell *)[self.tableView dequeueReusableCellWithIdentifier:@"BeverageCell"];
    
    Beverage *bev;    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        bev = [self.beveragesSearchFiltered objectAtIndex:indexPath.row];
    } else {
        bev = [self beverageForIndexPath:indexPath];
    }
	    
    [cell setupCellwithBeverage:bev];
    
	return cell;
}

#pragma mark - UISearchDisplayDelegate methods

 - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
 {     
     NSPredicate *pred = [NSPredicate predicateWithFormat:@"(SELF.name contains[c] %@) OR (SELF.manufacturer contains[c] %@) OR (SELF.country contains[c] %@)",searchString,searchString,searchString];
 
     self.beveragesSearchFiltered = [NSMutableArray arrayWithArray:[self.beverages filteredArrayUsingPredicate:pred]];
     
     NSSortDescriptor *nameSD =[[NSSortDescriptor alloc] initWithKey:@"name"
                                                           ascending:YES
                                                          comparator:^(id firstDocumentName, id secondDocumentName)
    {
        static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch;
                                    
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
                                    
     }];
     self.beveragesSearchFiltered = [self.beveragesSearchFiltered sortedArrayUsingDescriptors:@[nameSD]];
//
     return YES;
 }

//unfortunately we need to set row height on the search results table programmatically
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = self.tableView.rowHeight;
}
 
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //When search first starts it hides the navigation bar, but we unhide it detail view.  This rehides it
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //make sure navigation bar isn't hidden when we're done with search
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - BeerPullToRefreshViewDelegate Methods

- (void)beerPullToRefreshViewShouldRefresh:(BeerPullToRefreshView *)beerPullToRefreshView
{
    if ([User sharedInstance].locationID != nil) {
        [[BeerPassportAPI sharedInstance]
         retrieveBeersForLocation:[[User sharedInstance].locationID integerValue]
         onCompletion:^{
             
             [self.refreshView finishRefreshing];
             
         } onFailure:^void(NSInteger statusCode, NSError *error) {
             
             [self.refreshView finishRefreshing];
                 
             [BeerPassportAPI genericErrorHandler:statusCode
                                            error:error
                                   failureMessage:@"Beers could not be loaded, please try again later"];
             
         }];
    }
    
}
@end
