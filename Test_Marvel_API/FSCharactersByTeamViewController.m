//
//  FSCharactersViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 18.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharactersByTeamViewController.h"
#import "FSBaseCell.h"
#import "FSCharacterDetailViewController.h"

@import CoreData;

#import "FSDataManager.h"
#import "FSTeam.h"
#import "FSCharacter.h"

@interface FSCharactersByTeamViewController ()

@end

@implementation FSCharactersByTeamViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = self.team.name;
	
	__weak FSCharactersByTeamViewController *weakSelf = self;
	
	[[FSDataManager sharedManager] getCharactersByTeam:self.team withComplition:^(NSUInteger count) {
		NSLog(@"achive %ld characters by %@ team", count, weakSelf.team.name);
	}];
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
	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"team.name = %@", self.team.name];
	
	return _fetchRequest;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell"
																	  forIndexPath:indexPath];
	FSCharacter *character = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
	cell.imageView.layer.borderWidth = 2.0;
	cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showDetail"]) {
		
		NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
		FSCharacter *selectedCharacter = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
		FSCharacterDetailViewController *dvc = segue.destinationViewController;
		dvc.character = selectedCharacter;
	}
}
@end
