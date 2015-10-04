//
//  FSCreator+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 04.10.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FSCreator.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCreator (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *role;
@property (nullable, nonatomic, retain) NSSet<FSComic *> *writtenComics;

@end

@interface FSCreator (CoreDataGeneratedAccessors)

- (void)addWrittenComicsObject:(FSComic *)value;
- (void)removeWrittenComicsObject:(FSComic *)value;
- (void)addWrittenComics:(NSSet<FSComic *> *)values;
- (void)removeWrittenComics:(NSSet<FSComic *> *)values;

@end

NS_ASSUME_NONNULL_END
