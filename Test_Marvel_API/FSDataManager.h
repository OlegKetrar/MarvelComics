//
//  GDMarvelRKObjectManager.h
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;
@class NSManagedObjectContext, UIImage, FSTeam, FSCharacter;

NS_ASSUME_NONNULL_BEGIN

@interface FSDataManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSUInteger batchSize;


+ (instancetype)sharedManager;
- (NSUInteger)count;

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

- (void)loadImageFromURL:(NSURL *)url withComplition:(nullable void(^)(UIImage * _Nullable image))complition;
//
//
//
////send request for comics by character id
//- (void)getCharacterWithComplition:(nullable void(^)(NSError * _Nullable error))complition;


//
//- (void)loadDataWithOffset:(NSInteger)offset
//				   success:(nullable void(^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
//				   failure:(nullable void(^)(RKObjectRequestOperation *operation, NSError *error))failure;
//
//- (void)loadDataWithComplition:(nullable void(^)(NSArray * _Nullable results, NSError * _Nullable error))complition;

@end

NS_ASSUME_NONNULL_END
