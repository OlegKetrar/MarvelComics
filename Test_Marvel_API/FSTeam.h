//
//  FSTeam.h
//  Test_Marvel_API
//
//  Created by Oleg Ketrar on 17.09.15.
//  Copyright © 2015 Oleg Ketrar. All rights reserved.
//

#import "FSBaseEntity.h"

@class FSCharacter;

NS_ASSUME_NONNULL_BEGIN

@interface FSTeam : FSBaseEntity

@property (nonatomic) NSArray <NSString *> *charactersNames;

@end

NS_ASSUME_NONNULL_END

#import "FSTeam+CoreDataProperties.h"
