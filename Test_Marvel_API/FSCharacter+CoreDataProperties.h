//
//  FSCharacter+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "FSCharacter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCharacter (CoreDataProperties)

@property (nullable, nonatomic, retain) FSTeam *team;
@property (nullable, nonatomic, retain) NSSet<FSComic *> *comics;

@end

@interface FSCharacter (CoreDataGeneratedAccessors)

- (void)addComicsObject:(FSComic *)value;
- (void)removeComicsObject:(FSComic *)value;
- (void)addComics:(NSSet<FSComic *> *)values;
- (void)removeComics:(NSSet<FSComic *> *)values;

@end

NS_ASSUME_NONNULL_END
