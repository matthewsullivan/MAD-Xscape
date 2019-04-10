//
//  Members.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "Members.h"

@implementation Members

- (id)initWithTitle :(NSString *)name
           MemberID:(NSNumber *)memberID
              Email:(NSString *)email
              Phone:(NSString *)phone
               Type:(NSNumber *)type
            Arrived:(NSNumber *)arrived
           Selected:(NSString *)selected
{
    
    
    self = [super init];
    
    if (self) {
        _name = name;
        _memberID = memberID;
        _email = email;
        _phone = phone;
        _type = type;
        _arrived = arrived;
        _selected = selected;
    }

    return self;
}

@end
