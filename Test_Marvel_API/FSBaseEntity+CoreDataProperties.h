//
//  FSBaseEntity+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "FSBaseEntity.h"

@class FSThumbnailImage;

NS_ASSUME_NONNULL_BEGIN

@interface FSBaseEntity (CoreDataProperties)

@property (nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *text;

@property (nullable, nonatomic, retain) FSThumbnailImage *thumbnail;

@end

NS_ASSUME_NONNULL_END
