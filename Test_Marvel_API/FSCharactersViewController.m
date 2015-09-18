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

@property (nonatomic) NSArray *data;

@end

@implementation FSCharactersViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = self.team.name;
	
//	self.data = [NSArray array];
//	
//	[[FSDataManager sharedManager] getCharactersByTeam:self.team withComplition:^(NSError *error) {
//		if (error) {
//			NSLog(@"error: %@", [error localizedDescription]);
//		}
//		[self.collectionView reloadData];
//		
//		self.data = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:nil];
//	}];
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
	return _fetchRequest;
}

//- (NSFetchedResultsController *)fetchedResultsController {
//	return nil;
//}

- (void)shouldRequestMoreData {
	[[FSDataManager sharedManager] getCharactersByTeam:self.team withComplition:^(NSError *error) {
		if (error) {
			NSLog(@"error: %@", [error localizedDescription]);
		}
//		[self.collectionView reloadData];
//		
//		self.data = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:nil];
	}];
}

#pragma mark - UICollectionViewDataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//	return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//	return self.data.count;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSCharacterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell"
																	  forIndexPath:indexPath];
	FSCharacter *character = [self.fetchedResultsController objectAtIndexPath:indexPath];
//	FSCharacter *character = [self.data objectAtIndex:indexPath.row];
	
//	cell.imageView.layer.cornerRadius = 10.0;
//	cell.imageView.layer.borderWidth = 2.0;
//	cell.imageView.layer.borderColor = [UIColor grayColor].CGColor;
//	cell.imageView.layer.masksToBounds = YES;
//	cell.imageView.image = [UIImage imageNamed:team.imageUrl];
	
	cell.backgroundColor = [UIColor redColor];
	
	cell.nameLabel.backgroundColor = [UIColor lightGrayColor];
	cell.nameLabel.text = character.name;
	
	return cell;
}
@end
