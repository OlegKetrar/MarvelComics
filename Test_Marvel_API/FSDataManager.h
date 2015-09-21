//
//  GDMarvelRKObjectManager.h
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;
@class NSManagedObjectContext, NSManagedObjectModel, NSPersistentStoreCoordinator, UIImage, FSTeam, FSCharacter;

NS_ASSUME_NONNULL_BEGIN

@interface FSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSUInteger batchSize;


+ (instancetype)sharedManager;

- (void)getTeamsWithComplition:(nullable void(^)(NSError * _Nullable error))complition;

//
////send request for team by id
//- (void)getTeamById:(NSUInteger *)teamId
//	 withComplition:(nullable void(^)(NSError * _Nullable error))complition;


- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(nullable void(^)(NSError * _Nullable error))complition;

- (void)getCharacterByName:(NSString *)name
			withComplition:(nullable void(^)(FSCharacter * _Nullable character, NSError * _Nullable error))complition;

- (void)getCharacterById:(NSUInteger)characterId
		  withComplition:(nullable void(^)(FSCharacter * _Nullable character, NSError * _Nullable error))complition;

- (NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url
							withComplition:(nullable void(^)(UIImage * _Nullable image))complition;

@end

NS_ASSUME_NONNULL_END
