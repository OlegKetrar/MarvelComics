//
//  GDMarvelRKObjectManager.m
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSDataManager.h"

@import CoreData;
#import <RestKit/RestKit.h>

#import "FSThumbnailImage.h"
#import "FSTeam.h"
#import "FSCharacter.h"
#import "NSString+FSMD5.h"

//TODO: add downloader for images

#define FS_PRODUCT_NAME @"Test_Marvel_API"

@interface FSDataManager()

@property (nonatomic) NSString *basepoint;
@property (nonatomic) NSString *apiPattern;

@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *privateKey;

@property (strong, nonatomic) RKObjectManager *manager;

@end

@implementation FSDataManager

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
		
			//create ObjectManager
		self.manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:self.basepoint]];

			//Create Model (nonnull)
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:FS_PRODUCT_NAME withExtension:@"momd"];
		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
			//Create Store (nonnul)
		RKManagedObjectStore *store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:model];
		[store addInMemoryPersistentStore:nil];
		[store createManagedObjectContexts];
		self.manager.managedObjectStore = store;
		
			//Configure Mapping for Character entity
			//TODO: move this to appropriate getMethod
		[self.manager addResponseDescriptor:[self responseDescriptorWith:self.manager.managedObjectStore
														   forEntityName:@"Character"]];
	}
	return self;
}

- (RKResponseDescriptor *)responseDescriptorWith:(RKManagedObjectStore *)store
								   forEntityName:(NSString *)entityName {

		//TODO: should create descriptor for specific entity
	
	RKEntityMapping *characterMapping = [RKEntityMapping mappingForEntityForName:@"Character"
															inManagedObjectStore:store];
	characterMapping.identificationAttributes = @[@"id"];
	[characterMapping addAttributeMappingsFromDictionary: @{ @"id"			: @"id",
															 @"name"		: @"name",
															 @"description"	: @"text" }];
	
	RKEntityMapping *thumbnailMapping = [RKEntityMapping mappingForEntityForName:@"Thumbnail"
															inManagedObjectStore:self.manager.managedObjectStore];
	thumbnailMapping.identificationAttributes = @[@"path"];
	[thumbnailMapping addAttributeMappingsFromDictionary: @{ @"path"	  : @"path",
															 @"extension" : @"extension" }];
	
	[characterMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail"
																					 toKeyPath:@"thumbnail"
																				   withMapping:thumbnailMapping]];
	
	NSString *pathPattern = [self.apiPattern stringByAppendingPathComponent:@"characters"];
	return [RKResponseDescriptor responseDescriptorWithMapping:characterMapping
														method:RKRequestMethodGET
												   pathPattern:pathPattern
													   keyPath:@"data.results"
												   statusCodes:[NSIndexSet indexSetWithIndex:200]];
}

- (NSManagedObjectContext *)managedObjectContext {
	return [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
}

- (NSUInteger)count {
	return [self.managedObjectContext countForEntityForName:@"Character" predicate:nil error:nil];
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
			team.id = [teamDictionary objectForKey:@"id"];
			team.name = [teamDictionary objectForKey:@"name"];
			team.text = [teamDictionary objectForKey:@"description"];
			team.thumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
														   inManagedObjectContext:self.managedObjectContext];
			team.thumbnail.path = [teamDictionary valueForKeyPath:@"thumbnail.path"];
			team.thumbnail.extension = [teamDictionary valueForKeyPath:@"thumbnail.extension"];
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

//	NSString *characterName = [names objectAtIndex:0];
	for (NSString *characterName in names) {
	
		//TODO: add some multithreading
		//need to sleep between requests
		[self getCharacterByName:characterName withComplition:complition];
	}
}

- (void)getCharacterByName:(NSString *)name
			withComplition:(nullable void(^)(NSError * _Nullable error))complition {
	
	[self.manager addResponseDescriptor:[self responseDescriptorWith:self.manager.managedObjectStore
													   forEntityName:@"Character"]];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *pathPattern = [self.apiPattern stringByAppendingPathComponent:@"characters"];
	
	NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
	NSString *hash = [[timeStamp stringByAppendingFormat:@"%@%@", self.privateKey, self.publicKey] md5String];
	
	NSDictionary *queryParams = @{ @"name"   : name,
								   @"ts"     : timeStamp,
								   @"hash"   : [hash lowercaseString],
								   @"apikey" : self.publicKey           };
	
	[self.manager getObjectsAtPath:pathPattern
						parameters:queryParams
						   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
							   if (complition) {
								   complition(nil);
							   }
						
						   }
						   failure:^(RKObjectRequestOperation *operation, NSError *error) {
							   if (complition) {
								   complition(error);
							   }
						   }];
}

- (void)getCharacterWithComplition:(nullable void(^)(NSError * _Nullable error))complition {
}

#pragma mark -

- (void)loadDataWithComplition:(void(^)(NSArray *results, NSError *error))complition {
	
	[self loadDataWithOffset:[self count]
		success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
			if (complition) complition(mappingResult.array, nil);
		}
		failure:^(RKObjectRequestOperation *operation, NSError *error) {
			if (complition) complition(nil, error);
		}];
}

- (void)loadDataWithOffset:(NSInteger)offset
				   success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
				   failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
	NSString *hash = [[timeStamp stringByAppendingFormat:@"%@%@", self.privateKey, self.publicKey] md5String];
	
	NSDictionary *queryParams = @{ @"offset" : @(offset),
								   @"limit"  : @(self.batchSize),
								   @"ts"     : timeStamp,
								   @"hash"   : [hash lowercaseString],
								   @"apikey" : self.publicKey           };

	[self.manager getObjectsAtPath:@"/v1/public/characters"
						parameters:queryParams
						   success:success
						   failure:failure];
}

@end
