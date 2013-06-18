//
//  FBGraphObjectPagingLoader+Priority.m
//  iOSapp
//
//  Created by Evgenij on 6/18/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FBGraphObjectPagingLoader+Priority.h"

@implementation FBGraphObjectPagingLoader (Priority)

- (void)addResultsAndUpdateView:(NSDictionary*)results
{
    NSArray *data = (NSArray *)[results objectForKey:@"data"];
    for (NSMutableDictionary *obj in data) {
        obj[@"priority"] = [NSNumber numberWithInt:0];
    }
    if (data.count == 0) {
        // If we got no data, stop following paging links.
        [self setValue:nil forKey:@"_nextLink"];
        // Tell the data source we're done.
        [self.dataSource appendGraphObjects:nil];
        [self performSelector:@selector(updateView)];

        // notify of completion
        if ([self.delegate respondsToSelector:@selector(pagingLoaderDidFinishLoading:)]) {
            [self.delegate pagingLoaderDidFinishLoading:self];
        }
        return;
    } else {
        NSDictionary *paging = (NSDictionary *)[results objectForKey:@"paging"];
        NSString *next = (NSString *)[paging objectForKey:@"next"];
        [self setValue:next forKey:@"_nextLink"];
    }

    if (!self.dataSource.hasGraphObjects) {
        // If we don't have any data already, this is easy.
        [self.dataSource appendGraphObjects:data];
        [self performSelector:@selector(updateView)];
    } else {
        // As we fetch additional results and add them to the table, we do not
        // want the table jumping around seemingly at random, frustrating the user's
        // attempts at scrolling, etc. Since results may be added anywhere in
        // the table, we choose to try to keep the first visible row in a fixed
        // position (from the user's perspective). We try to keep it positioned at
        // the same offset from the top of the screen so adding new items seems
        // smoother, as opposed to having it "snap" to a multiple of row height
        // (as would happen by simply calling [UITableView
        // scrollToRowAtIndexPath:atScrollPosition:animated:].

        // Which object is currently at the top of the table (the "anchor" object)?
        // (If possible, we choose the second row, to give context above and below and avoid
        // cases where the first row is only barely visible, thus providing little context.)
        NSArray *visibleRowIndexPaths = [self.tableView indexPathsForVisibleRows];
        if (visibleRowIndexPaths.count > 0) {
            int anchorRowIndex = (visibleRowIndexPaths.count > 1) ? 1 : 0;
            NSIndexPath *anchorIndexPath = [visibleRowIndexPaths objectAtIndex:anchorRowIndex];
            id anchorObject = [self.dataSource itemAtIndexPath:anchorIndexPath];

            // What is its rect, and what is the overall contentOffset of the table?
            CGRect anchorRowRectBefore = [self.tableView rectForRowAtIndexPath:anchorIndexPath];
            CGPoint contentOffset = self.tableView.contentOffset;

            // Update with new data and reload the table.
            [self.dataSource appendGraphObjects:data];
            [self performSelector:@selector(updateView)];

            // Where is the anchor object now?
            anchorIndexPath = [self.dataSource indexPathForItem:anchorObject];
            CGRect anchorRowRectAfter = [self.tableView rectForRowAtIndexPath:anchorIndexPath];

            // Keep the content offset the same relative to the rect of the row (so if it was
            // 1/4 scrolled off the top before, it still will be, etc.)
            contentOffset.y += anchorRowRectAfter.origin.y - anchorRowRectBefore.origin.y;
            self.tableView.contentOffset = contentOffset;
        }
    }

    if ([self.delegate respondsToSelector:@selector(pagingLoader:didLoadData:)]) {
        [self.delegate pagingLoader:self didLoadData:results];
    }

    // If we are supposed to keep paging, do so. But unless we are viewless, if we have lost
    // our tableView, take that as a sign to stop (probably because the view was unloaded).
    // If tableView is re-set, we will start again.
    if ((self.pagingMode == FBGraphObjectPagingModeImmediate &&
         self.tableView) ||
        self.pagingMode == FBGraphObjectPagingModeImmediateViewless) {
        [self performSelector:@selector(followNextLink)];
    }
}

@end
