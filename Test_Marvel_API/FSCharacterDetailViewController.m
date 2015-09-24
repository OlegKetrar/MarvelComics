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

@property (nonatomic) NSMutableArray <NSURLSessionTask *> *tasks;

@property (nonatomic) NSUInteger currentOffset;
@property (nonatomic) NSURLSessionDataTask *lastTask;

@end

@implementation FSCharacterDetailViewController

@synthesize fetchRequest = _fetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tasks = [NSMutableArray array];
	self.currentOffset = 0;
	
	self.navigationItem.title = self.character.name;
	self.charIdLabel.text = self.character.id.stringValue;
	
		//wrapped text view
		//TODO: rewrite it with CoreText
	CGRect rect = self.backgroundView.frame;
	rect.origin.y -= self.descriptionView.frame.origin.y + 15.f;
	
	if ([self.character.text isEqualToString:@""])
		self.descriptionView.text = @"Oops... Marvel has not provided a description:(\nFor more "
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
	
	//TODO: add sorting by image presenting
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY characters == %@) AND "
								"thumbnail.path != %@ AND thumbnail.path != %@",
							   self.character, FS_IMAGE_NOT_AVAILABLE_1, FS_IMAGE_NOT_AVAILABLE_2];
	
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	
	__weak FSCharacterDetailViewController *weakSelf = self;
	
	void (^successBlock)(NSUInteger, NSUInteger) = ^(NSUInteger total, NSUInteger count) {
		weakSelf.relatedComicsLabel.text = [NSString stringWithFormat:@"Related comics (%ld total):", total];
		[weakSelf.collectionViewIndicator stopAnimating];
	};
	
	void (^failureBlock)(NSUInteger) = ^(NSUInteger statusCode) {
		if (statusCode == 500) {
			weakSelf.relatedComicsLabel.text = @"Loading...";
			[weakSelf shouldRequestMoreData];
		}
		else
			weakSelf.relatedComicsLabel.text = @"Related comics not found :(";
	};
	
	self.lastTask = [[FSDataManager sharedManager] getComicsByCharacter:self.character
															 withOffset:self.currentOffset
																success:successBlock
																failure:failureBlock];
	
	self.currentOffset += [FSDataManager sharedManager].batchSize;
	
	NSLog(@"send more request: %@", self.lastTask.originalRequest.URL.absoluteString);
	
}

- (void)dealloc {
//	for (NSURLSessionTask *task in self.tasks) {
//		
//		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
//		
//		NSLog(@"request: %@, state: %ld", dataTask.originalRequest.URL.absoluteString, dataTask.state);
//		
//		[task cancel];
//	}
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

- (void)collectionView:(UICollectionView *)collectionView
	   willDisplayCell:(UICollectionViewCell *)cell
	forItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if ( self.lastTask && (self.lastTask.state == NSURLSessionTaskStateCompleted)) {
		if ( indexPath.row == self.dataCount - 10 ) {
			[self shouldRequestMoreData];
		}
	}
}

@end
