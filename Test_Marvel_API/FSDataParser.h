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

+ (instancetype)parserWithManagedObjectContext:(NSManagedObjectContext *)context;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addParsingForEntity:(NSString *)entityName
			 identification:(NSArray *)attributes
				 parameters:(NSDictionary *)params;

- (void)removeParsingForEntity:(NSString *)entityName;

- (void)parseData:(NSArray *)data
	forEntityName:(NSString *)entityName
   withComplition:(nullable void(^)(NSArray <__kindof NSManagedObject *> * _Nullable results))complition;

@end

NS_ASSUME_NONNULL_END