//
//  FSImageDetailViewController.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 25.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSImageDetailViewController.h"
#import "FSDataManager.h"

#define FS_IMAGE_ZOOM_MAX 2.5

@interface FSImageDetailViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) UITapGestureRecognizer *toggleBarsGestureRecognizer;
@property (weak, nonatomic) UITapGestureRecognizer *toggleZoomGestureRecognizer;

@end

@implementation FSImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	
	if (self.imageUrl == nil) {
		NSLog(@"error: FSImageDetailViewController, imageURL is nil");
		return;
	}
	
		// create & set up scroll view
	UIScrollView *scrollView  = [[UIScrollView alloc] init];
	scrollView.delegate = self;
	scrollView.alwaysBounceVertical = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	
		//set up image view
	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.userInteractionEnabled = YES;
	
		//set up activity indicator view
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
										  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicatorView startAnimating];
	
		//set up gestures
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
																				action:@selector(toggleBars:)];
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
																				action:@selector(toggleZoom:)];
	doubleTap.numberOfTapsRequired = 2;
	[singleTap requireGestureRecognizerToFail:doubleTap];
	
	[imageView addGestureRecognizer:singleTap];
	[imageView addGestureRecognizer:doubleTap];
 
		// set up view hierarchy
	[self.view addSubview:scrollView];
	[scrollView addSubview:imageView];
	[scrollView addSubview:activityIndicatorView];
 
		// Set up constraints
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	imageView.translatesAutoresizingMaskIntoConstraints = NO;
	activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, imageView);
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
																	  options:0
																	  metrics:nil
																		views:viewsDictionary]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
																	  options:0
																	  metrics:nil
																		views:viewsDictionary]];
	
	[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
																	   options:0
																	   metrics:nil
																		 views:viewsDictionary]];
	
	[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
																	   options:0
																	   metrics:nil
																		 views:viewsDictionary]];
	
	[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicatorView
														   attribute:NSLayoutAttributeCenterX
														   relatedBy:NSLayoutRelationEqual
															  toItem:scrollView
														   attribute:NSLayoutAttributeCenterX
														  multiplier:1.0
															constant:0.0]];
	
	[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicatorView
														   attribute:NSLayoutAttributeCenterY
														   relatedBy:NSLayoutRelationEqual
															  toItem:scrollView
														   attribute:NSLayoutAttributeCenterY
														  multiplier:1.0
															constant:0.0]];
	self.scrollView = scrollView;
	self.imageView = imageView;
	self.activityIndicatorView = activityIndicatorView;
	
	self.toggleBarsGestureRecognizer = singleTap;
	self.toggleZoomGestureRecognizer = doubleTap;
	
	__weak FSImageDetailViewController *weakSelf = self;
	
	[[FSDataManager sharedManager] loadImageFromURL:[NSURL URLWithString:self.imageUrl]
									 withComplition:^(UIImage * _Nullable image) {
										 
										 if (image) {
											 [weakSelf.activityIndicatorView stopAnimating];
											 weakSelf.imageView.image = image;
											 [weakSelf scaleAndCenterContent];
										 }
									 }];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	if (self.imageView.image) {
		[self scaleAndCenterContent];
	}
}

- (void)scaleAndCenterContent {
	
	CGSize contentSize = self.imageView.image.size;
	CGSize viewSize = self.view.frame.size;
	
	CGFloat widthScale  = viewSize.width  / contentSize.width;
	CGFloat heightScale = viewSize.height / contentSize.height;
	CGFloat minScale = MIN(widthScale, heightScale);
	
	if (minScale > 1)
		minScale = 1;
	
	self.scrollView.minimumZoomScale = minScale;
	self.scrollView.maximumZoomScale = FS_IMAGE_ZOOM_MAX * minScale;
	self.scrollView.zoomScale = minScale;
	
	[self centerContent];
}

- (void)centerContent {
	
	CGSize contentSize = self.imageView.image.size;
	CGSize viewSize = self.view.frame.size;
	CGFloat scale = self.scrollView.zoomScale;
	
	CGFloat horizontalOffset = (viewSize.width - contentSize.width * scale) / 2.0;
	CGFloat verticalOffset = (viewSize.height - contentSize.height * scale) / 2.0;
	
	UIEdgeInsets insets = UIEdgeInsetsZero;
	
	if (verticalOffset > 0) {
		insets.top	  =   verticalOffset;
		insets.bottom = - verticalOffset;
	}
	
	if (horizontalOffset > 0) {
		insets.left   =   horizontalOffset;
		insets.right  = - horizontalOffset;
	}
	
	self.scrollView.contentInset = insets;
}

- (void)toggleZoom:(UITapGestureRecognizer *)gesture {
	
	CGFloat currentScale = self.scrollView.zoomScale;
	
	if (currentScale == self.scrollView.minimumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
	
	else
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
}

- (void)toggleBars:(UITapGestureRecognizer *)gesture {
	
	BOOL isHidden = [UIApplication sharedApplication].statusBarHidden;
	[UIApplication sharedApplication].statusBarHidden = !isHidden;
	
	isHidden = self.navigationController.navigationBar.hidden;
	[self.navigationController setNavigationBarHidden:!isHidden animated:YES];
	
	[self toggleTabBarAnimated];
}

- (void)toggleTabBarAnimated {
	
	self.toggleBarsGestureRecognizer.enabled = NO;
	
	// get a frame calculation ready
	CGRect frame = self.tabBarController.tabBar.frame;
	CGFloat height = frame.size.height;
	
	BOOL isHidden = self.tabBarController.tabBar.hidden;
	
	if (isHidden) { // to show
		
		frame = CGRectOffset(frame, 0, height);
		self.tabBarController.tabBar.frame = frame;
		
		[UIView animateWithDuration:0.33
							  delay:0.0
			 usingSpringWithDamping:0.5
			  initialSpringVelocity:1.0
							options:0
						 animations:^{
							 self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, -height);
						 }
						 completion:^(BOOL finished) {
							 self.tabBarController.tabBar.hidden = NO;
							 
							 self.toggleBarsGestureRecognizer.enabled = YES;
						 }];
	}
	else { // to hide
		
		[UIView animateWithDuration:0.33 animations:^{
			
			self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, height);
			
		} completion:^(BOOL finished) {
			self.tabBarController.tabBar.frame = frame;
			self.tabBarController.tabBar.hidden = YES;
			
			self.toggleBarsGestureRecognizer.enabled = YES;
		}];
	}
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self centerContent];
}

@end
