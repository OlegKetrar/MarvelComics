//
//  FSAllCharactersViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 22.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharactersViewController.h"
#import "FSBaseCell.h"
#import "FSCharacterDetailViewController.h"

@import CoreData;

#import "FSCharacter.h"
#import "FSDataManager.h"

@interface FSCharactersViewController ()

@property (nonatomic) BOOL loadMore;
@property (nonatomic) NSUInteger currentOffset;
@property (nonatomic) NSURLSessionDataTask *currentDataTask;

@end

@implementation FSCharactersViewController

@synthesize fetchRequest = _fetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.currentOffset = 0;
	self.loadMore = YES;
	
	self.navigationItem.title = @"All Marvel Characters";
	
	[self shouldRequestMoreData];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [FSDataManager sharedManager].managedObjectContext;
}

- (NSFetchRequest *)fetchRequest {
	if (_fetchRequest) {
		return _fetchRequest;
	}
	
	_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Character"];
	NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
																		 ascending:YES];
	
	
		//TODO: add sorting by image presenting
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"thumbnail.path != %@ AND thumbnail.path != %@",
							   FS_IMAGE_NOT_AVAILABLE_1, FS_IMAGE_NOT_AVAILABLE_2];
	
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	
	__weak FSCharactersViewController *weakSelf = self;
	
	self.currentDataTask = [[FSDataManager sharedManager] getCharactersWithOffset:self.currentOffset
																		  success:^(NSUInteger total, NSUInteger count) {
																			  if (weakSelf.currentOffset >= total) {
																				  weakSelf.loadMore = NO;
																			  }
																		  }
																		  failure:^(NSUInteger statusCode) {
																			  if (statusCode == 500) {
																				  [weakSelf shouldRequestMoreData];
																			  }
																		  }];
	
	self.currentOffset += [FSDataManager sharedManager].batchSize;
}

- (void)dealloc {
	[self.currentDataTask cancel];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell"
																	  forIndexPath:indexPath];
	FSCharacter *character = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
//	cell.imageView.layer.borderWidth = 1.0;
//	cell.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	
	cell.nameLabel.backgroundColor = [UIColor blackColor];
	cell.nameLabel.textColor = [UIColor whiteColor];
	cell.nameLabel.text = character.name;
	
	__weak FSBaseCell *weakCell = cell;

	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:character.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 
										 [weakCell setImage:image animated:YES];
									 }];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.loadMore && self.currentDataTask.state == NSURLSessionTaskStateCompleted) {
		if (indexPath.row > self.dataCount - 10 )
			[self shouldRequestMoreData];
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showDetail"]) {
		
		NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
		FSCharacter *selectedCharacter = [self.fetchedResultsController objectAtIndexPath:indexPath];
		FSCharacterDetailViewController *dvc = segue.destinationViewController;
		dvc.character = selectedCharacter;
	}
}

@end
