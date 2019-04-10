//
//  Team+CoreDataProperties.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Team+CoreDataProperties.h"

@implementation Team (CoreDataProperties)

+ (NSFetchRequest<Team *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Team"];
}

@dynamic access;
@dynamic date;
@dynamic day;
@dynamic name;
@dynamic time;
@dynamic members;
@dynamic countDown;

@end
