//
//  AppDelegate.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "AppDelegate.h"

#import "FSDataManager.h"
#import "FSDataParser.h"

#import "FSTeam.h"
#import "FSThumbnailImage.h"

@import CoreData;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
//	NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Teams" withExtension:@"json"];
//	NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:nil];
//	
//	NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//	NSArray <NSDictionary *> *teams = [jsonObj objectForKey:@"Titanic"];
//	
//	NSManagedObjectContext *context = [FSDataManager sharedManager].managedObjectContext;
//	
//	FSDataParser *parser = [[FSDataParser alloc] initWithManagedObjectContext:context];
//	[parser addParsingForEntity:@"Team"
//					 parameters:@{@"id" : @"id", @"name" : @"name", @"description" : @"text", @"thumbnail" : @"Thumbnail"}
//				 identification:@[@"id"]];
//	
//	[parser addParsingForEntity:@"Thumbnail"
//					 parameters:@{@"path" : @"path", @"extension" : @"extension"}
//				 identification:@[@"path"]];
//	
//	[parser parseData:teams forEntityName:@"Team" withComplition:^(NSArray<NSManagedObject *> * _Nullable results) {
//		
//		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
//		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
//		
//		NSArray *fetchedResults = [context executeFetchRequest:request error:nil];
//		NSLog(@"count: %ld", fetchedResults.count);
//		
//		for (FSTeam *team in fetchedResults) {
//			NSLog(@"id: %@, name: %@, description: %@", team.id, team.name, team.text);
//			NSLog(@"url: %@", [team imageUrl]);
//		}
//	}];

	return YES;
}

@end
