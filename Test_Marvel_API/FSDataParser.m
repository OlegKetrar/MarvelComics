//
//  FSDataParser.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 21.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSDataParser.h"
@import CoreData;

@interface FSDataParser ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSMutableDictionary *parsingParams;
@property (nonatomic) NSMutableDictionary *identificationAttributes;

@property (nonatomic) NSError *parseError;

@end

@implementation FSDataParser

+ (instancetype)parserWithManagedObjectContext:(NSManagedObjectContext *)context {
	return [[self alloc] initWithManagedObjectContext:context];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context {

	self = [super init];
	if (self) {
		self.managedObjectContext = context;
		self.parsingParams = [NSMutableDictionary dictionary];
		self.identificationAttributes = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)addParsingForEntity:(NSString *)entityName
			 identification:(NSArray *)attributes
				 parameters:(NSDictionary *)params {
	
	NSDictionary *existingParsing = [self.parsingParams objectForKey:entityName];
	NSArray *existingAttributes = [self.identificationAttributes objectForKey:entityName];
	
	if (existingParsing) {
		if ( ![existingParsing isEqualToDictionary:params] ) {
			[self.parsingParams removeObjectForKey:entityName];
		}
	}
	
	if (existingAttributes) {
		if ( ![existingAttributes isEqualToArray:attributes]) {
			[self.identificationAttributes removeObjectForKey:entityName];
		}
	}
	
	[self.parsingParams setObject:params forKey:entityName];
	[self.identificationAttributes setObject:attributes forKey:entityName];
}

- (void)removeParsingForEntity:(NSString *)entityName {
	[self.parsingParams removeObjectForKey:entityName];
	[self.identificationAttributes removeObjectForKey:entityName];
}

- (void)parseData:(NSArray *)data
	forEntityName:(NSString *)entityName
   withComplition:(nullable void(^)(NSArray <__kindof NSManagedObject *> * _Nullable results))complition {
	
	if (self.parseError) {
		self.parseError = nil;
	}
	
	NSMutableArray *objects = [NSMutableArray array];
	
	for (NSDictionary *dictionary in data) {
		NSManagedObject *parsedObject = [self objectForEntityForName:entityName withDictionary:dictionary];
		
		if ([self validateObject:parsedObject forEntityName:entityName]) {
			[self.managedObjectContext insertObject:parsedObject];
			[objects addObject:parsedObject];
		}
	}
	
//	[self.managedObjectContext save:nil];
	
	if (self.parseError) {
		return;
	}
	
	if (complition) {
		complition(objects);
	}
}

- (NSManagedObject *)objectForEntityForName:(NSString *)entityName
							 withDictionary:(NSDictionary *)dictionary {
	
	if (self.parseError) {
		return nil;
	}
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
														 inManagedObjectContext:self.managedObjectContext];
	
	NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:entity
											  insertIntoManagedObjectContext:nil];
	
		//TODO: handle error if parsing for entity is not exist
		//TODO: handle error if dictionary is nil
	NSDictionary *currentParsing = [self.parsingParams objectForKey:entityName];
	
	if ( currentParsing == nil ) {
		self.parseError = [[NSError alloc] initWithDomain:@"empty parsing" code:0 userInfo:nil];
		return nil;
	}
	
	if ( dictionary == nil ) {
		self.parseError = [[NSError alloc] initWithDomain:@"empty data" code:1 userInfo:nil];
		return nil;
	}
	
		//TODO: validate dictionary (may content NSNull values)
	NSMutableDictionary *currentObject = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	for (NSString *key in [currentObject allKeys]) {
		if ([[currentObject valueForKey:key] isKindOfClass:[NSNull class]])
			[currentObject removeObjectForKey:key];
	}
	
		//TODO: add more flexible relationships parsing
	NSArray <NSString *> *keysToParse = [currentParsing allKeys];
	for (NSString *key in keysToParse) {
		id value = [currentObject valueForKey:key];
	
			// setup relationship (1 to 1)
		if ([value isKindOfClass:[NSDictionary class]]) {
			[managedObject setValue:[self objectForEntityForName:[currentParsing valueForKey:key] withDictionary:value]
							 forKey:key];
		}
			// setup relationship (1 to many)
		else if ([value isKindOfClass:[NSArray class]]) {
//			NSSet *set = [managedObject valueForKey:key];
//			
//			if (!set) {
//				set = [NSSet set]
//			}
		}
			// setup normal property
		else
			[managedObject setValue:value forKey:[currentParsing valueForKey:key]];
	}
	
 	return managedObject;
}

- (BOOL)validateObject:(NSManagedObject *)object forEntityName:(NSString *)entityName {
	
	if (self.parseError) {
		return NO;
	}
	
	NSArray *properties = [self.identificationAttributes objectForKey:entityName];
	NSString *predicateString = [NSString string];
	
	for (NSString *someProperty in properties) {
		id propertyValue = [object valueForKey:someProperty];
		predicateString = [predicateString stringByAppendingFormat:@"%@ = %@", someProperty, propertyValue];
		
		if ( ![someProperty isEqual:[properties lastObject]]) {
			predicateString = [predicateString stringByAppendingString:@" AND "];
		}
	}
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.propertiesToFetch = properties;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	request.predicate = predicate;
	
	if ([self.managedObjectContext countForFetchRequest:request error:nil])
		return NO;
	else
		return YES;
}

@end
