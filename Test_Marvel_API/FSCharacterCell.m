//
//  FSCharacterCell.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 18.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharacterCell.h"

@implementation FSCharacterCell

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
	
	// TODO: create placeholder if image == nil
	// or DataManager should it do?
	if (image) {
		[self.indicator stopAnimating];
		self.imageView.image = image;
	}
}

- (void)prepareForReuse {
	self.imageView.image = nil;
	[self.indicator startAnimating];
}

@end
