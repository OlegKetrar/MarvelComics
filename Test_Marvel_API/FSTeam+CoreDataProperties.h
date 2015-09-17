//
//  FSTeam+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "FSTeam.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTeam (CoreDataProperties)

@property (nonatomic, retain) NSSet<FSCharacter *> *characters;

@end

@interface FSTeam (CoreDataGeneratedAccessors)

- (void)addCharactersObject:(FSCharacter *)value;
- (void)removeCharactersObject:(FSCharacter *)value;
- (void)addCharacters:(NSSet<FSCharacter *> *)values;
- (void)removeCharacters:(NSSet<FSCharacter *> *)values;

@end

NS_ASSUME_NONNULL_END
