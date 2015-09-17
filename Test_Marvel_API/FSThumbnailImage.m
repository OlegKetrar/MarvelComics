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

// Insert code here to add functionality to your managed object subclass

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@.%@", self.path, self.extension];
}

@end
