//
//  FSDataParser.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 21.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSDataParser.h"
@import CoreData;

// TODO: subclass of NSOperation, child managedObjectContext

@interface FSDataParser ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableDictionary *parsingParams;
@property (nonatomic) NSMutableDictionary *relationsParams;
@property (nonatomic) NSMutableDictionary *identificationParams;

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
		self.identificationParams = [NSMutableDictionary dictionary];
		self.relationsParams = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)removeParsingForEntity:(NSString *)entityName {
	[self.parsingParams removeObjectForKey:entityName];
	[self.identificationParams removeObjectForKey:entityName];
	[self.relationsParams removeObjectForKey:entityName];
}

- (void)addParsingForEntityForName:(NSString *)entityName
				withIdentification:(nullable NSArray *)attributes
					 relationships:(nullable NSDictionary *)relationships
						parameters:(NSDictionary *)params {
	
	NSDictionary *existingParsing = [self.parsingParams objectForKey:entityName];
	NSArray *existingAttributes = [self.identificationParams objectForKey:entityName];
	NSDictionary *existingRelation = [self.relationsParams objectForKey:entityName];
	
	if (existingParsing) {
		[self.parsingParams removeObjectForKey:entityName];
	}
	
	if (existingAttributes) {
		[self.identificationParams removeObjectForKey:entityName];
	}
	
	if (existingRelation) {
		[self.relationsParams removeObjectForKey:entityName];
	}
	
	[self.parsingParams setObject:params forKey:entityName];
	
	if (attributes) {
		[self.identificationParams setObject:attributes forKey:entityName];
	}
	
	if (relationships) {
		[self.relationsParams setObject:relationships forKey:entityName];
	}
}

- (NSArray *)parseData:(NSArray *)data
		 forEntityName:(NSString *)entityName
		updateExisting:(BOOL)update {
	
	NSMutableArray *results = [NSMutableArray array];
	
	for (NSDictionary *dictionary in data) {
		NSManagedObject *managedObject = [self parseEntityForName:entityName
														 withData:dictionary
												   updateExisting:update];
		
		if (managedObject) {
			[results addObject:managedObject];
		}
	}
	
	return results;
}

- (nullable NSManagedObject *)parseEntityForName:(NSString *)entityName
										withData:(NSDictionary *)data
								  updateExisting:(BOOL)update {
	
	NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
																   inManagedObjectContext:self.managedObjectContext];
	
	NSDictionary *currentParsing = [self.parsingParams objectForKey:entityName];
	NSDictionary *currentRelations = [self.relationsParams objectForKey:entityName];
	
	if (!data) {
		NSLog(@"FSDataParser: input data for entity %@ is empty", entityName);
		return nil;
	}
	
	if (!currentParsing) {
		NSLog(@"FSDataParser: parsing for entity %@ is empty", entityName);
		return nil;
	}
	
	//remove keys which contains NSNull values
	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:data];
	for (NSString *dataKey in [dataDictionary allKeys]) {
		if ([[dataDictionary valueForKey:dataKey] isKindOfClass:[NSNull class]])
			[dataDictionary removeObjectForKey:dataKey];
	}
	
	for (NSString *dataKey in [currentParsing allKeys]) {
		
		NSString *objectKey = [currentParsing valueForKeyPath:dataKey];
		NSString *relationEntity = [currentRelations valueForKeyPath:objectKey];
		
		id value = [dataDictionary valueForKeyPath:dataKey];
		
		if (relationEntity) { // parse like relationship
			
//			id relationProperty = [managedObject valueForKey:objectKey];
//			if ([relationProperty isKindOfClass:[NSSet class]] || [relationProperty isKindOfClass:[NSOrderedSet class]]) {
			
			if ([value isKindOfClass:[NSArray class]]) { // relationship "to many"
				
				NSArray *valueArray = value;
				for (id someValue in valueArray) {
					
					//TODO: may be NSOrderedSet
					NSMutableSet *propertySet = [managedObject mutableSetValueForKeyPath:objectKey];
					NSManagedObject *managedValue = [self parseEntityForName:relationEntity
																	withData:someValue
															  updateExisting:update];
					
					if (managedValue) {
						[propertySet addObject:managedValue];
					}
				}
			}
			else { // relationship "to one"
				NSManagedObject *managedValue = [self parseEntityForName:relationEntity
																withData:value
														  updateExisting:update];
				
				if (managedValue) {
					[managedObject setValue:managedValue forKeyPath:objectKey];
				}
			}
		}
		else { // parse like attribute
			[managedObject setValue:value forKeyPath:objectKey];
		}
	}
	
	return [self validateManagedObject:managedObject forName:entityName updateExisting:update];
}

- (nullable NSManagedObject *)validateManagedObject:(NSManagedObject *)insertedObject
											forName:(NSString *)entityName
									 updateExisting:(BOOL)update {
	
	NSArray <NSString *> *identificationAttributes = [self.identificationParams objectForKey:entityName];
	
	// if identification attributes are not set
	if (!identificationAttributes) {
		return insertedObject;
	}
	
	if (!insertedObject) {
		NSLog(@"entity %@", entityName);
		return nil;
	}
	
	// create predicate string to determine uniqueness of insertedObject by identification attributes
	NSString *predicateString = [NSString string];
	for (NSString *attribute in identificationAttributes) {
		id attributeValue = [insertedObject valueForKey:attribute];
		
		if ([attributeValue isKindOfClass:[NSString class]]) {
			attributeValue = [NSString stringWithFormat:@"'%@'", attributeValue];
		}
		
		predicateString = [predicateString stringByAppendingFormat:@"%@ == %@", attribute, attributeValue];
		
		if ( ![attribute isEqual:[identificationAttributes lastObject]]) {
			predicateString = [predicateString stringByAppendingString:@" AND "];
		}
	}
	
	// create fetch request with predicate
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.propertiesToFetch = identificationAttributes;
	request.predicate = [NSPredicate predicateWithFormat:predicateString];
	
	// looking for objects with the same attributes of identification
	if ([self.managedObjectContext countForFetchRequest:request error:nil] > 1) { //insertedObject is not unique
		
		NSManagedObject *originalObject = nil;
		
		if (update) { // find original object and update its attributes & relationships
		
			originalObject = [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
		
			[self updateManagedObject:originalObject
					withManagedObject:insertedObject
					 forEntityForName:entityName];
		}
		
		[self.managedObjectContext deleteObject:insertedObject];
		return originalObject;
	}
	else { // insertedObject is unique, return it
		return insertedObject;
	}
}

- (void)updateManagedObject:(NSManagedObject *)updateTo
		  withManagedObject:(NSManagedObject *)updateFrom
		   forEntityForName:(NSString *)entityName {
	
	// which attributes needs to update
	NSDictionary *currentParsing = [self.parsingParams objectForKey:entityName];
	NSArray <NSString *> *attributesToUpdate = [currentParsing allValues];
	
	for (NSString *attribute in attributesToUpdate) {
		
		id value = [updateFrom valueForKey:attribute];
		
		//relationship "to many"
		if ([value isKindOfClass:[NSSet class]]) { // set
			
			NSMutableSet *attributeSet = [updateTo mutableSetValueForKey:attribute];
			[attributeSet addObjectsFromArray:[[updateFrom valueForKey:attribute] allObjects]];
		}
		else if ([value isKindOfClass:[NSOrderedSet class]]) { // ordered set
			
			NSMutableOrderedSet *values = [updateTo mutableOrderedSetValueForKey:attribute];
			[values addObjectsFromArray:[[updateFrom valueForKey:attribute] array]];
		}
		else // attribute or relationship "to one"
			[updateTo setValue:value forKey:attribute];
	}
}

@end
