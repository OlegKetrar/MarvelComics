//
//  FSCharacter.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharacter.h"
#import "FSComic.h"
#import "FSTeam.h"

#import "FSThumbnailImage.h"

NSString *const kFSImageVariationsPortraitSmall = @"portrait_small";
NSString *const kFSImageVariationsPortraitMedium = @"portrait_medium";
NSString *const kFSImageVariationsPortraitXlarge = @"portrait_xlarge";
NSString *const kFSImageVariationsPortraitFantastic = @"portrait_fantastic";
NSString *const kFSImageVariationsPortraitUncanny = @"portrait_uncanny";
NSString *const kFSImageVariationsPortraitIncredible = @"portrait_incredible";

NSString *const kFSImageVariationsDetail = @"detail";
NSString *const kFSImageVariationsStandardMedium = @"standard_medium";
NSString *const kFSImageVariationsStandardXlarge = @"standard_xlarge";

@implementation FSCharacter

- (NSString *)imageUrlWithVariaton:(NSString *)variation {
	return [self.thumbnail.path stringByAppendingFormat:@"/%@.%@", variation, self.thumbnail.extension];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"\n{\n\tid: %@\n\tname: %@\n\tdescription: %@\n\tthumbnail: %@\n}",
			self.id, self.name, self.text, self.thumbnail];
}

@end
