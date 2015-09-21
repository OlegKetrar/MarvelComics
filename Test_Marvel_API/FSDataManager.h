//
//  GDMarvelRKObjectManager.h
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;
@class NSManagedObjectContext, NSManagedObjectModel, NSPersistentStoreCoordinator, UIImage, FSTeam, FSCharacter, FSComic;

NS_ASSUME_NONNULL_BEGIN

@interface FSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSUInteger batchSize;


+ (instancetype)sharedManager;

- (void)getTeamsWithComplition:(nullable void(^)(void))complition;

- (void)getCharactersWithComplition:(nullable void(^)(void))complition;

- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(nullable void(^)(void))complition;

- (void)getCharacterByName:(NSString *)name
			   withSuccess:(nullable void(^)(FSCharacter *character))success
				   failure:(nullable void(^)(NSUInteger statusCode))failure;

- (void)getCharacterById:(NSUInteger)characterId
			 withSuccess:(nullable void(^)(FSCharacter *character))success
				 failure:(nullable void(^)(NSUInteger statusCode))failure;

- (void)getComicsByCharacter:(FSCharacter *)character
			  withComplition:(void(^)(void))complition;

- (void)getComicById:(NSUInteger *)comicId
		 withSuccess:(nullable void(^)(FSComic *comic))success
			 failure:(nullable void(^)(NSUInteger statusCode))failure;

- (NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url
							withComplition:(nullable void(^)(UIImage * _Nullable image))complition;

- (NSError *)lastError;

@end

NS_ASSUME_NONNULL_END
