//
//  FSCharactersViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 18.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharactersViewController.h"
#import <CoreData/CoreData.h>
#import "FSDataManager.h"

#import "FSTeam.h"
#import "FSCharacter.h"
#import "FSCharacterCell.h"

@interface FSCharactersViewController ()

@end

@implementation FSCharactersViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = self.team.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
																						   action:@selector(actionCalc:)];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [FSDataManager sharedManager].managedObjectContext;
}

- (void)actionCalc:(id)sender {
	NSLog(@"count is %ld", self.dataCount);
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
//	_fetchRequest.predicate = [NSPredicate predicateWithFormat:@"team.name like %@", self.team.name];
	
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	[[FSDataManager sharedManager] getCharactersByTeam:self.team withComplition:^(NSError *error) {
		if (error) {
			NSLog(@"error: %@", [error localizedDescription]);
		}
	}];
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
	
	NSLog(@"name: %@, url: %@", character.name, [character imageUrl]);
	
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