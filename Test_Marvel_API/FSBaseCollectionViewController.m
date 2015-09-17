//
//  FSBaseCollectionViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import CoreData;

#import "FSBaseCollectionViewController.h"
#import "FSDataManager.h"
#import "FSTeam.h"
#import "FSThumbnailImage.h"

#import "FSBaseCollectionViewCell.h"

@interface FSBaseCollectionViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResults;

@end

@implementation FSBaseCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Marvel Titanic Teams";
	[[FSDataManager sharedManager] getTeamsWithComplition:^(NSError * _Nullable error) {
		if (error) NSLog(@"error: %@", [error localizedDescription]);
		
//		[self.collectionView reloadData];
	}];
}

- (NSFetchedResultsController *)fetchedResults
{
	if (_fetchedResults != nil) {
		
		return _fetchedResults;
	}
	
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
	
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:@[nameDescriptor]];
//	[request setFetchBatchSize: 10];
	
	NSManagedObjectContext *context = [FSDataManager sharedManager].managedObjectContext;
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		  managedObjectContext:context
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	frc.delegate = self;
	_fetchedResults = frc;
	
	NSError *error = nil;
	if (![_fetchedResults performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _fetchedResults;
}

- (void)configureCell:(FSBaseCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FSTeam *team = [self.fetchedResults objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	cell.imageView.layer.borderWidth = 2.0;
	cell.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	[cell.imageView.layer setMasksToBounds:YES];
	cell.imageView.contentMode = UIViewContentModeScaleToFill;
	
	cell.imageView.image = [UIImage imageNamed:team.imageUrl];
	cell.nameLabel.text = team.name;
	cell.nameLabel.backgroundColor = [UIColor lightGrayColor];
	cell.nameLabel.opaque = YES;
	cell.nameLabel.layer.cornerRadius = 5.0;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(nullable NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(nullable NSIndexPath *)newIndexPath {
	
	if (type == NSFetchedResultsChangeInsert) {
		[self.collectionView insertItemsAtIndexPaths:@[indexPath]];
	}
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	if (type == NSFetchedResultsChangeInsert) {
		[self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
	}
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//	[self.tableView beginUpdates];
//	[self.collectionView ]
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	[self.tableView endUpdates];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResults sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedResults.sections objectAtIndex:section].numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    FSBaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
																			   forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	
//	NSUInteger countOfData = [[FSDataManager sharedManager] count];
//	
//	NSLog(@"index = %ld, count = %ld", indexPath.row, countOfData);
//	
//	if (indexPath.row == countOfData - 5 ) {
//		[self loadMore];
//		NSLog(@"loading data");
//	}
}

@end
