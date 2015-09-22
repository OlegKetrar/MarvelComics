//
//  FSCharacterDetailViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 22.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSCharacterDetailViewController.h"

#import "FSDataManager.h"

#import "FSCharacter.h"

@interface FSCharacterDetailViewController ()

@end

@implementation FSCharacterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = self.character.name;
	self.charIdLabel.text = self.character.id.stringValue;
	
		//wrapped text view
		//TODO: rewrite it with CoreText
	CGRect rect = self.backgroundView.frame;
	rect.origin.y -= self.descriptionView.frame.origin.y + 15.f;
	
	UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:rect];
	self.descriptionView.textContainer.exclusionPaths = @[imgRect];
	self.descriptionView.text = self.character.text;
	self.descriptionView.font = [UIFont systemFontOfSize:18.f];
	
	self.backgroundView.layer.cornerRadius = 10;
	
		//load image
		//TODO: cache image data, do not save to CoreData
		//TODO: add animation when image appear
	NSString *urlString = [self.character imageUrlWithVariaton:kFSImageVariationsPortraitIncredible];
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:urlString]
									 withComplition:^(UIImage * _Nullable image) {
										 if (image) {
											 self.imageView.image = image;
											 [self.indicator stopAnimating];
										 }
									 }];
}

@end
