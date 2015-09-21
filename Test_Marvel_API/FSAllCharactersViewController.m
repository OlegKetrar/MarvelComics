//
//  FSAllCharactersViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 22.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSAllCharactersViewController.h"
#import "FSCharacterCell.h"

@import CoreData;

#import "FSCharacter.h"
#import "FSDataManager.h"

#define FS_IMAGE_NOT_AVAILABLE_1 @"http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available"
#define FS_IMAGE_NOT_AVAILABLE_2 @"http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c002e0305708"

@interface FSAllCharactersViewController ()

@end

@implementation FSAllCharactersViewController

@synthesize fetchRequest = _fetchRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"All Marvel Characters";
	self.loadMoreEnabled = YES;
	self.spareDataCount = 5;
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
	[[FSDataManager sharedManager] getCharactersWithComplition:nil];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSCharacterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell"
																	  forIndexPath:indexPath];
	FSCharacter *character = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	cell.imageView.layer.borderWidth = 2.0;
	cell.imageView.layer.borderColor = [UIColor grayColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	
	cell.nameLabel.backgroundColor = [UIColor lightGrayColor];
	cell.nameLabel.text = character.name;

	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:character.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 
										 if (!image) {
											 NSLog(@"image url = %@", character.imageUrl);
										 }
										 [cell setImage:image animated:YES];
									 }];
	return cell;
}



@end
