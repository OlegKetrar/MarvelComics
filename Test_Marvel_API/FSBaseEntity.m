//
//  FSBaseEntity.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSBaseEntity.h"
#import "FSThumbnailImage.h"

@implementation FSBaseEntity

- (NSString *)imageUrl {
	return [self.thumbnail.path stringByAppendingFormat:@".%@", self.thumbnail.extension];
}

@end
