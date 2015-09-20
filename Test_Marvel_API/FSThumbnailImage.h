//
//  FSThumbnailImage.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import CoreData;
@class FSBaseEntity, FSComic;

NS_ASSUME_NONNULL_BEGIN

@interface FSThumbnailImage : NSManagedObject

- (void)configureWithResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END

#import "FSThumbnailImage+CoreDataProperties.h"
