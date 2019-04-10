//
//  Members.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Members : NSObject

@property (nonatomic, strong) NSNumber *arrived;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *selected;
@property (nonatomic, strong) NSNumber *type;

- (id)initWithTitle :(NSString *)name
             MemberID:(NSNumber *)memberID
             Email:(NSString *)email
             Phone:(NSString *)phone
               Type:(NSNumber *)type
            Arrived:(NSNumber *)arrived
           Selected:(NSString *)selected;

@end
