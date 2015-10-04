//
//  FSBaseCollectionViewController.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

/* In subclass you must:
 - link collectionView property in IB to your collection view and configure it yourself
 - set managedObjectContext property
 - set and configure fetchRequest property
 - override method shouldRequestMoreData() to insert your specified data into CoreData context
 - override collectionView:cellForItemAtIndexPath: method to setup your cell
 */

@import UIKit;

@class NSManagedObjectContext, NSFetchRequest, NSFetchedResultsController;

NS_ASSUME_NONNULL_BEGIN

@interface FSBaseViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

// count of entity in managedObjectContext for fetchRequest
- (NSUInteger)dataCount;

@end

NS_ASSUME_NONNULL_END