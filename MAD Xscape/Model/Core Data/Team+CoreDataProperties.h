//
//  Team+CoreDataProperties.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Team+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Team (CoreDataProperties)

+ (NSFetchRequest<Team *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *date;
@property (nonatomic) int16_t day;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *time;
@property (nullable, nonatomic, copy) NSString *countDown;
@property (nullable, nonatomic, copy) NSString *access;
@property (nullable, nonatomic, retain) NSSet<Member *> *members;

@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Member *)value;
- (void)removeMembersObject:(Member *)value;
- (void)addMembers:(NSSet<Member *> *)values;
- (void)removeMembers:(NSSet<Member *> *)values;

@end

NS_ASSUME_NONNULL_END
