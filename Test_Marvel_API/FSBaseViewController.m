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
@property (nonatomic) NSMutableDictionary *sectionChanges;

@end

@implementation FSBaseViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.loadMoreEnabled = NO;
	
	[self shouldRequestMoreData];
}

- (NSUInteger)dataCount {
	return [self.managedObjectContext countForFetchRequest:self.fetchRequest error:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController)
		return _fetchedResultsController;
	
//	NSLog(@"%@ fetchedResultsController", NSStringFromClass([self class]));
	
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

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//	self.contentChanges = [NSMutableDictionary dictionary];
//	
//	NSLog(@"%@ controllerWillChangeContent", NSStringFromClass([self class]));
//}
//
//- (void)controller:(NSFetchedResultsController *)controller
//  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//		   atIndex:(NSUInteger)sectionIndex
//	 forChangeType:(NSFetchedResultsChangeType)type {
//	
//	NSLog(@"%@ didChangeSection", NSStringFromClass([self class]));
//}
//
//- (void)controller:(NSFetchedResultsController *)controller
//   didChangeObject:(id)anObject
//	   atIndexPath:(nullable NSIndexPath *)indexPath
//	 forChangeType:(NSFetchedResultsChangeType)type
//	  newIndexPath:(nullable NSIndexPath *)newIndexPath {
//	
//	NSLog(@"%@ didChangeObject atIndex:(%ld, %ld) forChangeType:%ld newIndex:(%ld, %ld)", NSStringFromClass([self class]),
//		  indexPath.section, indexPath.row, type, newIndexPath.section, newIndexPath.row);
//	
//	if (type == NSFetchedResultsChangeInsert) {
//		NSArray *array = [self.contentChanges objectForKey:@(type)];
//		if ( array )
//			[self.contentChanges setObject:[array arrayByAddingObject:newIndexPath]
//									forKey:@(type)];
//		else
//			[self.contentChanges setObject:@[newIndexPath] forKey:@(type)];
//	}
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	
//	NSLog(@"%@ controllerDidChangeContent", NSStringFromClass([self class]));
//	
//	[self.collectionView performBatchUpdates:^{
//		
//		for ( NSNumber *changeType in self.contentChanges.keyEnumerator.allObjects ) {
//			
//			switch ([changeType unsignedIntegerValue]) {
//				case NSFetchedResultsChangeInsert:
//					[self.collectionView insertItemsAtIndexPaths:[self.contentChanges objectForKey:changeType]];
//					break;
//					
//				default:
//					break;
//			}
//		}
//		
//	} completion:^(BOOL finished) {}];
//	
//	self.contentChanges = nil;
//}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	self.contentChanges = [NSMutableDictionary dictionary];
	self.sectionChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
		NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
		if (changeSet != nil) {
			[changeSet addIndex:sectionIndex];
		} else {
			self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
		}
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	NSMutableArray *changeSet = self.contentChanges[@(type)];
	if (changeSet == nil) {
		changeSet = [[NSMutableArray alloc] init];
		self.contentChanges[@(type)] = changeSet;
	}
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[changeSet addObject:newIndexPath];
			break;
		case NSFetchedResultsChangeDelete:
			[changeSet addObject:indexPath];
			break;
		case NSFetchedResultsChangeUpdate:
			[changeSet addObject:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[changeSet addObject:@[indexPath, newIndexPath]];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	NSMutableArray *moves = self.contentChanges[@(NSFetchedResultsChangeMove)];
	if (moves.count > 0) {
		NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];
		
		NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
		NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
		for (NSArray *move in moves) {
			NSIndexPath *fromIP = move[0];
			NSIndexPath *toIP = move[1];
			
			if ([deleteSections containsIndex:fromIP.section]) {
				if (![insertSections containsIndex:toIP.section]) {
					NSMutableArray *changeSet = self.contentChanges[@(NSFetchedResultsChangeInsert)];
					if (changeSet == nil) {
						changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
						self.contentChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
					} else {
						[changeSet addObject:toIP];
					}
				}
			} else if ([insertSections containsIndex:toIP.section]) {
				NSMutableArray *changeSet = self.contentChanges[@(NSFetchedResultsChangeDelete)];
				if (changeSet == nil) {
					changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
					self.contentChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
				} else {
					[changeSet addObject:fromIP];
				}
			} else {
				[updatedMoves addObject:move];
			}
		}
		
		if (updatedMoves.count > 0) {
			self.contentChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
		} else {
			[self.contentChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
		}
	}
	
	NSMutableArray *deletes = self.contentChanges[@(NSFetchedResultsChangeDelete)];
	if (deletes.count > 0) {
		NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
		[deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
			return ![deletedSections containsIndex:evaluatedObject.section];
		}]];
	}
	
	NSMutableArray *inserts = self.contentChanges[@(NSFetchedResultsChangeInsert)];
	if (inserts.count > 0) {
		NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
		[inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
			return ![insertedSections containsIndex:evaluatedObject.section];
		}]];
	}
	
	UICollectionView *collectionView = self.collectionView;
	
	[collectionView performBatchUpdates:^{
		NSIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
		if (deletedSections.count > 0) {
			[collectionView deleteSections:deletedSections];
		}
		
		NSIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
		if (insertedSections.count > 0) {
			[collectionView insertSections:insertedSections];
		}
		
		NSArray *deletedItems = self.contentChanges[@(NSFetchedResultsChangeDelete)];
		if (deletedItems.count > 0) {
			[collectionView deleteItemsAtIndexPaths:deletedItems];
		}
		
		NSArray *insertedItems = self.contentChanges[@(NSFetchedResultsChangeInsert)];
		if (insertedItems.count > 0) {
			[collectionView insertItemsAtIndexPaths:insertedItems];
		}
		
		NSArray *reloadItems = self.contentChanges[@(NSFetchedResultsChangeUpdate)];
		if (reloadItems.count > 0) {
			[collectionView reloadItemsAtIndexPaths:reloadItems];
//			[collectionView deleteItemsAtIndexPaths:reloadItems];
//			[collectionView insertItemsAtIndexPaths:reloadItems];
		}
		
		NSArray *moveItems = self.contentChanges[@(NSFetchedResultsChangeMove)];
		for (NSArray *paths in moveItems) {
			[collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
			
//			[collectionView deleteItemsAtIndexPaths:@[paths[0]]];
//			[collectionView insertItemsAtIndexPaths:@[paths[1]]];
		}
	} completion:nil];
	
	self.contentChanges = nil;
	self.sectionChanges = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSUInteger sections = [[self.fetchedResultsController sections] count];
	
//	NSLog(@"%@ sections = %ld", NSStringFromClass([self class]), sections);
	return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	NSUInteger rows = [self.fetchedResultsController.sections objectAtIndex:section].numberOfObjects;
//	NSLog(@"%@ rows = %ld", NSStringFromClass([self class]), rows);
	
	return rows;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {

	if (self.loadMoreEnabled) {
		if (indexPath.row == self.dataCount - self.spareDataCount ) {
			[self shouldRequestMoreData];
		}
	}
}

@end
