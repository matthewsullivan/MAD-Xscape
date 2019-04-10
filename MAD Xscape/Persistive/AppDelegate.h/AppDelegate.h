//
//  AppDelegate.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;

- (void) askPermisionForRemoteNotifications;
- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;


@end

