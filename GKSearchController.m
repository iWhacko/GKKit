//
//  GKSearchController.m
//  GKKit
//
//  Created by Gaurav Khanna on 7/14/10.
//

#if IPHONE_ONLY

#import "GKSearchController.h"

@implementation GKSearchController

@synthesize delegate;
@synthesize view;
@synthesize searchDisplayController;

#pragma mark - Instance Setup Methods

- (id)initWithSearchDisplayController:(UISearchDisplayController *)controller {
    self = [super init];
    if (self) {
        UIView *aBlankView = [[UIView alloc] initWithFrame:CGRectZero];
        UIActivityIndicatorView *aActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        _searchLoadingView = aBlankView;
        _activityView = aActivityIndicator;
        _activityView.hidesWhenStopped = YES;
        [_activityView stopAnimating];
        [_searchLoadingView addSubview:_activityView];

        id controllerDelegate = (id<GKSearchControllerDelegate>)controller.delegate;
        if (controllerDelegate) {
            self.delegate = controllerDelegate;
            // we have to fail if the auto chosen delegate isn't a viewController
            UIView *controllerDelegateView = [controllerDelegate view];
            if (controllerDelegateView)
                self.view = controllerDelegateView;
            else
                return nil;
        }
        
        controller.delegate = self;
        controller.searchBar.delegate = self;
        self.searchDisplayController = controller;
    }
    return self;
}

- (void)setSearchLoadingState:(GKSearchDisplayState)state {
    switch(state) {
        case GKSearchDisplayStateSearch:
            [_activityView stopAnimating];
            _searchLoadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            break;
        case GKSearchDisplayStateLoading:
            _searchLoadingView.backgroundColor = [UIColor whiteColor];
            _activityView.center = _searchLoadingView.center;
            UIViewFrameChangeValue(_activityView, origin.y, 11.0);
            [_activityView startAnimating];
            break;
    }
}

#pragma mark - Instance Feedback Methods

- (void)readyToDisplayResults {
    self.searchDisplayController.searchResultsTableView.hidden = FALSE;
    [_searchLoadingView removeFromSuperview];
}

- (void)search:(NSString *)searchText fromTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    if(tableView && indexPath)
        [tableView deselectRowAtIndexPath:indexPath animated:animated];
    [self.searchDisplayController setActive:YES animated:animated];
    self.searchDisplayController.searchBar.text = searchText;
    [self searchBarSearchButtonClicked:self.searchDisplayController.searchBar];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    tableView.hidden = YES;
    [_searchLoadingView setFrame:( CGRectEqualToRect(tableView.frame, CGRectZero ) ? _searchLoadingView.frame : tableView.frame)];
    [self setSearchLoadingState:GKSearchDisplayStateSearch];
    [self.view addSubview:_searchLoadingView];
}

#ifdef DEBUG
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

#pragma mark Begin / End Search

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
}

#pragma mark Load / Unload Table View

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    
}

#pragma mark Hide Table view

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
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
    if(_searchLoadingView.superview) {
        [_searchLoadingView removeFromSuperview];
        [NSObject scheduleRunAfterDelay:1.0 forBlock:^{
            self.searchDisplayController.searchResultsTableView.hidden = NO;
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0)
        _searchLoadingView.hidden = YES;
    else
        _searchLoadingView.hidden = NO;
}

#pragma mark - Memory Management

#if !OBJC_ARC
- (void)dealloc {
    [_searchLoadingView removeFromSuperview];
    [_activityView removeFromSuperview];
    [_searchLoadingView release];
    [_activityView release];
    [super dealloc];
}
#endif

@end

#endif
