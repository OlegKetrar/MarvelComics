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
	NSPredicate *teamPredicate = [NSPredicate predicateWithFormat:@"team.name like %@", self.team.name];
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	_fetchRequest.predicate = teamPredicate;
	
	return _fetchRequest;
}

- (void)shouldRequestMoreData {
	[[FSDataManager sharedManager] getCharactersByTeam:self.team withComplition:^(NSError *error) {
		if (error) {
			NSLog(@"error: %@", [error localizedDescription]);
		}
		
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comic"];
		NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
		request.sortDescriptors = @[idDescriptor];
		
		NSError *error2;
		NSArray *results = [[FSDataManager sharedManager].managedObjectContext executeFetchRequest:request error:&error2];
		NSLog(@"results = %@", results);
		
		if (error2) {
			NSLog(@"fetch error: %@", [error2 localizedDescription]);
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
