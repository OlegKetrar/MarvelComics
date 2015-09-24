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
#import "FSBaseCell.h"
#import "FSCharacter.h"

@interface FSCharacterDetailViewController ()

@property (weak, nonatomic) UIActivityIndicatorView *collectionViewIndicator;

@property (nonatomic) BOOL loadMore;
@property (nonatomic) NSUInteger currentOffset;
@property (nonatomic) NSURLSessionDataTask *currentDataTask;

@end

@implementation FSCharacterDetailViewController

@synthesize fetchRequest = _fetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentOffset = 0;
	self.loadMore = YES;
	
	self.navigationItem.title = self.character.name;
	self.charIdLabel.text = self.character.id.stringValue;
	
		//wrapped text view
		//TODO: rewrite it with CoreText
	CGRect rect = self.backgroundView.frame;
	rect.origin.y -= self.descriptionView.frame.origin.y + 15.f;
	
	if ([self.character.text isEqualToString:@""])
		self.descriptionView.text = @"Oops... Marvel has not provided a description:( For more "
									 "information, please visit www.marvel.com";
	else
		self.descriptionView.text = self.character.text;
	
	UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:rect];
	self.descriptionView.textContainer.exclusionPaths = @[imgRect];
	self.descriptionView.font = [UIFont systemFontOfSize:18.f];
	self.descriptionView.textColor = [UIColor whiteColor];

	self.imageView.layer.cornerRadius = 10;
	self.imageView.layer.masksToBounds = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	
		//load image
		//TODO: cache image data, do not save to CoreData
		//TODO: add animation when image appear
	NSString *urlString = [self.character imageUrlWithVariaton:kFSImageVariationsPortraitIncredible];
	__weak FSCharacterDetailViewController *weakSelf = self;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:urlString]
									 withComplition:^(UIImage * _Nullable image) {
										 if (image) {
											 weakSelf.imageView.image = image;
											 [weakSelf.indicator stopAnimating];
										 }
									 }];
	
	UIActivityIndicatorView *collectionViewIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.collectionView.bounds];
	collectionViewIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[collectionViewIndicator startAnimating];
	collectionViewIndicator.hidesWhenStopped = YES;
	[self.collectionView addSubview:collectionViewIndicator];
	self.collectionViewIndicator = collectionViewIndicator;
	
	[self shouldRequestMoreData];
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
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY characters == %@) AND "
							   "thumbnail.path != %@ AND thumbnail.path != %@",
							   self.character, FS_IMAGE_NOT_AVAILABLE_1, FS_IMAGE_NOT_AVAILABLE_2];
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	
	__weak FSCharacterDetailViewController *weakSelf = self;
	
	NSString *loadingPhrase = @" loading...";
	if (![self.relatedComicsLabel.text hasSuffix:loadingPhrase]) {
		self.relatedComicsLabel.text = [self.relatedComicsLabel.text stringByAppendingString:loadingPhrase];
	}
	
	void (^successBlock)(NSUInteger, NSUInteger) = ^(NSUInteger total, NSUInteger count) {
		
		if (total == 0) {
			weakSelf.loadMore = NO;
			weakSelf.relatedComicsLabel.text = @"Related comics not found :(";
		}
		else {
			if (weakSelf.currentOffset >= total) {
				weakSelf.loadMore = NO;
			}
			
			weakSelf.relatedComicsLabel.text = [NSString stringWithFormat:@"Related comics (%ld of %ld):",
																			weakSelf.dataCount, total];
		}

		[weakSelf.collectionViewIndicator stopAnimating];
	};
	
	void (^failureBlock)(NSUInteger) = ^(NSUInteger statusCode) {
		if (statusCode == 500) {
			[weakSelf shouldRequestMoreData];
		}
		else
			NSLog(@"error with code %ld", statusCode);
	};
	
	self.currentDataTask = [[FSDataManager sharedManager] getComicsByCharacter:self.character
																	withOffset:self.currentOffset
																	   success:successBlock
																	   failure:failureBlock];
	
	self.currentOffset += [FSDataManager sharedManager].batchSize;
}

- (void)dealloc {
	[self.currentDataTask cancel];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell"
																	  forIndexPath:indexPath];
	FSComic *comic = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	cell.imageView.layer.borderWidth = 2.0;
	cell.imageView.layer.borderColor = [UIColor  whiteColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	
	cell.nameLabel.text = comic.name;
	
	__weak FSBaseCell *weakCell = cell;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:comic.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 [weakCell setImage:image animated:YES];
									 }];
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

//TODO: ---
// self.dataCount can frize UI if CoreData storage is SQLite
// add possibility to FSDataParser: ignore some entity with specified values (such as "image_not_found")
//									to managedObjectContext

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( self.loadMore && self.currentDataTask.state == NSURLSessionTaskStateCompleted ) {
		if ( indexPath.row == self.dataCount - 10 ) {
			[self shouldRequestMoreData];
		}
	}
}

@end
