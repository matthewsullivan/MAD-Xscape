//
//  Leaderboard.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Leaderboard : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *place;
@property (nonatomic, strong) NSNumber *teamID;
@property (nonatomic, strong) NSString *result;

- (id)initWithTitle :(NSString *)name
              TeamID:(NSNumber *)teamID
        Result:(NSString *)result
             Rating:(NSNumber *)place;


@end
