//
//  GDMarvelRKObjectManager.h
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;

@class NSManagedObjectContext, NSManagedObjectModel, NSPersistentStoreCoordinator, UIImage;
@class FSTeam, FSCharacter, FSComic;

#define FS_IMAGE_NOT_AVAILABLE_1 @"http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available"
#define FS_IMAGE_NOT_AVAILABLE_2 @"http://i.annihil.us/u/prod/marvel/i/mg/f/60/4c002e0305708"

NS_ASSUME_NONNULL_BEGIN

@interface FSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSUInteger batchSize;

+ (instancetype)sharedManager;

- (void)getTeamsWithComplition:(nullable void(^)(void))complition;

//---------------characters-----------------------------------------------------------------
- (void)getCharactersWithComplition:(nullable void(^)(void))complition; // load all characters

- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(nullable void(^)(void))complition; // load characters by specified team

- (void)getCharacterByName:(NSString *)name
			   withSuccess:(nullable void(^)(FSCharacter *character))success
				   failure:(nullable void(^)(NSUInteger statusCode))failure; //load single character

- (void)getCharacterById:(NSUInteger)characterId
			 withSuccess:(nullable void(^)(FSCharacter *character))success
				 failure:(nullable void(^)(NSUInteger statusCode))failure; // load single character

//---------------comics----------------------------------------------------------------------
- (nullable NSURLSessionDataTask *)getComicsByCharacter:(FSCharacter *)character
										 withComplition:(void(^)(void))complition;

- (nullable NSURLSessionDataTask *)getComicById:(NSUInteger)comicId
									withSuccess:(nullable void(^)(FSComic *comic))success
										failure:(nullable void(^)(NSUInteger statusCode))failure;


//---------------other-----------------------------------------------------------------------
- (NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url
							withComplition:(nullable void(^)(UIImage * _Nullable image))complition;
- (NSError *)lastError;

@end

NS_ASSUME_NONNULL_END
