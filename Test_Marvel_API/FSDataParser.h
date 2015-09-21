//
//  FSDataParser.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 21.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import Foundation;

@class NSManagedObjectContext, NSManagedObject;

NS_ASSUME_NONNULL_BEGIN

@interface FSDataParser : NSObject

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addParsingForEntity:(NSString *)entityName
				 parameters:(NSDictionary *)params
			 identification:(NSArray *)attributes;

- (void)removeParsingForEntity:(NSString *)entityName;

- (void)parseData:(NSArray *)data
	forEntityName:(NSString *)entityName
   withComplition:(nullable void(^)(NSArray <NSManagedObject *> * _Nullable results))complition;

@end

NS_ASSUME_NONNULL_END