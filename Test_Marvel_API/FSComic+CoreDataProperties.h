//
//  FSComic+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 04.10.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FSComic.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSComic (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<FSCharacter *> *characters;
@property (nullable, nonatomic, retain) NSSet<FSThumbnailImage *> *images;
@property (nullable, nonatomic, retain) NSSet<FSCreator *> *creators;

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

- (void)addCreatorsObject:(FSCreator *)value;
- (void)removeCreatorsObject:(FSCreator *)value;
- (void)addCreators:(NSSet<FSCreator *> *)values;
- (void)removeCreators:(NSSet<FSCreator *> *)values;

@end

NS_ASSUME_NONNULL_END
