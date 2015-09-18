//
//  GDMarvelRKObjectManager.h
//  Test2
//
//  Created by Oleg Ketrar on 03.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;
@class NSManagedObjectContext, RKObjectRequestOperation, RKMappingResult, FSTeam;

NS_ASSUME_NONNULL_BEGIN

@interface FSDataManager : NSObject

@property (nonatomic) NSUInteger batchSize;


+ (instancetype)sharedManager;
- (NSManagedObjectContext *)managedObjectContext;
- (NSUInteger)count;

- (void)getTeamsWithComplition:(nullable void(^)(NSError * _Nullable error))complition;

//
////send request for team by id
//- (void)getTeamById:(NSUInteger *)teamId
//	 withComplition:(nullable void(^)(NSError * _Nullable error))complition;
//
//
////send requests: for names of team members(i.e. characters)
- (void)getCharactersByTeam:(FSTeam *)team
			 withComplition:(nullable void(^)(NSError * _Nullable error))complition;
//
////send request for character by name
- (void)getCharacterByName:(NSString *)name
			withComplition:(nullable void(^)(NSError * _Nullable error))complition;
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
