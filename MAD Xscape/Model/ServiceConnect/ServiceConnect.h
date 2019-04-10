//
//  ServiceConnect.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ServiceConnect : NSObject

/**
 * @class ServiceConnect
 *
 * @author Matthew Sullivan
 * @date 2015-10-30
 *
 * @version 1.1
 * @copyright Copyright © 2017 MAD DC. All rights reserved.
 *
 * Handling web service connection POST's & responses. Use for application web service requests.
 *
 */

/**
 * One instance method to rule them all. This is the start to determine which web service to communicate with.
 * This is more or less a switch controller that delegates what url's to call, and how to handle successful calls and failures.
 *
 * @param serviceKey An int that determines what url to POST to
 * @param post A string value of our POST to POST to our web service.
 */
+ (void)startServiceConnection :(int)serviceKey :(NSString *)post andCallback:(void (^)(NSDictionary *))callback;

@end
