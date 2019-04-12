//
//  MADTeam.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-26.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//


#import "AppDelegate.h"
#import "Member+CoreDataProperties.h"
#import "Teams.h"
#import "Team+CoreDataProperties.h"

@implementation Teams

+ (BOOL)isTeamSaved {
    BOOL teamObject = false;
    
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSFetchRequest *fetchTeam = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortTeam = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchTeam setSortDescriptors:@[sortTeam]];
    
    NSEntityDescription *teamEntity = [NSEntityDescription entityForName:@"Team"
                                                  inManagedObjectContext:context];
    [fetchTeam setEntity:teamEntity];
    
    NSArray *teamInformation = [[NSArray alloc] init];
    teamInformation = [[context executeFetchRequest:fetchTeam error:nil] mutableCopy];
    
    if (teamInformation.count == 0) {
        teamObject = false;
    } else {
        teamObject = true;
    }
    
    return teamObject;
}

+ (BOOL)addedTeamSuccessfully :(NSDictionary *)teams {
    BOOL added = false;
    
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    Team *team = (Team *)[NSEntityDescription
                         insertNewObjectForEntityForName:@"Team"
                         inManagedObjectContext:context];

    NSString *access = [teams objectForKey:@"access"];
    
    team.access = access;
    
    for (id data in [[teams objectForKey:@"response"] objectForKey:@"results"]) {
        NSString *teamName = [data objectForKey:@"name"];
        NSString *time = [data objectForKey:@"time"];
        NSString *date = [data objectForKey:@"date"];
        NSString *countDown = [data objectForKey:@"count_down"];
        int day = [[data objectForKey:@"day"] intValue];
    
        team.name = teamName;
        team.day = day;
        team.time = time;
        team.date = date;
        team.countDown = countDown;
    
        for (id members in [data objectForKey:@"members"]) {
            Member *member = (Member *)[NSEntityDescription
                                    insertNewObjectForEntityForName:@"Member"
                                    inManagedObjectContext:context];
            
            int memberId = [[members objectForKey:@"id"] intValue];
            NSString *name = [members objectForKey:@"name"];
            NSString *email = [members objectForKey:@"email"];
            int type = [[members objectForKey:@"type"] intValue];
            BOOL selected = [[members objectForKey:@"selected"] boolValue];
            
            member.memberID = memberId;
            member.name =  name;
            member.email = email;
            member.type = type;
            member.selected = selected;
            
            [team addMembersObject:member];
        }
    }

    NSError *error = nil;
    
    if (![context save:&error]) {
        added = false;
    }else{
        added = true;
    }
    
    return added;
}

+ (Team *)currentRegisteredTeam {
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSFetchRequest *fetchTeam = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortTeam = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchTeam setSortDescriptors:@[sortTeam]];
    
    NSEntityDescription *teamEntity = [NSEntityDescription entityForName:@"Team"
                                                  inManagedObjectContext:context];
    [fetchTeam setEntity:teamEntity];
    
    NSArray *team = [[NSArray alloc] init];
    team = [[context executeFetchRequest:fetchTeam error:nil] mutableCopy];
    
    return [team firstObject];
}

+ (void)removeUserInformation {
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Team *currentTeam = [fetchedObjects objectAtIndex:0];
    
    [context deleteObject:currentTeam];
    
    error = nil;
    
    [context save:&error];
}

@end
