//
//  LogOutVC.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-09-20.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "LogOutVC.h"
#import "Constants.h"
#import "Teams.h"

@interface LogOutVC ()

@end

@implementation LogOutVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    /**
     *  Remove the team and user information, then progrmatically change back to the MembersVC  which will force a re-login.
     *
     *  A new login will repopulate CoreData.
     *
     */
    [Teams removeUserInformation];
    
    [self.tabBarController setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
