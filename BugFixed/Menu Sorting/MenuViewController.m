//
//  MenuViewController.m
//  BeerPassport
//
//  Created by Rahul Bir on 2013-03-21.
//  Copyright (c) 2013 AppColony. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "MenuViewController.h"
#import "User.h"
#import "MenuCategory.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "ColoredSectionHeaderView.h"
#import "WelcomeViewController.h"
#import "BeerPassportAPI.h"

// NOTE: These must match the size of the Item Description label in the storyboard
const CGFloat kOrigDescLabelWidth = 280;
const CGFloat kOrigDescLabelHeight = 52;
const CGFloat kDescFontSize = 13.0;

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *menuCategory;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) BeerPullToRefreshView *refreshView;

@property (nonatomic) BOOL shouldReloadMenuOnNextAppearance;


@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOnNextAppearance)
                                                 name:kUserBarLocationChangedNotification
                                               object:nil];
    self.shouldReloadMenuOnNextAppearance = NO;

    
    // When you expand any header, have all the others close automatically
    self.onlyOneSectionOpenAllowed = YES;
    
    [self setSectionHeaderNibName:[ColoredSectionHeaderView nibName]];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];

    UINib *nib = [UINib nibWithNibName:@"MenuItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MenuItemCell"];
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setMinimumFractionDigits:2];
    [self.numberFormatter setMaximumFractionDigits:2];
    
    self.refreshView = [[BeerPullToRefreshView alloc] initWithScrollView:self.tableView];
    [self.refreshView setDelegate:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadOnNextAppearance
{
    if (self.isViewLoaded && self.view.window) {
        [self loadMenuFromServer];
    } else {
        self.shouldReloadMenuOnNextAppearance = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if the bar we're currently displaying is not the one the user selected
    if (self.shouldReloadMenuOnNextAppearance || !self.menuCategory) {
        self.shouldReloadMenuOnNextAppearance = NO;
        [self loadMenuFromServer];
    }
}

- (void)loadMenuFromServer
{
    //Show the loading spinner
    //only display the loading message if we aren't already displaying a welcome screen
    if (![WelcomeViewController instanceBeingDisplayed]) {
        [SVProgressHUD showWithStatus:@"Loading Menu..."];
    }
    
    BeerPassportAPI *bpAPI = [BeerPassportAPI sharedInstance];
    
    [bpAPI retrieveMenuOnCompletion:^(NSArray *menuCategory) {
        
        [SVProgressHUD dismiss];
        self.menuCategory = menuCategory;
        [self prepareAccordionTableView];
        
    } onFailure:^(NSInteger statusCode, NSError *error) {
        [SVProgressHUD dismiss];
        
        [BeerPassportAPI genericErrorHandler:statusCode
                                       error:error
                              failureMessage:@"Menu could not be loaded, please try again later."];
        
    }];
}

- (void)prepareAccordionTableView
{
    [self removeAllData];
    
    NSSortDescriptor *categorySD = [[NSSortDescriptor alloc] initWithKey:@"menuCategoryID"
                                                          ascending:YES] ;
	
	NSArray *sorted = [self.menuCategory sortedArrayUsingDescriptors:@[categorySD]];
    
    for (MenuCategory *menuCategory in sorted) {
        if (menuCategory.menuItems.count > 0) {
            [self.sectionNameIndexArray addObject:menuCategory.name];
            [self.sectionIndexesDictionary setObject:menuCategory.menuItems forKey:menuCategory.name];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (MenuItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.sectionNameIndexArray objectAtIndex:indexPath.section];
    return [[self.sectionIndexesDictionary objectForKey:key] objectAtIndex:indexPath.row];
}

// Calculate the size of the MenuCell description label
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath)
        return 0.0f;
    
    MenuItem *item = [self itemForIndexPath:indexPath];

    // find the size of the description field
    CGSize size = [item.itemDescription sizeWithFont:[UIFont systemFontOfSize:kDescFontSize] constrainedToSize:CGSizeMake(kOrigDescLabelWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    // Cell size is 102. Default description field size is 52. So remaining height of cell = 102-52 = 50.
    return self.tableView.rowHeight - kOrigDescLabelHeight + size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItemCell *cell = (MenuItemCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
    
    MenuItem *item = [self itemForIndexPath:indexPath];
    
    cell.title.text = item.name;
    cell.description.text = item.itemDescription;
    
    if (item.price) {
        cell.price.text = [NSString stringWithFormat:@"$%@", [self.numberFormatter stringFromNumber:item.price]];
    } else {
        cell.price.text = @"";
    }

	return cell;
}

#pragma mark - BeerPullToRefreshViewDelegate Methods

- (void)beerPullToRefreshViewShouldRefresh:(BeerPullToRefreshView *)beerPullToRefreshView
{
    BeerPassportAPI *bpAPI = [BeerPassportAPI sharedInstance];
    
    [bpAPI retrieveMenuOnCompletion:^(NSArray *menuCategory) {
        
        [self removeAllData];
        self.menuCategory = menuCategory;
        [self prepareAccordionTableView];
        [self.refreshView finishRefreshing];

    } onFailure:^(NSInteger statusCode, NSError *error) {
        [self.refreshView finishRefreshing];
        
        [BeerPassportAPI genericErrorHandler:statusCode
                                       error:error
                              failureMessage:@"Menu could not be loaded, please try again later."];
        
    }];
    
}

@end