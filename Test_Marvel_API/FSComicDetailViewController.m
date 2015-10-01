//
//  FSComicViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 01.10.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSComicDetailViewController.h"
#import "FSBaseCell.h"
#import "FSPageContainer.h"
#import "FSCharacterDetailViewController.h"

#import "FSDataManager.h"
#import "FSComic.h"
#import "FSCharacter.h"

@interface FSComicDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *nameBackgroundView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *relatedBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorsLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *relatedLabelConstraint;

@property (nonatomic) BOOL loadMore;
@property (nonatomic) NSUInteger currentOffset;
@property (nonatomic) NSURLSessionDataTask *currentDataTask;

@end

@implementation FSComicDetailViewController

@synthesize fetchRequest = _fetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentOffset = 0;
	self.loadMore = YES;
	
	self.nameLabel.text = self.comic.name;

	if ([self.comic.text length] > 1) {
		self.descriptionLabel.text = self.comic.text;
	}
	else
		self.descriptionLabel.text = @"Oops... Marvel has not provided a description :("
									 " For more information, please visit www.marvel.com";
	
	self.creatorsLabel.text = @"Alan Patrik - director\n"
							   "John Prinkle - designer\n"
							   "Woody Alan - writter";
	
	self.imageView.layer.cornerRadius = 10;
	self.imageView.layer.borderWidth = 1.0;
	self.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	self.imageView.layer.masksToBounds = YES;
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	NSString *urlString = [self.comic imageUrl];
	__weak FSComicDetailViewController *weakSelf = self;
//	__weak UIActivityIndicatorView *weakIndicator = imageIndicatorView;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:urlString]
									 withComplition:^(UIImage * _Nullable image) {
										 if (image) {
											 weakSelf.imageView.image = image;
//											 [weakIndicator stopAnimating];
										 }
									 }];
	[self shouldRequestMoreData];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.collectionView collectionViewLayout];
	UIEdgeInsets collectionInsets = self.collectionView.contentInset;
	UIEdgeInsets scrollInsets = self.scrollView.contentInset;
	
	CGFloat verticalOffset = self.navigationController.navigationBar.frame.size.height;
	verticalOffset += self.navigationController.navigationBar.frame.origin.y;
	verticalOffset += self.nameBackgroundView.frame.size.height;
	
	scrollInsets.top = verticalOffset;
	
	self.nameConstraint.constant = self.navigationController.navigationBar.frame.size.height;
	self.nameConstraint.constant += self.navigationController.navigationBar.frame.origin.y;
	
	if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
			// collection view
		flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
		collectionInsets.top = self.navigationController.navigationBar.frame.size.height;
//		self.collectionView.contentInset = collectionInsets;
//		collectionInsets.left = 5;
//		self.collectionView.scrollIndicatorInsets = collectionInsets;
		
			// scroll view 
		self.relatedLabelConstraint.constant = - self.tabBarController.tabBar.frame.size.height;
		scrollInsets.bottom = self.tabBarController.tabBar.frame.size.height + self.relatedBackgroundView.frame.size.height;
	}
	else {
			//collection view
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		scrollInsets.top = 0;
//		self.collectionView.contentInset = scrollInsets;
		
//		scrollInsets.left = 0;
//		self.collectionView.scrollIndicatorInsets = scrollInsets;
		
			// scroll view
		self.relatedLabelConstraint.constant = 0;
		scrollInsets.bottom = self.relatedBackgroundView.frame.size.height;
	}
	
	self.collectionView.contentInset = scrollInsets;
	self.collectionView.scrollIndicatorInsets = scrollInsets;
	
	self.scrollView.contentInset = scrollInsets;
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
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY comics == %@) AND "
							   "thumbnail.path != %@ AND thumbnail.path != %@",
							   self.comic, FS_IMAGE_NOT_AVAILABLE_1, FS_IMAGE_NOT_AVAILABLE_2];
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	
	__weak FSComicDetailViewController *weakSelf = self;
	
	NSString *loadingPhrase = @" loading...";
	if (![self.relatedLabel.text hasSuffix:loadingPhrase]) {
		self.relatedLabel.text = [self.relatedLabel.text stringByAppendingString:loadingPhrase];
	}
	
	void (^successBlock)(NSUInteger, NSUInteger) = ^(NSUInteger total, NSUInteger count) {
		
		if (total == 0) {
			weakSelf.loadMore = NO;
			weakSelf.relatedLabel.text = @"Related characters not found :(";
		}
		else {
			if (weakSelf.currentOffset >= total) {
				weakSelf.loadMore = NO;
			}
			
			if (weakSelf.dataCount) {
				weakSelf.relatedLabel.text = [NSString stringWithFormat:@"Related characters (%ld received):", weakSelf.dataCount];
			}
			else
				weakSelf.relatedLabel.text = @"Related characters not found :(";
			
		}
		
		NSLog(@"total: %ld, count %ld", total, count);
		
//		[weakSelf.comicsIndicatorView stopAnimating];
	};
	
	void (^failureBlock)(NSUInteger) = ^(NSUInteger statusCode) {
		if (statusCode == 500) {
			[weakSelf shouldRequestMoreData];
		}
		else
			NSLog(@"error with code %ld", statusCode);
	};
	
	self.currentDataTask = [[FSDataManager sharedManager] getCharactersByComic:self.comic
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
	
	FSBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell"
																 forIndexPath:indexPath];
	FSCharacter *character = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	//	cell.imageView.layer.borderWidth = 2.0;
	//	cell.imageView.layer.borderColor = [UIColor  whiteColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	cell.nameLabel.text = character.name;
	
	__weak FSBaseCell *weakCell = cell;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:character.imageUrl]
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
		NSString *urlString = [self.comic imageUrl];
		
		if (urlString)
			pageVC.imageURLs = @[urlString];
	}
	else if ([segue.identifier isEqualToString:@"showCharacter"]) {
		
		NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
		FSCharacter *selectedCharacter = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
		FSCharacterDetailViewController *dvc = segue.destinationViewController;
		dvc.character = selectedCharacter;
	}
}

@end
