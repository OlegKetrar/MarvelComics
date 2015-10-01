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

#import "FSPageContainer.h"

@interface FSCharacterDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *relatedComicsLabel;

@property (weak, nonatomic) UIActivityIndicatorView *comicsIndicatorView;

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
	
	self.nameLabel.text = self.character.name;
	
		//some bug. Character Hank Pym, description is [NSTaggedPointerString class], length = 1
	
	if ([self.character.text length] > 1) {
		self.descriptionTextView.text = self.character.text;
	}
	else
		self.descriptionTextView.text = @"Oops... Marvel has not provided a description :("
												 " For more information, please visit www.marvel.com";
	
	self.descriptionTextView.layer.cornerRadius = 5.0;
	self.descriptionTextView.layer.borderWidth = 1.0;
	self.descriptionTextView.layer.borderColor = [UIColor grayColor].CGColor;

	self.imageView.layer.cornerRadius = 10;
	self.imageView.layer.borderWidth = 1.0;
	self.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	self.imageView.layer.masksToBounds = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	UIActivityIndicatorView *imageIndicatorView = [[UIActivityIndicatorView alloc]
													initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:imageIndicatorView];
	[imageIndicatorView startAnimating];
	
	imageIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageIndicatorView
														   attribute:NSLayoutAttributeCenterX
														   relatedBy:NSLayoutRelationEqual
																	   toItem:self.imageView
														   attribute:NSLayoutAttributeCenterX
																   multiplier:1.0
																	 constant:0.0]];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageIndicatorView
														   attribute:NSLayoutAttributeCenterY
														   relatedBy:NSLayoutRelationEqual
																	   toItem:self.imageView
														   attribute:NSLayoutAttributeCenterY
																   multiplier:1.0
																	 constant:0.0]];
	
		//load image
		//TODO: cache image data, do not save to CoreData
		//TODO: add animation when image appear
	NSString *urlString = [self.character imageUrlWithVariaton:kFSImageVariationsPortraitIncredible];
	__weak FSCharacterDetailViewController *weakSelf = self;
	__weak UIActivityIndicatorView *weakIndicator = imageIndicatorView;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:urlString]
									 withComplition:^(UIImage * _Nullable image) {
										 if (image) {
											 weakSelf.imageView.image = image;
											 [weakIndicator stopAnimating];
										 }
									 }];
	
	UIActivityIndicatorView *comicsIndicatorView = [[UIActivityIndicatorView alloc]
										initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.collectionView addSubview:comicsIndicatorView];
	
	comicsIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.collectionView addConstraint:[NSLayoutConstraint constraintWithItem:comicsIndicatorView
														   attribute:NSLayoutAttributeCenterX
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.collectionView
														   attribute:NSLayoutAttributeCenterX
														  multiplier:1.0
															constant:0.0]];
	
	[self.collectionView addConstraint:[NSLayoutConstraint constraintWithItem:comicsIndicatorView
														   attribute:NSLayoutAttributeCenterY
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.collectionView
														   attribute:NSLayoutAttributeCenterY
														  multiplier:1.0
															constant:0.0]];
	
	self.comicsIndicatorView = comicsIndicatorView;
	[self.comicsIndicatorView startAnimating];
	
	[self shouldRequestMoreData];
}

- (void)updateViewConstraints {
	
	[super updateViewConstraints];
	
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.collectionView collectionViewLayout];
	UIEdgeInsets scrollInsets = self.collectionView.contentInset;
	
	if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
		scrollInsets.top = self.navigationController.navigationBar.frame.size.height;
		self.collectionView.contentInset = scrollInsets;
		
		scrollInsets.left = 5;
		self.collectionView.scrollIndicatorInsets = scrollInsets;
	}
	else {
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		scrollInsets.top = 0;
		self.collectionView.contentInset = scrollInsets;
		
		scrollInsets.left = 0;
		self.collectionView.scrollIndicatorInsets = scrollInsets;
	}
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
			
			if (weakSelf.dataCount) {
				weakSelf.relatedComicsLabel.text = [NSString stringWithFormat:@"Related comics (%ld received):", weakSelf.dataCount];
			}
			else
				weakSelf.relatedComicsLabel.text = @"Related comics not found :(";
			
		}

		[weakSelf.comicsIndicatorView stopAnimating];
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
//	cell.imageView.layer.borderWidth = 2.0;
//	cell.imageView.layer.borderColor = [UIColor  whiteColor].CGColor;
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
		if ( indexPath.row > self.dataCount - 10 ) {
			[self shouldRequestMoreData];
		}
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"showImageDetail"]) {
		
		FSPageContainer *pageVC = segue.destinationViewController;
		NSString *urlString = [self.character imageUrlWithVariaton:kFSImageVariationsDetail];
		
		if (urlString)
			pageVC.imageURLs = @[urlString];
	}
}

@end





