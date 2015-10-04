//
//  FSThumbnailImage+CoreDataProperties.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "FSThumbnailImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSThumbnailImage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *extension;

@property (nullable, nonatomic, retain) FSComic *imageOwner;
@property (nullable, nonatomic, retain) FSBaseEntity *thumbnailOwner;

@end

NS_ASSUME_NONNULL_END
