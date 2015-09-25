//
//  FSImageDetailViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 25.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSImageDetailViewController.h"
#import "FSDataManager.h"

@interface FSImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation FSImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.imageUrl == nil) {
		NSLog(@"error: FSImageDetailViewController, imageURL is nil");
		return;
	}
	
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:self.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 self.imageView.image = image;
										 [self.activityIndicator stopAnimating];
									 }];
}

@end
