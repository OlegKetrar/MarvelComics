//
//  FSCharacterDetailViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 22.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharacterDetailViewController.h"

#import "FSDataManager.h"

#import "FSComic.h"
#import "FSComicCell.h"
#import "FSCharacter.h"

@interface FSCharacterDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) NSMutableDictionary *contentChanges;
@property (nonatomic) NSMutableDictionary *sectionChanges;

@property (nonatomic) NSMutableArray <NSURLSessionTask *> *tasks;

@property (nonatomic) BOOL loadMoreEnabled;

@end

@implementation FSCharacterDetailViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tasks = [NSMutableArray array];
	
	self.navigationItem.title = self.character.name;
	self.charIdLabel.text = self.character.id.stringValue;
	
		//wrapped text view
		//TODO: rewrite it with CoreText
	CGRect rect = self.backgroundView.frame;
	rect.origin.y -= self.descriptionView.frame.origin.y + 15.f;
	
	if ([self.character.text isEqualToString:@""])
		self.descriptionView.text = @"Oops... Marvel do not provide a description data:(";
	else
		self.descriptionView.text = self.character.text;
	
	UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:rect];
	self.descriptionView.textContainer.exclusionPaths = @[imgRect];
	self.descriptionView.font = [UIFont systemFontOfSize:18.f];
	self.descriptionView.textColor = [UIColor whiteColor];
	
	self.loadMoreEnabled = YES;
	
	self.imageView.layer.cornerRadius = 10;
	self.imageView.layer.masksToBounds = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	
		//load image
		//TODO: cache image data, do not save to CoreData
		//TODO: add animation when image appear
	NSString *urlString = [self.character imageUrlWithVariaton:kFSImageVariationsPortraitIncredible];
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:urlString]
									 withComplition:^(UIImage * _Nullable image) {
										 if (image) {
											 self.imageView.image = image;
											 [self.indicator stopAnimating];
										 }
									 }];
	UIActivityIndicatorView *collectionViewIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.collectionView.bounds];
	collectionViewIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[collectionViewIndicator startAnimating];
	collectionViewIndicator.hidesWhenStopped = YES;
	[self.collectionView addSubview:collectionViewIndicator];
	
	NSURLSessionTask *task = [[FSDataManager sharedManager] getComicsByCharacter:self.character
																  withComplition:^{
		[collectionViewIndicator stopAnimating];
		[collectionViewIndicator removeFromSuperview];
																		  
		[self.tasks removeObject:task];
	}];
	
	[self.tasks addObject:task];
}

- (NSUInteger)dataCount {
	return [self.managedObjectContext countForFetchRequest:self.fetchRequest error:nil];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [FSDataManager sharedManager].managedObjectContext;
}

- (NSFetchRequest *)fetchRequest {
	if (_fetchRequest) {
		return _fetchRequest;
	}
	
	_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comic"];
	NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
																		 ascending:YES];
	
	//TODO: add sorting by image presenting
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY characters == %@) AND "
								"thumbnail.path != %@ AND thumbnail.path != %@",
							   self.character, FS_IMAGE_NOT_AVAILABLE_1, FS_IMAGE_NOT_AVAILABLE_2];
	
	return _fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController)
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

- (void)shouldRequestMoreData {
	NSURLSessionTask *task = [[FSDataManager sharedManager] getComicsByCharacter:self.character
																  withComplition:^{
																	  [self.tasks removeObject:task];
																  }];
	[self.tasks addObject:task];
}

- (void)dealloc {
	for (NSURLSessionTask *task in self.tasks) {
		
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		
		NSLog(@"request: %@, state: %ld", dataTask.originalRequest.URL.absoluteString, dataTask.state);
		
		[task cancel];
	}
}

#pragma mark - UICollectionViewDataSource 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.fetchedResultsController.sections objectAtIndex:section].numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSComicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell"
																	  forIndexPath:indexPath];
	FSComic *comic = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	cell.imageView.layer.borderWidth = 2.0;
	cell.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	
	cell.nameLabel.text = comic.name;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:comic.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 [cell setImage:image animated:YES];
									 }];
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.loadMoreEnabled) {
		if (indexPath.row == self.dataCount - 10 ) {
			[self shouldRequestMoreData];
		}
	}
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

@end
