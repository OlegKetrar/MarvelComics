//
//  FSBaseCollectionViewController.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import UIKit;

@class NSManagedObjectContext, NSFetchRequest, NSFetchedResultsController;

NS_ASSUME_NONNULL_BEGIN

@interface FSBaseViewController : UICollectionViewController

//
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

// setup requests to your specific data model
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

// needs for automatic loading of content while scroll down
// setup in viewDidLoad method
@property (nonatomic) NSUInteger spareDataCount;

// count of entity in managedObjectContext for fetchRequest
- (NSUInteger)dataCount;

// should be overridden
// send data request to your DataController
- (void)shouldRequestMoreData;

@end

NS_ASSUME_NONNULL_END