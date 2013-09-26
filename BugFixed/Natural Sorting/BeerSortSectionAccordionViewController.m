//
//  BeerSortSectionAccordionViewController.m
//  BeerPassport
//
//  Created by Jeremy Gale on 2013-01-28.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import "BeerSortSectionAccordionViewController.h"
#import "AccordionTableViewController.h"
#import "BeverageCell.h"
#import "Beverage.h"
#import "User.h"
#import "BeerDetailViewController.h"
#import "SubmitTabViewController.h"
#import "ColoredSectionHeaderView.h"


@interface BeerSortSectionAccordionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *expandCollapseButton;

@end

@implementation BeerSortSectionAccordionViewController

- (void)viewDidLoad
{
    self.accordionVC = [[AccordionTableViewController alloc] init];
    [self.accordionVC setSectionHeaderNibName:[ColoredSectionHeaderView nibName]];
    
    // Let accordionVC know who our searchResultsTableView is. Otherwise it has no way to access it
    
    // Since we are using our own tableView for the Accordion, it's outlet will be nil. Manually set it.
    // Same for searchDisplayController
    self.accordionVC.tableView = self.tableView;
    self.accordionVC.searchController = self.searchDisplayController;
    self.accordionVC.expandCollapseButton = self.expandCollapseButton;
    
    // AccordionTableViewController sets this on it's own tableView but we need to set it on ours
    self.tableView.sectionHeaderHeight = kDefaultSectionHeaderHeight;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    
    // This is dumb, but it hides the invisible cells if you have less than 4 items on your tab
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    // This does a lot of important base class stuff
    [super viewDidLoad];
}

#pragma mark - Initialize the AccordionTableViewController data

// Takes a section nanme and and array of beverages, and adds them to self.accordionVC
// after sorting the beverages by self.secondaryKey
- (void)addBeverages:(NSArray *)beverages forSectionName:(NSString *)sectionName sortedByKey:(NSString *)sortKey
{
    NSSortDescriptor *secondaryDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                                        ascending:YES
                                                                       comparator:^(id firstDocumentName, id secondDocumentName)
    {
                                                                           
        static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch;
                                                                           
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
    }];
    beverages = [beverages sortedArrayUsingDescriptors:@[secondaryDescriptor]];
    [self.accordionVC.sectionIndexesDictionary setObject:beverages forKey:sectionName];
    [self.accordionVC.sectionNameIndexArray addObject:sectionName];
}

- (void)beverageSectionInfosForPrimaryKey:(NSString *)primaryKey secondaryKey:(NSString *)secondaryKey
{
    [self.accordionVC removeAllData];
    
    NSArray *beveragesByKey = [Beverage MR_findAllSortedBy:primaryKey ascending:YES];
    
    // e.g. all beers of Type "IPA"
    NSMutableArray *beersOfOneValue;
    
    // e.g. we were on IPA, but now we are on Lager
    NSString *previousValue = nil;
    NSString *currentValue = nil;
    
    for (Beverage *bev in beveragesByKey) {
        currentValue = [bev valueForKey:primaryKey];
        if (previousValue == nil || [currentValue isEqualToString:previousValue] == NO) {
            // Found a new value (e.g. new country or category)
            
            if (beersOfOneValue) {
                [self addBeverages:beersOfOneValue forSectionName:previousValue sortedByKey:secondaryKey];
            }
            
            beersOfOneValue = [NSMutableArray arrayWithCapacity:10];
            previousValue = currentValue;
        }
        
        [beersOfOneValue addObject:bev];
    }
    
    // Add all the beverages for the last value
    if (beersOfOneValue) {
        [self addBeverages:beersOfOneValue forSectionName:currentValue sortedByKey:secondaryKey];
    }
}

#pragma mark - BeerTableViewController required methods

- (void)reloadRowData:(NSNotification *)notification
{
    Beverage *bevToReload = [[notification userInfo] valueForKey:@"beer"];
    if (!bevToReload)
        return;
    
    NSString *sectionName = [bevToReload valueForKey:self.primaryKey];
    NSNumber *sectionIndex = [NSNumber numberWithInt:[self.accordionVC.sectionNameIndexArray indexOfObject:sectionName]];

    BOOL sectionOpen = [(ColoredSectionHeaderView *)self.accordionVC.sectionHeaderViews[sectionIndex] open];
    if (sectionOpen) {
        NSInteger section = [self.accordionVC.sectionNameIndexArray indexOfObject:sectionName];
        NSInteger row     = [self.accordionVC.sectionIndexesDictionary[sectionName] indexOfObject:bevToReload];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:section];
        
        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    }

    if (self.searchDisplayController.active) {
        NSIndexPath *searchRowSelected = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        if (searchRowSelected)
            [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[searchRowSelected]
                                                                       withRowAnimation:UITableViewRowAnimationNone];
    }
}

// trigger when backend beverages have changed for resorting
- (void)reloadFromCoreData
{
    self.expandCollapseButton.selected = NO;
    [self beverageSectionInfosForPrimaryKey:self.primaryKey secondaryKey:self.secondaryKey];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource Methods

// In most cases, just delegate to self.accordionVC

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BeverageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BeverageCell"];
    Beverage *bev;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        //the last section contains a dummy cell with nothing in it for the dummy section
        if(indexPath.section == ([self.accordionVC.filteredSectionNameIndexArray count]-1)) {
            cell.hidden = YES;
            return cell;
        }
        
        NSString *key = [self.accordionVC.filteredSectionNameIndexArray objectAtIndex:indexPath.section];
        bev = (Beverage *)[[self.accordionVC.filteredSectionIndexesDictionary objectForKey:key] objectAtIndex:indexPath.row];
        
    } else {        
        NSString *key = [self.accordionVC.sectionNameIndexArray objectAtIndex:indexPath.section];
        bev = (Beverage *)[[self.accordionVC.sectionIndexesDictionary objectForKey:key] objectAtIndex:indexPath.row];
    }
    
    [cell setupCellwithBeverage:bev];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [self.accordionVC numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accordionVC tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self.accordionVC tableView:tableView heightForHeaderInSection:section];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.accordionVC tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self.accordionVC tableView:tableView heightForFooterInSection:section];
}

#pragma mark - UISearch methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.accordionVC.filteredSectionHeaderViews = [[NSMutableDictionary alloc] init];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchString];
    
    self.accordionVC.filteredSectionNameIndexArray = [NSMutableArray arrayWithArray:[self.accordionVC.sectionNameIndexArray filteredArrayUsingPredicate:pred]];
    self.accordionVC.filteredSectionIndexesDictionary = [NSMutableDictionary dictionaryWithDictionary:self.accordionVC.sectionIndexesDictionary];
    
    for (NSString *name in self.accordionVC.sectionNameIndexArray) {
        if (![self.accordionVC.filteredSectionNameIndexArray containsObject:name]) {
            [self.accordionVC.filteredSectionIndexesDictionary removeObjectForKey:name];
        }
    }
    
    return [self.accordionVC searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.accordionVC searchDisplayController:controller didLoadSearchResultsTableView:tableView];
}

#pragma mark - Actions

- (IBAction)expandCollapse:(id)sender
{
    [self.accordionVC toggleExpandCollapseTable:self.tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showBeerDetailFromAccordion"]) {
        BeerDetailViewController *detailViewController = [segue destinationViewController];
        
        NSIndexPath *indexPath;
        Beverage *bev;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
            NSString *key = [self.accordionVC.filteredSectionNameIndexArray objectAtIndex:indexPath.section];
            bev = (Beverage *)[[self.accordionVC.filteredSectionIndexesDictionary objectForKey:key] objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];

            NSString *key = [self.accordionVC.sectionNameIndexArray objectAtIndex:indexPath.section];
            bev = (Beverage *)[[self.accordionVC.sectionIndexesDictionary objectForKey:key] objectAtIndex:indexPath.row];
        }
        
        //Give Detail view controller a pointer to the item object in a row
        [detailViewController setBeer:bev];
    }
}

@end
