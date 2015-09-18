//
//  FSBaseCollectionViewController.m
//  Test_Marvel_API
//
//  Created by Oleg ; on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import CoreData;

#import "FSBaseViewController.h"

//TODO: create default setup for managedObjectContext

@interface FSBaseViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSMutableDictionary *contentChanges;

@end

@implementation FSBaseViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self shouldRequestMoreData];
}

- (NSUInteger)dataCount {
	return [self.fetchedResultsController.managedObjectContext countForFetchRequest:self.fetchRequest
																			  error:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil)
		return _fetchedResultsController;
	
	NSManagedObjectContext *context = self.managedObjectContext;
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
																		  managedObjectContext:context
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	frc.delegate = self;
	_fetchedResultsController = frc;
	
	NSError *error;
	if (![_fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _fetchedResultsController;
}

#pragma mark - should be overridden

- (void)shouldRequestMoreData {
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	self.contentChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(nullable NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(nullable NSIndexPath *)newIndexPath {
	
	if (type == NSFetchedResultsChangeInsert) {
		NSArray *array = [self.contentChanges objectForKey:@(type)];
		if ( array )
			[self.contentChanges setObject:[array arrayByAddingObject:newIndexPath]
									forKey:@(type)];
		else
			[self.contentChanges setObject:@[newIndexPath] forKey:@(type)];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	
	[self.collectionView performBatchUpdates:^{
		
		for ( NSNumber *changeType in self.contentChanges.keyEnumerator.allObjects ) {
			
			switch ([changeType unsignedIntegerValue]) {
				case NSFetchedResultsChangeInsert:
					[self.collectionView insertItemsAtIndexPaths:[self.contentChanges objectForKey:changeType]];
					break;
					
				default:
					break;
			}
		}
		
	} completion:^(BOOL finished) {}];
	
	self.contentChanges = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections objectAtIndex:section].numberOfObjects;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == self.dataCount - self.spareDataCount ) {
		[self shouldRequestMoreData];
	}
}

@end
