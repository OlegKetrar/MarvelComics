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
#import "FSComic.h"
#import "NSString+FSMD5.h"

#import "FSDataParser.h"

#define FS_DATA_MANAGER_LOG_ENABLED

#define FS_PRODUCT_NAME @"Test_Marvel_API"

@interface FSDataManager()

@property (nonatomic) NSString *basepoint;
@property (nonatomic) NSString *apiPattern;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *privateKey;

@property (nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic) AFURLSessionManager *imageLoader;

@property (nonatomic) FSDataParser *parser;

@property (nonatomic) NSError *error;

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
		NSURL *pathToConfiguration = [[NSBundle mainBundle] URLForResource:@"MarvelAPI"
															 withExtension:@"plist"];
		NSDictionary *apiConfiguration = [NSDictionary dictionaryWithContentsOfURL:pathToConfiguration];
		
		self.basepoint   = [apiConfiguration objectForKey:@"basepoint"];
		self.apiPattern	 = [apiConfiguration objectForKey:@"apiPattern"];
		self.publicKey   = [apiConfiguration objectForKey:@"publicKey"];
		self.privateKey  = [apiConfiguration objectForKey:@"privateKey"];
		
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
		configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
		
		self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.basepoint]
												sessionConfiguration:configuration];
		
		self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
		self.parser = [FSDataParser parserWithManagedObjectContext:self.managedObjectContext];
		
			// configure parsing
		[self.parser addParsingForEntity:@"Thumbnail"
						  identification:@[@"path"]
							  parameters:@{@"path"		: @"path",
										   @"extension" : @"extension" }];
		
		[self.parser addParsingForEntity:@"Team"
						  identification:@[@"id"]
							  parameters:@{@"id"		  : @"id",
										   @"name"		  : @"name",
										   @"description" : @"text",
										   @"thumbnail"   : @"Thumbnail" }];
		
		[self.parser addParsingForEntity:@"Character"
						  identification:@[@"id"]
							  parameters:@{@"id"		  : @"id",
										   @"name"		  : @"name",
										   @"description" : @"text",
										   @"thumbnail"	  : @"Thumbnail" }];
	}
	return self;
}

#pragma mark - Get 

	// load all titanic teams from Teams.json to CoreData
	// add to each team array property with members(characters) names
- (void)getTeamsWithComplition:(void(^)(void))complition {
	
	NSError *error;
	NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Teams" withExtension:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:&error];
	
	if (error) {
		self.error = error;
		if (complition) {
			complition();
		}
		return;
	}
	
	NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		
	if (error) {
		self.error = error;
		if (complition) {
			complition();
		}
		return;
	}
		
	[self.parser parseData:[jsonObj objectForKey:@"Titanic"]
			 forEntityName:@"Team"
			withComplition:^(NSArray *results) {
				if (complition) {
					complition();
				}
			}];
}

- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(void(^)(void))complition {

		// TODO: parse characters names for given team
	NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Teams" withExtension:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:nil];
	NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	NSArray <NSString *> *names = [[[jsonObj valueForKey:@"Titanic"] objectAtIndex:[team.id unsignedIntegerValue]] valueForKey:@"characters"];

		// TODO: complition should invoke when all responses have been fetched
		// enqueue batch requests
	for (NSString *characterName in names) {
		[self getCharacterByName:characterName withSuccess:^(FSCharacter * _Nonnull character) {
			character.team = team;
			
			if (complition) complition();
			
		} failure:^(NSUInteger statusCode) {
			NSLog(@"status code %ld", statusCode);
			
			if (complition)  complition();
		}];
	}
}

- (void)getCharacterByName:(NSString *)name
			   withSuccess:(nullable void(^)(FSCharacter *character))success
				   failure:(nullable void(^)(NSUInteger statusCode))failure {

	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:[self baseParameters]];
	[queryParams addEntriesFromDictionary:@{ @"name" : name }];
	
	[self.manager GET:[self.apiPattern stringByAppendingPathComponent:@"characters"]
				  parameters:queryParams
					 success:^(NSURLSessionDataTask *task, id responseObject) {
						 
						 [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
								  forEntityName:@"Character"
								 withComplition:^(NSArray *results) {
									 if (success) {
										 success([results firstObject]);
									 }
								 }];
					 }
					 failure:^(NSURLSessionDataTask *task, NSError *error) {
						 
						 self.error = error;
						 
						 if (failure) {
							 failure(((NSHTTPURLResponse*)(task.response)).statusCode);
						 }
					 }];
}

- (void)getCharacterById:(NSUInteger)characterId
			 withSuccess:(nullable void(^)(FSCharacter *character))success
				 failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:[self baseParameters]];
	[queryParams addEntriesFromDictionary:@{ @"id" : @(characterId) }];
	
	[self.manager GET:[self.apiPattern stringByAppendingPathComponent:@"characters"]
		   parameters:queryParams
			  success:^(NSURLSessionDataTask *task, id responseObject) {
				  
				  [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
						   forEntityName:@"Character"
						  withComplition:^(NSArray *results) {
							  if (success) {
								  success([results firstObject]);
							  }
						  }];
			  }
			  failure:^(NSURLSessionDataTask *task, NSError *error) {
				  
				  self.error = error;
				  
				  if (failure) {
					  failure(((NSHTTPURLResponse*)(task.response)).statusCode);
				  }
			  }];
}

- (void)getComicsByCharacter:(FSCharacter *)character
			  withComplition:(void(^)(void))complition {
	
}

- (void)getComicById:(NSUInteger *)comicId
		 withSuccess:(nullable void(^)(FSComic *comic))success
			 failure:(nullable void(^)(NSUInteger statusCode))failure {
	
}

- (NSDictionary *)baseParameters {
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	
	NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
	NSString *hash = [[timeStamp stringByAppendingFormat:@"%@%@", self.privateKey, self.publicKey] md5String];
	
	
	return @{ @"ts"     : timeStamp,
			  @"hash"   : [hash lowercaseString],
			  @"apikey" : self.publicKey           };
}

#pragma mark - Image loading

	//TODO: handle error
- (NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url withComplition:(void(^)(UIImage *image))complition {
	
	if (!self.imageLoader) {
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
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

#pragma mark - Error handling

- (NSError *)lastError {
	return self.error;
}

- (void)setError:(NSError *)error {
	
	_error = error;
	
#ifdef FS_DATA_MANAGER_LOG_ENABLED
	NSLog(@"error: %@", [error localizedDescription]);
#endif
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
		
		self.error = error;
		return  nil;
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
			self.error = error;
			return;
		}
	}
}

@end
