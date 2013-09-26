//
//  BeerSortTypeAccordionViewController.m
//  BeerPassport
//
//  Created by Jeremy Gale on 2013-05-14.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import "BeerSortTypeAccordionViewController.h"
#import "AccordionTableViewController.h"
#import "ColoredSectionHeaderView.h"
#import "Beverage.h"
#import "Category.h"

@implementation BeerSortTypeAccordionViewController

#pragma mark - BeerTableViewController required methods

- (void)reloadFromCoreData
{
    [self.accordionVC removeAllData];

    NSArray *allCategories = [Category MR_findAllSortedBy:@"name" ascending:YES];

    for (Category *cat in allCategories) {
        if (cat.beverages && cat.beverages.count > 0)
            [self addBeverages:cat.beverages.allObjects forSectionName:cat.name sortedByKey:self.secondaryKey];
//        NSSortDescriptor *sd =[[NSSortDescriptor alloc] initWithKey:@"name"
//                                                          ascending:YES
//                                                         comparator:^(id firstDocumentName, id secondDocumentName)
//        {                                 
//            static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch;
//                                                             
//            return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
//        }];
//        
    }
    
    [self.tableView reloadData];
}

- (void)reloadRowData:(NSNotification *)notification
{
    Beverage *bevToReload = [[notification userInfo] valueForKey:@"beer"];
    if (!bevToReload)
        return;
    
    NSArray *categories = [[bevToReload currentCategories] allObjects];
    
    for (Category *cat in categories) {
        
        NSUInteger sectionIndex = [self.accordionVC.sectionNameIndexArray indexOfObject:cat.name];
        if (sectionIndex == NSNotFound)
            continue;
        
        BOOL sectionOpen = [(ColoredSectionHeaderView *)self.accordionVC.sectionHeaderViews[@(sectionIndex)] open];
        if (sectionOpen) {
            NSInteger row   = [self.accordionVC.sectionIndexesDictionary[cat.name] indexOfObject:bevToReload];
            if (sectionIndex == NSNotFound)
                continue;

            NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
            
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
        }
    }

    if (self.searchDisplayController.active) {
        NSIndexPath *searchRowSelected = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        if (searchRowSelected)
            [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[searchRowSelected]
                                                                       withRowAnimation:UITableViewRowAnimationNone];
    }
}


@end
