//
//  FSPageContainer.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 25.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSPageContainer.h"
#import "FSImageDetailViewController.h"

#define FS_CHILD_VC_ID @"imageDetailVC"

@interface FSPageContainer () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@end

@implementation FSPageContainer

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.imageURLs == nil) {
		NSLog(@"error: FSPageContainer, imageURLs = nil");
		return;
	}
	
	UIPageViewController *pageVC = [self.childViewControllers firstObject];
	pageVC.dataSource = self;
	pageVC.delegate = self;
	pageVC.view.backgroundColor = [UIColor blackColor];
	
	FSImageDetailViewController *firstVC = [self.storyboard instantiateViewControllerWithIdentifier:FS_CHILD_VC_ID];
	firstVC.imageUrl = [self.imageURLs firstObject];
	firstVC.index = 0;
	
	[pageVC setViewControllers:@[firstVC]
					 direction:UIPageViewControllerNavigationDirectionForward
					  animated:NO
					completion:nil];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
	  viewControllerBeforeViewController:(FSImageDetailViewController *)vc {
	
	if(self.imageURLs.count < 2)
		return nil;

	NSUInteger newIndex;
	
	if (vc.index > 0)
		newIndex = vc.index - 1;
	else
		newIndex = self.imageURLs.count - 1;
	
	FSImageDetailViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:FS_CHILD_VC_ID];
	newVC.imageUrl = [self.imageURLs objectAtIndex:newIndex];
	newVC.index = newIndex;
	
	return newVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
	   viewControllerAfterViewController:(FSImageDetailViewController *)vc {
	
	if(self.imageURLs.count < 2)
		return nil;

	NSUInteger newIndex;
	
	if (vc.index < self.imageURLs.count - 1)
		newIndex = vc.index + 1;
	else
		newIndex = 0;
	
	FSImageDetailViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:FS_CHILD_VC_ID];
	newVC.imageUrl = [self.imageURLs objectAtIndex:newIndex];
	newVC.index = newIndex;
	
	return newVC;
}

@end
