//
//  FSThumbnailImage.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSThumbnailImage.h"
#import "FSBaseEntity.h"
#import "FSComic.h"

@implementation FSThumbnailImage

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@.%@", self.path, self.extension];
}

@end
