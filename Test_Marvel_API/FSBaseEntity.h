//
//  FSBaseEntity.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import CoreData;
@class FSThumbnailImage;

NS_ASSUME_NONNULL_BEGIN

@interface FSBaseEntity : NSManagedObject

- (nullable NSString *)imageUrl;
- (void)configureWithResponse:(NSDictionary *)response;
@end

NS_ASSUME_NONNULL_END

#import "FSBaseEntity+CoreDataProperties.h"
