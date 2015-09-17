//
//  FSCharacter.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSBaseEntity.h"

@class FSComic, FSTeam;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kFSImageVariationsPortraitSmall;
extern NSString *const kFSImageVariationsPortraitMedium;
extern NSString *const kFSImageVariationsPortraitXlarge;
extern NSString *const kFSImageVariationsPortraitFantastic;
extern NSString *const kFSImageVariationsPortraitUncanny;
extern NSString *const kFSImageVariationsPortraitIncredible;

extern NSString *const kFSImageVariationsDetail;
extern NSString *const kFSImageVariationsStandardMedium;
extern NSString *const kFSImageVariationsStandardXlarge;

@interface FSCharacter : FSBaseEntity

- (NSString *)imageUrlWithVariaton:(NSString *)variation;

@end

NS_ASSUME_NONNULL_END

#import "FSCharacter+CoreDataProperties.h"
