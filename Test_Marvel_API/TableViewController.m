//
//  TableViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 20.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "TableViewController.h"

@import CoreData;

#import "FSDataManager.h"

#import "FSTeam.h"
#import "FSCharactersViewController.h"

@interface TableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchRequest *fetchRequest;

@end

@implementation TableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"Teams";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						   target:self
																						   action:@selector(actionAdd:)];
}

- (void)actionAdd:(id)sender {

	[[FSDataManager sharedManager] getTeamsWithComplition:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"error: %@", [error localizedDescription]);
		}
		
		[self.tableView reloadData];
	}];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [FSDataManager sharedManager].managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController) {
		return _fetchedResultsController;
	}
	
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
																	managedObjectContext:self.managedObjectContext
																	  sectionNameKeyPath:nil
																			   cacheName:nil];
	
	_fetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest {
	if (_fetchRequest) {
		return _fetchRequest;
	}
	
	_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
	NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	[_fetchRequest setSortDescriptors:@[nameDescriptor]];
	
	return _fetchRequest;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FSTeam *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = team.name;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
	
	NSLog(@"willChangeContent");
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(nullable NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(nullable NSIndexPath *)newIndexPath {
	
	NSLog(@"didChangeObject index:(%ld,%ld) forChangeType:%ld newIndex:(%ld,%ld)", indexPath.section, indexPath.row,
		  type, newIndexPath.section, newIndexPath.row);
	
	NSLog(@"object is %@", NSStringFromClass([anObject class]));
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			if( ![[self.fetchedResultsController objectAtIndexPath:indexPath] isEqual:anObject] )
				[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
	
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	NSLog(@"didChangeSection atIndex:(%ld) forChangeType:%ld", sectionIndex, type);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
	
	NSLog(@"didChangeContent");
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"showDetail"]) {
		
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		FSTeam *selectedTeam = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
		FSCharactersViewController *dvc = segue.destinationViewController;
		dvc.team = selectedTeam;
	}
}

@end
