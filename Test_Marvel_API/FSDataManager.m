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

@end

@implementation FSDataManager

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
		
			//create ObjectManager
//		self.manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:self.basepoint]];

			//Create Model (nonnull)
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:FS_PRODUCT_NAME withExtension:@"momd"];
		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
	}
	return self;
}

//- (void)configureMappingWithStore:(RKManagedObjectStore *)store {
//
//		//FSThumbnail ------------------------------
//	self.thumbnailMapping = [RKEntityMapping mappingForEntityForName:@"Thumbnail"
//												inManagedObjectStore:store];
//	
//	[self.thumbnailMapping setIdentificationAttributes:@[@"path"]];
//	[self.thumbnailMapping addAttributeMappingsFromDictionary: @{ @"path"	  : @"path",
//																  @"extension" : @"extension" }];
//	
//		// FSTeam ------------------------------
//	self.teamMapping = [RKEntityMapping mappingForEntityForName:@"Team"
//													   inManagedObjectStore:self.manager.managedObjectStore];
//	
//	[self.teamMapping setIdentificationAttributes:@[@"id"]];
//	[self.teamMapping addAttributeMappingsFromDictionary: @{ @"id" : @"id",
//															 @"name" : @"name",
//															 @"description" : @"text" }];
//
//	
//		// FSCharacter ------------------------------
//	self.characterMapping = [RKEntityMapping mappingForEntityForName:@"Character"
//												inManagedObjectStore:store];
//	[self.characterMapping setIdentificationAttributes:@[@"id"]];
//	[self.characterMapping addAttributeMappingsFromDictionary: @{ @"id"			: @"id",
//																  @"name"		: @"name",
//																  @"description"	: @"text" }];
//	
//		//FSComic ------------------------------
//	self.comicMapping = [RKEntityMapping mappingForEntityForName:@"Comic"
//											inManagedObjectStore:store];
//	[self.comicMapping setIdentificationAttributes:@[@"id"]];
//	[self.comicMapping addAttributeMappingsFromDictionary: @{ @"id" : @"id",
//															  @"title" : @"name",
//															  @"description" : @"text" }];
//	
//		// add baseEntity relationship with thumbnail (1 to 1)
//	[self.teamMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail"
//																					 toKeyPath:@"thumbnail"
//																				   withMapping:self.thumbnailMapping ]];
//	
//	[self.characterMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail"
//																						  toKeyPath:@"thumbnail"
//																						withMapping:self.thumbnailMapping]];
//	
//	[self.comicMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"thumbnail"
//																					  toKeyPath:@"thumbnail"
//																					withMapping:self.thumbnailMapping]];
//	
//	// add comic relationship with thumbnails (1 to many)
//	[self.comicMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"images"
//																					  toKeyPath:@"images"
//																					withMapping:self.thumbnailMapping]];
//}

- (NSManagedObjectContext *)managedObjectContext {
	return nil;
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

		// TODO: complition should invoke when all responses have been fetched
		// enqueue batch requests
//	__weak FSTeam *weakTeam = team;
	
//	for (NSString *characterName in names) {
	for (NSUInteger i=0; i<2; i++) {

		NSString *characterName = [names objectAtIndex:i];

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

- (void)getCharacterByName:(NSString *)name
			withComplition:(void(^)(FSCharacter *character, NSError *error))complition {

//	NSString *pathPattern = [self.apiPattern stringByAppendingPathComponent:@"characters"];
//	[self.manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:self.characterMapping
//																					 method:RKRequestMethodGET
//																				pathPattern:@"/v1/public/characters"
//																					keyPath:@"data.results"
//																				statusCodes:[NSIndexSet indexSetWithIndex:200]]];
//	
//	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//	[formatter setDateFormat:@"yyyyMMddHHmmss"];
//	
//	NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
//	NSString *hash = [[timeStamp stringByAppendingFormat:@"%@%@", self.privateKey, self.publicKey] md5String];
//	
//	NSDictionary *queryParams = @{ @"name"   : name,
//								   @"ts"     : timeStamp,
//								   @"hash"   : [hash lowercaseString],
//								   @"apikey" : self.publicKey           };
//	
//	[self.manager getObjectsAtPath:pathPattern
//						parameters:queryParams
//						   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//							   if (complition) {
//								   complition([mappingResult.array firstObject], nil);
//							   }
//						   }
//						   failure:^(RKObjectRequestOperation *operation, NSError *error) {
//							   if (complition) {
//								   complition(nil, error);
//							   }
//						   }];
}

- (void)getCharacterById:(NSUInteger)characterId
		  withComplition:(void(^)(FSCharacter *character, NSError *error))complition {
}

- (void)loadImageFromURL:(NSURL *)url withComplition:(void(^)(UIImage *image))complition {
	
//	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
	
//	if ([AFImageRequestOperation canProcessRequest:imageRequest]) {
//		AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest
//			success:^(UIImage *image) {
//				if (complition) {
//					complition(image);
//				}
//			}];
//		
//		[operation start];
//	}
//	else if(complition) {
//		complition(nil); //error
//	}
}

@end
