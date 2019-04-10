//
//  PhoneDevice+CoreDataProperties.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-09-21.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "PhoneDevice+CoreDataProperties.h"

@implementation PhoneDevice (CoreDataProperties)

+ (NSFetchRequest<PhoneDevice *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PhoneDevice"];
}

@dynamic token;

@end
