//
//  ServiceConnect.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//


#import "Device.h"
#import "PhoneDevice+CoreDataProperties.h"
#import "ServiceConnect.h"

@implementation ServiceConnect

#define APNSConnect @"http://madxscape.ca/app/services/apns_registration.php"
#define Leaderboard @"http://madxscape.ca/app/services/get_team_result.php?my_hash="
#define CheckIn @"http://madxscape.ca/app/services/arrived.php"
#define Members @"http://madxscape.ca/app/services/get_team.php"


/*
 All we need to do is call our startServiceConnection method, pass it a unique service key (int) -
 and the string we want to post to the web service.
 We then sort through what request should be made (some are slightly different).
 */
+ (void)startServiceConnection:(int)serviceKey :(NSString *)post andCallback:(void (^)(NSDictionary *))callback{
    
    NSMutableData *responseData;
    NSMutableURLRequest *request;
    
    switch (serviceKey) {
        case 0: {
            responseData = [NSMutableData data];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:Members]];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:post forHTTPHeaderField:@"METHOD"];
            
            NSString *userInput = post;
            
            post = [NSString stringWithFormat:@"xscape=%@", post];
            
            NSData *data = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:data];
            [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
        
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *cloudConnection = [session dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                 NSError *error) {
                                                         if (!error && data) {
                                                             NSError *error = nil;
                                                             
                                                             NSDictionary *responseData = [[NSMutableDictionary alloc] init];
                                                             
                                                             responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:0
                                                                                                              error:&error];
                                                             
                                                             NSMutableDictionary *credentialDataPacket = [responseData mutableCopy];
                                                             
                                                             [credentialDataPacket setObject:userInput forKey:@"access"];
                                                             [credentialDataPacket setObject:responseData forKey:@"response"];
                                                             
                                                            /*
                                                             * Pass back a copy because our callback is looking for an immutable dictionary
                                                             * not a mutable one.
                                                             */
                                                             callback([credentialDataPacket  copy]);
                                                         }
                                                     }];
            [cloudConnection resume];
            
            break;
            
        } case 1: {
            responseData = [NSMutableData data];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:Leaderboard]];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:post forHTTPHeaderField:@"METHOD"];
            
            NSData *data = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:data];
            [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *cloudConnection = [session dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         
                                                         if (!error && data) {
                                                             NSError *error = nil;
                                                             
                                                             NSDictionary *responseData = [[NSDictionary alloc] init];
                                                             
                                                             responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:0
                                                                                                            error:&error];
                                                             
                                                             responseData = [responseData valueForKey:@"results"];

                                                            callback(responseData);
                                                         }
                                                     }];
            [cloudConnection resume];
            
            break;
            
        } case 2: {
            responseData = [NSMutableData data];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:CheckIn]];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:post forHTTPHeaderField:@"METHOD"];
            
            post = [NSString stringWithFormat:@"xscape=%@", post];
            
            NSData *data = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:data];
            
            [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
                        
            NSURLSession *session = [NSURLSession sharedSession];
            
            NSURLSessionDataTask *cloudConnection = [session dataTaskWithRequest:request
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if (!error && data) {
                                                             NSError *error = nil;
                                                             
                                                             NSDictionary *responseData = [[NSDictionary alloc] init];
                                                             
                                                             responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:0
                                                                                                              error:&error];
                                                             
                                                             responseData = [responseData valueForKey:@"results"];
                                                             
                                                             callback(responseData);
                                                         }
                                                     }];
            [cloudConnection resume];
            
            break;
            
        } case 3: {
            responseData = [NSMutableData data];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:APNSConnect]];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:post forHTTPHeaderField:@"METHOD"];
            
            PhoneDevice *device = [[Device currentDeviceInformation] firstObject];
     
            post = [NSString stringWithFormat:@"xscape=%@&token=%@", post, device.token];
            
            NSData *data = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:data];
            
            [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
        
            NSURLSession *session = [NSURLSession sharedSession];
            
            NSURLSessionDataTask *cloudConnection = [session dataTaskWithRequest:request
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                   if (!error && data) {
                                                                       NSError *error = nil;
                                                                       
                                                                       NSDictionary *responseData = [[NSDictionary alloc] init];
                                                                       
                                                                       responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                      options:0
                                                                                                                        error:&error];
                                                                       
                                                                       responseData = [responseData valueForKey:@"results"];
                                                                       
                                                                       callback(responseData);
                                                                   }
                                                               }];
            [cloudConnection resume];
            
            break;
            
        }  default: {
            
            break;
        }
    }
}

@end
