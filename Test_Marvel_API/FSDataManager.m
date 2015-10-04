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

//TODO: parse 1 to many & many to many relationships

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
		
		self.batchSize = 20;
		self.logEnabled = NO;
		
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
		[self.parser addParsingForEntityForName:@"Thumbnail"
							 withIdentification:nil
								  relationships:nil
									 parameters:@{@"path"	   : @"path",
												  @"extension" : @"extension" }];
		
		[self.parser addParsingForEntityForName:@"Team"
							 withIdentification:@[@"id"]
								  relationships:@{@"thumbnail"   : @"Thumbnail" }
									 parameters:@{@"id"		     : @"id",
												  @"name"		 : @"name",
												  @"description" : @"text",
												  @"thumbnail"   : @"thumbnail"}];
		
		[self.parser addParsingForEntityForName:@"Character"
							 withIdentification:@[@"id"]
								  relationships:@{@"thumbnail" : @"Thumbnail"}
									 parameters:@{@"id"		     : @"id",
												  @"name"		 : @"name",
												  @"description" : @"text",
												  @"thumbnail"	 : @"thumbnail" }];
		
		[self.parser addParsingForEntityForName:@"Comic"
							 withIdentification:@[@"id"]
								  relationships:@{@"thumbnail" : @"Thumbnail",
												  @"images"    : @"Thumbnail",
												  @"creators"  : @"Creator"}
									 parameters:@{@"id"		        : @"id",
												  @"title"		    : @"name",
												  @"description"    : @"text",
												  @"thumbnail"	    : @"thumbnail",
												  @"images"         : @"images",
												  @"creators.items" : @"creators"}];
		
		[self.parser addParsingForEntityForName:@"Creator"
							 withIdentification:@[@"name", @"role"]
								  relationships:nil
									 parameters:@{@"name" : @"name",
												  @"role" : @"role"}];
		
	}
	return self;
}

#pragma mark - GET Teams

	// load all titanic teams from local Teams.json to CoreData
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
			updateExisting:NO];
		
	if (complition) {
		complition();
	}
}

#pragma mark - GET Characters

- (nullable NSURLSessionDataTask *)getCharactersWithOffset:(NSUInteger)offset
												   success:(nullable void(^)(NSUInteger total, NSUInteger count))success
												   failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	NSDictionary *params = @{ @"offset"  : @(offset),
							  @"limit"   : @(self.batchSize),
							  @"orderBy" : @"name" };
	
	void (^successBlock)(NSURLSessionDataTask *task, id responseObject)
		= ^(NSURLSessionDataTask *task, id responseObject) {
			
			NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
										forEntityName:@"Character"
									   updateExisting:NO];
			
			if (success) {
				NSUInteger total = [[responseObject valueForKeyPath:@"data.total"] unsignedIntegerValue];
				success(total, results.count);
			}
	};
	
	return [self getDataAtPath:[self.apiPattern stringByAppendingPathComponent:@"characters"]
				withParameters:params
					   success:successBlock
					   failure:failure];
}

- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(void(^)(NSUInteger count))complition {

		// Parse characters names for given team from Teams.json
	NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Teams" withExtension:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:nil];
	NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	NSArray *teams = [jsonObj valueForKey:@"Titanic"];
	NSArray <NSString *> *names = [[teams objectAtIndex:[team.id unsignedIntegerValue]] valueForKey:@"characters"];

		// TODO: complition should invoke when all responses have been fetched
		// enqueue batch requests
	__block NSUInteger addedCharacersCount = 0;
	
	for (NSString *characterName in names) {
		
		void (^complitionBlock)(void) = nil;
		
		if ([characterName isEqual:[names lastObject]]) {
			complitionBlock = ^{
				if (complition) {
					complition(addedCharacersCount);
				}
			};
		}
		
		[self getCharacterByName:characterName
					 withSuccess:^(FSCharacter * _Nonnull character) {
						 character.team = team;
						 addedCharacersCount++;
													  
						 NSLog(@"%@ -> %@", team.name, character.name);
			
						 if (complitionBlock) complitionBlock();
					 }
						 failure:^(NSUInteger statusCode) {
							 if (complitionBlock)  complitionBlock();
						 }];
	}
}

- (nullable NSURLSessionDataTask *)getCharacterByName:(NSString *)name
										  withSuccess:(nullable void(^)(FSCharacter * _Nullable character))success
											  failure:(nullable void(^)(NSUInteger statusCode))failure {

	void (^successBlock)(NSURLSessionDataTask *task, id responseObject);
	
	successBlock = ^(NSURLSessionDataTask *task, id responseObject) {
		
		NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
									forEntityName:@"Character"
								   updateExisting:NO];

		if (results.count) {
			if (success)
			success([results firstObject]);
		}
		else {
			//TODO: set up error
			if (failure)
				failure(9999);
		}
	};
	
	return [self getDataAtPath:[self.apiPattern stringByAppendingPathComponent:@"characters"]
				withParameters:@{ @"name" : name }
					   success:successBlock
					   failure:failure];
}

- (nullable NSURLSessionDataTask *)getCharacterById:(NSUInteger)characterId
			 withSuccess:(nullable void(^)(FSCharacter * _Nullable character))success
				 failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	void (^successBlock)(NSURLSessionDataTask *task, id responseObject);
	
	successBlock = ^(NSURLSessionDataTask *task, id responseObject) {
		NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
									forEntityName:@"Character"
								   updateExisting:YES];
		
		if (success) {
			success([results firstObject]);
		}
	};
	
	return [self getDataAtPath:[self.apiPattern stringByAppendingPathComponent:@"characters"]
				withParameters:@{ @"id" : @(characterId) }
					   success:successBlock
					   failure:failure];
}

- (nullable NSURLSessionDataTask *)getCharactersByComic:(FSComic *)comic
											 withOffset:(NSUInteger)offset
												success:(nullable void(^)(NSUInteger total, NSUInteger count))success
												failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	NSString *path = [self.apiPattern stringByAppendingFormat:@"comics/%@/characters", comic.id];
	
	NSLog(@"comic id = %@", comic.id);
	
	NSDictionary *params = @{ @"offset"  : @(offset),
							  @"limit"	 : @(self.batchSize),
							  @"orderBy" : @"name" };
	
	void (^successBlock)(NSURLSessionDataTask*, id) = ^(NSURLSessionDataTask *task, id responseObject) {
		
		NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
									forEntityName:@"Character"
								   updateExisting:NO];
		
		for (FSCharacter *character in results) {
			[comic addCharactersObject:character];
		}
		
		if (success) {
			NSUInteger total = [[responseObject valueForKeyPath:@"data.total"] unsignedIntegerValue];
			success(total, results.count);
		}
	};
	
	return [self getDataAtPath:path withParameters:params success:successBlock failure:failure];
}

#pragma mark - GET Comics

- (nullable NSURLSessionDataTask *)getComicsWithOffset:(NSUInteger)offset
											   success:(nullable void(^)(NSUInteger total, NSUInteger count))success
											   failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	void (^successBlock)(NSURLSessionDataTask *task, id responseObject);
	successBlock = ^(NSURLSessionDataTask *task, id responseObject) {
		
		NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
									forEntityName:@"Comic"
								   updateExisting:NO];
	
		if (success) {
			NSUInteger total = [[responseObject objectForKey:@"total"] unsignedIntegerValue];
			success(total, results.count);
		}
	};
	
	return [self getDataAtPath:[self.apiPattern stringByAppendingPathComponent:@"comics"]
				withParameters:@{ @"offset" : @(offset), @"limit" : @(self.batchSize) }
					   success:successBlock
					   failure:failure];
}

- (nullable NSURLSessionDataTask *)getComicsByCharacter:(FSCharacter *)character
											 withOffset:(NSUInteger)offset
												success:(nullable void(^)(NSUInteger total, NSUInteger count))success
												failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	NSString *path = [self.apiPattern stringByAppendingFormat:@"characters/%@/comics", character.id];
	
	NSDictionary *params = @{ @"offset"  : @(offset),
							  @"limit"	 : @(self.batchSize),
							  @"orderBy" : @"title" };
	
	void (^successBlock)(NSURLSessionDataTask*, id) = ^(NSURLSessionDataTask *task, id responseObject) {
		
		NSArray *results = [self.parser parseData:[responseObject valueForKeyPath:@"data.results"]
									forEntityName:@"Comic"
								   updateExisting:NO];
		
		for (FSComic *comic in results) {
			[character addComicsObject:comic];
		}
		
		if (success) {
			NSUInteger total = [[responseObject valueForKeyPath:@"data.total"] unsignedIntegerValue];
			success(total, results.count);
		}
	};
	
	return [self getDataAtPath:path withParameters:params success:successBlock failure:failure];
}

- (nullable NSURLSessionDataTask *)getComicById:(NSUInteger)comicId
									withSuccess:(nullable void(^)(FSComic *comic))success
										failure:(nullable void(^)(NSUInteger statusCode))failure {
	return nil;
	
}

#pragma mark - GET base methods

- (nullable NSURLSessionDataTask *)getDataAtPath:(NSString *)path
								  withParameters:(NSDictionary *)params
										 success:(nullable void(^)(NSURLSessionDataTask *task, id responseObject))success
										 failure:(nullable void(^)(NSUInteger statusCode))failure {
	
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:[self baseParameters]];
	
	if (params) {
		[queryParams addEntriesFromDictionary:params];
	}
	
	return [self.manager GET:path
				  parameters:queryParams
					 success:success
					 failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
						 
						 self.error = error;
						 
						 if (failure) {
							 failure(((NSHTTPURLResponse*)(task.response)).statusCode);
						 }
					 }];
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
														 
														 if (error) {
															 self.error = error;
															 if (complition) complition(nil);
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
	
	if (self.logEnabled) {
		NSLog(@"error: %@", [error localizedDescription]);
	}
}

- (void)printJSONString:(id)response {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response
													   options:NSJSONWritingPrettyPrinted
														 error:nil];
	NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}

- (void)printCacheCapacity {
	NSLog(@"cache usage: disk = %ld, memory = %ld",
		  self.manager.session.configuration.URLCache.currentDiskUsage,
		  self.manager.session.configuration.URLCache.currentMemoryUsage);
	
	NSURLCache *cache = [NSURLCache sharedURLCache];
	NSLog(@"shared cache: disk = %ld, memory = %ld", cache.diskCapacity, cache.memoryCapacity);
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

@end
