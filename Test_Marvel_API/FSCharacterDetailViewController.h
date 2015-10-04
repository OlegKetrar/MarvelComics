//
//  FSCharacterDetailViewController.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 22.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

@import UIKit;

#import "FSBaseViewController.h"

@class FSCharacter;

@interface FSCharacterDetailViewController : FSBaseViewController

@property (nonatomic) FSCharacter *character;

@end
