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

- (void)addParsingForEntityForName:(NSString *)entityName
				withIdentification:(nullable NSArray *)attributes
					 relationships:(nullable NSDictionary *)relationships
						parameters:(NSDictionary *)params;

// Parameters - NSDictionary with
// key   - key in Dictionary with Data
// value - attributes (properties) of ManagedObject for entity with name: entityName
//
// Identification attributes - attributes (properties) of ManagedObject which define it uniqueness
//
// Relationships - NSDictionary with
// key   - attributes (properties) of ManagedObject
// value - name of entity to which ManagedObject has relationship

- (void)removeParsingForEntity:(NSString *)entityName;

- (NSArray *)parseData:(NSArray *)data
		 forEntityName:(NSString *)entityName
		updateExisting:(BOOL)update;

@end

NS_ASSUME_NONNULL_END