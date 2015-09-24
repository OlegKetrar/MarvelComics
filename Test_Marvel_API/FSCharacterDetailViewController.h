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

@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel *charIdLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *relatedComicsLabel;

@property (nonatomic) FSCharacter *character;

@end
