//
//  FSComicViewController.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 01.10.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBaseViewController.h"

@class FSComic;

@interface FSComicDetailViewController : FSBaseViewController

@property (nonatomic) FSComic *comic;

@end
