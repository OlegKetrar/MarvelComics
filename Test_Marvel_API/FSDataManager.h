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
- (void)getCharactersByTeam:(FSTeam *)team withComplition:(nullable void(^)(NSError * _Nullable error))complition;
- (void)getCharacterWithComplition:(nullable void(^)(NSError * _Nullable error))complition;

- (void)loadDataWithOffset:(NSInteger)offset
				   success:(nullable void(^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
				   failure:(nullable void(^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)loadDataWithComplition:(nullable void(^)(NSArray * _Nullable results, NSError * _Nullable error))complition;

@end

NS_ASSUME_NONNULL_END
