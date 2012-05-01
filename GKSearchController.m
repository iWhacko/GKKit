//
//  GKSearchController.m
//  GKKit
//
//  Created by Gaurav Khanna on 7/14/10.
//

#if IPHONE_ONLY

#import "GKSearchController.h"

@implementation GKSearchController

@synthesize loadingView;
@synthesize activityView;
@synthesize delegateView = _delegateView;
@synthesize delegate = _delegate;
@synthesize searchDisplayController = _searchDisplayController;

#pragma mark - Instance Setup Methods

- (id)initWithSearchDisplayController:(UISearchDisplayController *)controller {
    self = [super init];
    if (self) {
        self.loadingView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UIActivityIndicatorView *indic = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indic.hidesWhenStopped = YES;
        [indic stopAnimating];
        self.activityView = indic;
        
        [self.loadingView addSubview:self.activityView];

        id controllerDelegate = (id<GKSearchControllerDelegate>)controller.delegate;
        if (controllerDelegate) {
            _delegate = controllerDelegate;
            // we have to fail if the auto chosen delegate isn't a viewController
            UIView *controllerDelegateView = [controllerDelegate view];
            if (controllerDelegateView)
                _delegateView = controllerDelegateView;
            else
                return nil;
        }
        //controller.searchResultsDataSource = (id<UITableViewDataSource>)controller.searchContentsController;  
        //controller.searchResultsDelegate = (id<UITableViewDelegate>)controller.searchContentsController;
        controller.delegate = self;
        controller.searchBar.delegate = self;
        _searchDisplayController = controller;
    }
    return self;
}

- (void)setSearchLoadingState:(GKSearchDisplayState)state {
    switch(state) {
        case GKSearchDisplayStateSearch:
            [self.activityView stopAnimating];
            self.loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            break;
        case GKSearchDisplayStateLoading: {
            self.loadingView.backgroundColor = self.searchDisplayController.searchResultsTableView.backgroundColor;
            self.activityView.center = self.loadingView.center;
            UIViewFrameChangeValue(self.activityView, origin.y, 11.0);
            [self.activityView startAnimating];
            break;
        }
    }
}

#pragma mark - Instance Feedback Methods

- (void)readyToDisplayResults {
    self.searchDisplayController.searchResultsTableView.hidden = FALSE;
    [self.loadingView removeFromSuperview];
}

- (void)search:(NSString *)searchText fromTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    if(tableView && indexPath)
        [tableView deselectRowAtIndexPath:indexPath animated:animated];
    [self.searchDisplayController setActive:YES animated:animated];
    self.searchDisplayController.searchBar.text = searchText;
    [self searchBarSearchButtonClicked:self.searchDisplayController.searchBar];
}

#pragma mark - UISearchDisplayController Delegate Methods

#pragma mark Begin / End Search
#ifdef DEBUG
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    DLogFunc();
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    DLogFunc();
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    DLogFunc();
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    DLogFunc();
}

#pragma mark Load / Unload Table View

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    DLogFunc();
    DLogCGRect(tableView.frame);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    DLogFunc();
}
#endif

#pragma mark Hide Table view

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    tableView.hidden = YES;
    [self setSearchLoadingState:GKSearchDisplayStateSearch];
    [self.delegateView addSubview:self.loadingView];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    [self.loadingView setFrame:tableView.frame];
}

#ifdef DEBUG
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    DLogFunc();
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    DLogFunc();
}
#endif

// returns NO to not cause reload of table with no results
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return NO;
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self setSearchLoadingState:GKSearchDisplayStateLoading];
    [self.delegate searchController:self shouldStartSearch:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if(self.loadingView.superview) {
        [self.loadingView removeFromSuperview];
        [NSObject scheduleRunAfterDelay:1.0 forBlock:^{
            self.searchDisplayController.searchResultsTableView.hidden = NO;
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0)
        self.loadingView.hidden = YES;
    else
        self.loadingView.hidden = NO;
}

@end

#endif