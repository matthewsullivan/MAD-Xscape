//
//  Member+CoreDataProperties.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Member+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Member (CoreDataProperties)

+ (NSFetchRequest<Member *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *email;
@property (nonatomic) int16_t memberID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) BOOL selected;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, retain) Team *team;

@end

NS_ASSUME_NONNULL_END
