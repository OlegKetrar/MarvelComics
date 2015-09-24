//
//  AppDelegate.m
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "AppDelegate.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "FSDataManager.h"

@import CoreData;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	[FSDataManager sharedManager].logEnabled = NO;

	return YES;
}

@end
