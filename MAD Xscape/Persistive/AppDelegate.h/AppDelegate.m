//
//  AppDelegate.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Device.h"
#import "Teams.h"
#import "ViewFX.h"

#import "ServiceConnect.h"

@interface AppDelegate ()

@property BOOL firstLoad;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Device setNewDevice];
    
    //Selected Tab Bar Item
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:(1.0)]];
    
    //Tab Bar Background Colour
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:(33/255.0) green:(33/255.0) blue:(33/255.0) alpha:(1.0)]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:12.0f]
                                                        } forState:UIControlStateNormal];
    
    
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:frame];
    
    statusBarBackground.backgroundColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(0.6)];
    statusBarBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [ViewFX applyDropShadowOn:statusBarBackground];

    [self.window.rootViewController.view addSubview:statusBarBackground];
    
    self.firstLoad = TRUE;
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
        [self askPermisionForRemoteNotifications];
    }else{
        [Device userDeviceToken:@""];
        
        [self startServiceApnsRegistration];
    }
    
    return YES;
}

- (void)askPermisionForRemoteNotifications {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound |
    UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [Device userDeviceToken:token];
    
    if(self.firstLoad){
        [self startServiceApnsRegistration];
    }
    
    self.firstLoad = FALSE;
}

- (void)startServiceApnsRegistration {
    Team *team = [Teams currentRegisteredTeam];
    
    [ServiceConnect startServiceConnection:3 :team.access andCallback:^(NSDictionary* result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(result.count > 0){
                for (id data in result) {
                    NSLog(@"Data %@", data);
                }
            }
        });
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //if a notification comes in while the app is open, we want to tell our server to reset the badge count to 0 again.
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground
        [self startServiceApnsRegistration];
    }
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [Device userDeviceToken:@""];
    
    [self startServiceApnsRegistration];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.so-media.CoreDataTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MadXModel" withExtension:@"momd"];

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MadXModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;

        error = [NSError errorWithDomain:@"xscape.mad.durhamcollege.ca" code:9999 userInfo:dict];
        
        NSLog(@"error! %@", [error localizedDescription]);
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        NSError *error = nil;

        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"error! %@", [error localizedDescription]);
        }
    }
}

@end
