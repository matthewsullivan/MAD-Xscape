//
//  Device.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-09-21.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Device : NSObject

+ (NSArray *)currentDeviceInformation;
+ (void)setNewDevice;
+ (void)userDeviceToken:(NSString *)token;

@end
