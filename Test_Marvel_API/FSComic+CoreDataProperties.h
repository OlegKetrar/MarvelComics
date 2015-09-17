//
//  FSComic+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "FSComic.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSComic (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<FSCharacter *> *characters;
@property (nullable, nonatomic, retain) NSSet<FSThumbnailImage *> *images;

@end

@interface FSComic (CoreDataGeneratedAccessors)

- (void)addCharactersObject:(FSCharacter *)value;
- (void)removeCharactersObject:(FSCharacter *)value;
- (void)addCharacters:(NSSet<FSCharacter *> *)values;
- (void)removeCharacters:(NSSet<FSCharacter *> *)values;

- (void)addImagesObject:(FSThumbnailImage *)value;
- (void)removeImagesObject:(FSThumbnailImage *)value;
- (void)addImages:(NSSet<FSThumbnailImage *> *)values;
- (void)removeImages:(NSSet<FSThumbnailImage *> *)values;

@end

NS_ASSUME_NONNULL_END
