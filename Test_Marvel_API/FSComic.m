//
//  FSComic.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSComic.h"
#import "FSCharacter.h"
#import "FSThumbnailImage.h"

@implementation FSComic

- (void)configureWithResponse:(NSDictionary *)response {
	self.id = [response objectForKey:@"id"];
	self.name = [response objectForKey:@"title"];
	self.text = [response objectForKey:@"description"];
}

@end
