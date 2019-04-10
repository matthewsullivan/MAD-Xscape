//
//  PhoneDevice+CoreDataProperties.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-09-21.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "PhoneDevice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PhoneDevice (CoreDataProperties)

+ (NSFetchRequest<PhoneDevice *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
