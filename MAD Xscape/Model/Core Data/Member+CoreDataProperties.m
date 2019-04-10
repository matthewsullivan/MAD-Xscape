//
//  Member+CoreDataProperties.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Member+CoreDataProperties.h"

@implementation Member (CoreDataProperties)

+ (NSFetchRequest<Member *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Member"];
}

@dynamic email;
@dynamic memberID;
@dynamic name;
@dynamic selected;
@dynamic type;
@dynamic team;

@end
