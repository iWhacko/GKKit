//
//  GKSearchController.h
//  GKKit
//
//  Created by Gaurav Khanna on 7/14/10.
//
//  Usage: 
//      GKSearchController *aSearchController = [[GKSearchController alloc] initWithSearchDisplayController:mySearchDisplayController];
//      self.searchController = aSearchController;
//  
//  
//  Notes: 
//     (by default)
//      - instance delegate is assigned as the delegate of the UISearchDisplayController received.
//      - Controlled view is set to delegates view (if exists)
//      - UISearchDisplayController delegate is set to instance
//  

#if IPHONE_ONLY

#import <UIKit/UIKit.h>
#import "common.h"
#import "NSObject+GKAdditions.h"

@class GKSearchController;

typedef enum {
    GKSearchDisplayStateSearch,
    GKSearchDisplayStateLoading,
} GKSearchDisplayState;

@protocol GKSearchControllerDelegate
@required
- (void)searchController:(GKSearchController *)controller shouldStartSearch:(NSString *)searchText;
@end

@interface GKSearchController : NSObject <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak, readonly) UIView *delegateView;
@property (nonatomic, weak, readonly) id<GKSearchControllerDelegate> delegate;
@property (nonatomic, weak, readonly) UISearchDisplayController *searchDisplayController;

- (id)initWithSearchDisplayController:(UISearchDisplayController *)controller;
- (void)readyToDisplayResults;
- (void)search:(NSString *)searchText fromTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end

#endif