//
//  FSTeamsCollectionViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 18.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSTeamsViewController.h"
#import <CoreData/CoreData.h>
#import "FSDataManager.h"

#import "FSTeam.h"
#import "FSBaseCell.h"

#import "FSCharactersByTeamViewController.h"

@interface FSTeamsViewController ()

@end

@implementation FSTeamsViewController

@synthesize fetchRequest = _fetchRequest;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Marvel Titanic Teams";
	self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
	
	[[FSDataManager sharedManager] getTeamsWithComplition:nil];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [FSDataManager sharedManager].managedObjectContext;
}

- (NSFetchRequest *)fetchRequest {
	if (_fetchRequest) {
		return _fetchRequest;
	}
	
	_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
	NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
																		 ascending:YES];
	_fetchRequest.sortDescriptors = @[nameSortDescriptor];
	return _fetchRequest;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FSBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"teamCell"
																 forIndexPath:indexPath];
	FSTeam *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.imageView.layer.cornerRadius = 10.0;
//	cell.imageView.layer.borderWidth = 1.0;
//	cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	cell.imageView.layer.masksToBounds = YES;
	cell.imageView.image = [UIImage imageNamed:team.imageUrl];
	
	cell.nameLabel.backgroundColor = [UIColor blackColor];
	cell.nameLabel.textColor = [UIColor whiteColor];
	cell.nameLabel.text = team.name;
	
	return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"showCharacters"]) {
		
		NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
		FSTeam *selectedTeam = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
		FSCharactersByTeamViewController *vc = segue.destinationViewController;
		vc.team = selectedTeam;
	}
}

@end








