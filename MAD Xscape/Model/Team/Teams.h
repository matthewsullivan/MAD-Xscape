//
//  Teams.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//MAD Xscape Imports
#import "Team+CoreDataProperties.h"

@interface Teams : NSObject

+ (BOOL)addedTeamSuccessfully :(NSDictionary *)teams;
+ (Team *)currentRegisteredTeam;
+ (BOOL)isTeamSaved;
+ (void)removeUserInformation;

@end
