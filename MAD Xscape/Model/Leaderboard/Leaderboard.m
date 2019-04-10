//
//  Leaderboard.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Leaderboard.h"

@implementation Leaderboard

- (id)initWithTitle :(NSString *)name
             TeamID:(NSNumber *)teamID
             Result:(NSString *)result
             Rating:(NSNumber *)place{
    
    self = [super init];
    
    if (self) {
        _name = name;
        _teamID = teamID;
        _result = result;
        _place = place;
    }
    
    return self;
}

@end
