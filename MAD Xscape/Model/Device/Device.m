//
//  Device.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-09-21.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//


#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Device.h"
#import "PhoneDevice+CoreDataProperties.h"

@implementation Device

+ (void)setNewDevice{
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];

    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSFetchRequest *fetchUser = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortUser = [NSSortDescriptor sortDescriptorWithKey:@"token" ascending:YES];
    [fetchUser setSortDescriptors:@[sortUser]];
    
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"PhoneDevice"
                                                  inManagedObjectContext:context];
    [fetchUser setEntity:userEntity];
    
    NSArray *userInformation = [[NSArray alloc] init];
    userInformation = [[context executeFetchRequest:fetchUser error:nil] mutableCopy];
    
    if (userInformation.count == 0) {
        PhoneDevice *device =  (PhoneDevice *)[NSEntityDescription
                               insertNewObjectForEntityForName:@"PhoneDevice"
                               inManagedObjectContext:context];
        device.token = @"";
    }
}

+ (void)userDeviceToken :(NSString *)token{
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    PhoneDevice *phone = [[Device currentDeviceInformation] firstObject];
    phone.token = token;
}

+ (NSArray *)currentDeviceInformation{
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSArray *userInformation = [[NSArray alloc] init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhoneDevice"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    userInformation = [context executeFetchRequest:fetchRequest error:nil];
    
    return userInformation;
}

@end
