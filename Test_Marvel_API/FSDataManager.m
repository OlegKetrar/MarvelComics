//
//  GDMarvelRKObjectManager.m
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSDataManager.h"

@import UIKit;
@import CoreData;

#import <AFNetworking/AFNetworking.h>

#import "FSThumbnailImage.h"
#import "FSTeam.h"
#import "FSCharacter.h"
#import "NSString+FSMD5.h"

#define FS_PRODUCT_NAME @"Test_Marvel_API"

@interface FSDataManager()

@property (nonatomic) NSString *basepoint;
@property (nonatomic) NSString *apiPattern;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *privateKey;

@property (nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic) AFURLSessionManager *imageLoader;

@end

@implementation FSDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)sharedManager {
	static id manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		
		self.batchSize = 10;
		
			//Read marvel api configuration from plist
		NSURL *pathToConfiguration = [[NSBundle mainBundle] URLForResource:@"MarvelAPI" withExtension:@"plist"];
		NSDictionary *apiConfiguration = [NSDictionary dictionaryWithContentsOfURL:pathToConfiguration];
		
		self.basepoint   = [apiConfiguration objectForKey:@"basepoint"];
		self.apiPattern = [apiConfiguration objectForKey:@"apiPattern"];
		self.publicKey   = [apiConfiguration objectForKey:@"publicKey"];
		self.privateKey  = [apiConfiguration objectForKey:@"privateKey"];
		
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
		
		self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.basepoint]
												sessionConfiguration:configuration];
		
		self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
		
	}
	return self;
}

- (NSUInteger)count {
	return 0;
}

#pragma mark - Get 

	// load all titanic teams from Teams.json to CoreData
	// add to each team array property with members(characters) names
- (void)getTeamsWithComplition:(nullable void(^)(NSError * _Nullable error))complition {
	
	NSError *error;
	NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Teams" withExtension:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:&error];

	if (!error) {
		NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		NSArray <NSDictionary *> *teams = [jsonObj objectForKey:@"Titanic"];
		
		for (NSDictionary *teamDictionary in teams) {
			FSTeam *team = [NSEntityDescription insertNewObjectForEntityForName:@"Team"
														 inManagedObjectContext:self.managedObjectContext];
			team.thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
														   inManagedObjectContext:self.managedObjectContext];
			[team configureWithResponse:teamDictionary];
			[team.thumbnail configureWithResponse:[teamDictionary objectForKey:@"thumbnail"]];
			team.charactersNames = [teamDictionary objectForKey:@"characters"];
		}
	}
	
	if (complition) {
		complition(error);
	}
}

- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(nullable void(^)(NSError * _Nullable error))complition {
	
	NSArray <NSString *> *names = team.charactersNames;

		// TODO: complition should invoke when all responses have been fetched
		// enqueue batch requests
	for (NSString *characterName in names) {

		[self getCharacterByName:characterName withComplition:^(FSCharacter *character, NSError *error) {
			
			if (character) {
				[team addCharactersObject:character];
				complition(nil);
			}
			else
				NSLog(@"error: %@", [error localizedDescription]);
		}];
	}
}

	//TODO: handle status code
- (void)getCharacterByName:(NSString *)name
			withComplition:(void(^)(FSCharacter *character, NSError *error))complition {

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	
	NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
	NSString *hash = [[timeStamp stringByAppendingFormat:@"%@%@", self.privateKey, self.publicKey] md5String];
	
	NSDictionary *queryParams = @{ @"name"   : name,
								   @"ts"     : timeStamp,
								   @"hash"   : [hash lowercaseString],
								   @"apikey" : self.publicKey           };
	
	[self.manager GET:[self.apiPattern stringByAppendingPathComponent:@"characters"]
				  parameters:queryParams
					 success:^(NSURLSessionDataTask *task, id responseObject) {
						 
						 NSDictionary *characterDictionary = [[responseObject valueForKeyPath:@"data.results"] firstObject];
						 FSCharacter *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character"
																				inManagedObjectContext:self.managedObjectContext];
						 [character configureWithResponse:characterDictionary];
						 
						 if (![[characterDictionary objectForKey:@"thumbnail"] isEqual:[NSNull null]]) {
							 character.thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
																				 inManagedObjectContext:self.managedObjectContext];
							 [character.thumbnail configureWithResponse:[characterDictionary objectForKey:@"thumbnail"]];
						 }
						 
						 if (complition) {
							 complition(character, nil);
						 }
					 }
					 failure:^(NSURLSessionDataTask *task, NSError *error) {
						 
						 if (complition)
							 complition(nil, error);
						 
					 }];
}

- (void)getCharacterById:(NSUInteger)characterId
		  withComplition:(void(^)(FSCharacter *character, NSError *error))complition {
}

	//TODO: handle error
- (NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url withComplition:(void(^)(UIImage *image))complition {
	
	if (self.imageLoader == nil) {
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		self.imageLoader = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
		self.imageLoader.responseSerializer = [AFImageResponseSerializer serializer];
	}
	
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
	
	NSURLSessionDataTask *task = [self.imageLoader dataTaskWithRequest:imageRequest
													 completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
														if (responseObject) {
															if (complition) complition(responseObject);
														}
													 }];
	[task resume];
	return task;
}

#pragma mark - Core Data setup

- (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
	// The managed object model for the application.
	// It is a fatal error for the application not to be able to find and load its model.
	if (_managedObjectModel) {
		return _managedObjectModel;
	}
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:FS_PRODUCT_NAME withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	// The persistent store coordinator for the application. This implementation creates and returns a coordinator,
	// having added the store for the application to it.
	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
	}
	
	// Create the coordinator and store
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	//	NSString *storeFilename = [NSString stringWithFormat:@"%@.sqlite", FS_PRODUCT_NAME];
	//	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeFilename];
	NSError *error = nil;
	NSString *failureReason = @"There was an error creating or loading the application's saved data.";
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
												   configuration:nil
															 URL:nil
														 options:nil
														   error:&error]) {
		// Report any error we got.
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
		dict[NSLocalizedFailureReasonErrorKey] = failureReason;
		dict[NSUnderlyingErrorKey] = error;
		error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
		// Replace this with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this
		// function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
	// Returns the managed object context for the application (which is already bound
	// to the persistent store coordinator for the application.)
	if (_managedObjectContext) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
		return nil;
	}
	
	_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
	return _managedObjectContext;
}

- (void)saveContext {
	if (self.managedObjectContext != nil) {
		NSError *error = nil;
		if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate.
			// You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

@end
