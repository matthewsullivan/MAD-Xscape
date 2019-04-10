//
//  CheckInVC.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

//MAD Xscape Imports
#import "AppDelegate.h"
#import "CheckInVC.h"
#import "CheckInCell.h"
#import "Constants.h"
#import "ViewFX.h"
#import "Teams.h"
#import "Team+CoreDataProperties.h"
#import "ServiceConnect.h"
#import "Members.h"
#import "BeaconRadar.h"
#import "AppDelegate.h"

//MAD Xscape Extensions
#import "UIScrollView+MSParallaxHeader.h"

@interface CheckInVC () <UITableViewDataSource,
                        UITableViewDelegate,
                        MSParallaxViewDelegate,
                        UIActionSheetDelegate>


@property (strong, nonatomic) BeaconRadar *beaconRadar;
@property (strong, nonatomic) UIButton *checkInButton;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) NSString *lastUpdate;
@property (strong, nonatomic) UILabel *lastUpdatedLabelView;
@property (strong, nonatomic) UIView *loaderView;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) IBOutlet UITableView *membersTable;
@property UIDeviceOrientation orientation;
@property (nonatomic, strong) UILabel *teamBookingTimeCountDown;

@end

@implementation CheckInVC

#pragma mark - Keep status bar even in landscape
- (BOOL)prefersStatusBarHidden {return NO;}

- (void)viewWillLayoutSubviews {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];

    if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        if(self.orientation != orientation){[self.beaconRadar layoutIfNeeded]; self.orientation = orientation;}
    } else if(orientation == UIDeviceOrientationPortrait) {
        if(self.orientation != orientation){[self.beaconRadar layoutIfNeeded]; self.orientation = orientation;}
    }
}

#pragma mark - View Controller Tear Down and Setup Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    /**
     * Members table configuration
     */
    self.membersTable.delegate = self;
    self.membersTable.dataSource = self;
    
    /**
     * Adjust Member table height to account for tab bar.
     */
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);

    self.membersTable.contentInset = adjustForTabbarInsets;
    self.membersTable.scrollIndicatorInsets = adjustForTabbarInsets;

    
    /**
     * Custom Table View Extensions  setup
     */
    self.membersTable.parallaxView.delegate = self;
    
    [self memberInformation];
    
    /**
     * Will eventually call custom leader object Alloc Init method.
     */
    self.members = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate askPermisionForRemoteNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if(self.beaconRadar){
        [self.beaconRadar stopRadar];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateTableCellInformation];
}

- (void)updateTableCellInformation{
    Team *team = [Teams currentRegisteredTeam];
    
    [ServiceConnect startServiceConnection:0 :team.access andCallback:^(NSDictionary* result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(result.count > 0){
                [self.members removeAllObjects];
                
                for (id data in [[result objectForKey:@"response"] objectForKey:@"results"]) {
                    for (id members in [data objectForKey:@"members"]) {
                        Members *member = [[Members alloc] initWithTitle:[members objectForKey:@"name"]
                                                                MemberID:[members objectForKey:@"id"]
                                                                   Email:[members objectForKey:@"email"]
                                                                   Phone:[members objectForKey:@"phone"]
                                                                    Type:[members objectForKey:@"type"]
                                                                 Arrived:[members objectForKey:@"arrived"]
                                                                Selected:[members objectForKey:@"selected"]];

                        NSString *checkInButtonTitle;
                        
                        if (member.selected.length > 0) {
                            if ([member.arrived intValue] == 1) {
                                checkInButtonTitle = NSLocalizedString(@"Checked In", @"Check In Button Title");
                                
                                [self.checkInButton setTitle:checkInButtonTitle forState:UIControlStateNormal];
                            } else {
                                checkInButtonTitle = NSLocalizedString(@"Check In", @"Check In Button Title");
                                
                                [self.checkInButton setTitle:checkInButtonTitle forState:UIControlStateNormal];
                            }
                        }
                        
                        [self.members addObject:member];
                    }
                }
            } else {
                NSString *noMembers = NSLocalizedString(@"No Team Members", @"No Team Table Cells");
                
                Members *members = [[Members alloc] initWithTitle:noMembers
                                                         MemberID:0
                                                            Email:@""
                                                            Phone:@""
                                                             Type:0
                                                          Arrived:0
                                                         Selected:@""];
                
                [self.members removeAllObjects];
                [self.members addObject:members];
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            
            [self.loaderView removeFromSuperview];
            
            self.lastUpdatedLabelView.frame = CGRectMake(18,
                                                         0,
                                                         (self.tableView.frame.size.width - 40),
                                                         50);
            
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSString *currentTime = [dateFormatter stringFromDate:today];
            
            self.lastUpdate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Last updated at", @"Last Updated"), currentTime];
            self.lastUpdatedLabelView.text = self.lastUpdate;
            
            [self.lastUpdatedLabelView reloadInputViews];
           
            [self.membersTable reloadData];
            
            NSMutableArray *membersCheckedIn = [[NSMutableArray alloc] init];
            
            for (Members *member in self.members) {
                if ([member.arrived intValue] == 1) {
                    [membersCheckedIn addObject:member];
                }
            }
            
            if (self.beaconRadar) {
                [self.beaconRadar stopRadar];
                [self.beaconRadar createTargets: (int)membersCheckedIn.count];
                [self.beaconRadar startRadar];
            }
        });
    }];
}

- (void)memberInformation{
    /**
     * leader Information View
     */
    UIView *proximityRadar = [[UIView alloc] initWithFrame: CGRectMake(0,
                                                                            0,
                                                                            self.view.bounds.size.width,
                                                                            340)];
    /**
     * leader Information View Background Image
     */
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maps"]];
    [backgroundImageView setFrame:proximityRadar.frame];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundImageView setFrame: CGRectMake(-20,
                                              -10,
                                              self.view.bounds.size.width + 40,
                                              380)];
    
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [proximityRadar addSubview:backgroundImageView];
    
    [ViewFX applyTiltEffectTo:proximityRadar];
    [ViewFX applyBlurEffectTo:backgroundImageView];
    
    self.beaconRadar = [[BeaconRadar alloc] init];
    [self.beaconRadar layoutRadarWindowWithFrame:proximityRadar];
    
    /*
     * Error Label setup
     */
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                            proximityRadar.frame.size.height / 2 + 80,
                                                            self.view.bounds.size.width,
                                                            40.0)];
    
    self.errorLabel.text = NSLocalizedString(@"", @"Early Check In Message");
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.font = [UIFont fontWithName:@"Roboto-Italic" size:12];
    self.errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    
    [proximityRadar addSubview:self.errorLabel];
    
    self.checkInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkInButton addTarget:self
               action:@selector(checkIn:)
     forControlEvents:UIControlEventTouchUpInside];
    
    NSString * checkInButtonTitle = NSLocalizedString(@"Check In", @"Check In Button Title");;

    self.checkInButton.frame = CGRectMake(proximityRadar.frame.size.width / 2 - 80,
                              proximityRadar.frame.size.height / 2 + 100,
                              160.0,
                              40.0);
    
    [self.checkInButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Medium" size:16]];
    [self.checkInButton setTitle:checkInButtonTitle forState:UIControlStateNormal];
    
    self.checkInButton.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                             green:(195/255.0)
                                              blue:(74/255.0)
                                             alpha:(0.5)];
    
    self.checkInButton.layer.borderWidth = 1.5f;
    self.checkInButton.layer.cornerRadius = 5.0;
    self.checkInButton.clipsToBounds = true;
    self.checkInButton.layer.borderColor = [UIColor colorWithRed:(139/255.0)
                                               green:(195/255.0)
                                                blue:(74/255.0)
                                               alpha:(1.0)].CGColor;
    
    self.checkInButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    
    [proximityRadar addSubview:self.checkInButton];
    [proximityRadar bringSubviewToFront:self.checkInButton];
    
    [self.tableView addParallaxWithView:proximityRadar
                              andHeight:proximityRadar.frame.size.height
                               andWidth:self.view.bounds.size.width
                            andRotation:YES];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.tableView.frame.size.width,
                                                                  50)];
    
    self.loaderView = [[UIView alloc] initWithFrame:CGRectMake(18,
                                                               0,
                                                               50,
                                                               50)];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [indicator startAnimating];
    
    [self.loaderView addSubview:indicator];
    
    [headerView addSubview: self.loaderView];
    
    
    self.lastUpdatedLabelView = [[UILabel alloc] initWithFrame:CGRectMake(78,
                                                                          0,
                                                                          (self.tableView.frame.size.width - 40),
                                                                          50)];
    
    self.lastUpdatedLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.lastUpdate = NSLocalizedString(@"Updating..", @"Last Update");
    
    [headerView addSubview:self.lastUpdatedLabelView];

    self.lastUpdatedLabelView.text = self.lastUpdate;
    self.lastUpdatedLabelView.font = [UIFont fontWithName:@"RobotoCondensed-Medium" size:16];
    self.lastUpdatedLabelView.textColor = [UIColor whiteColor];

    headerView.backgroundColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
    
    self.tableView.tableHeaderView = headerView;
}


- (void)checkIn :(UIButton *)sender{
    Team *team = [Teams currentRegisteredTeam];
    
    self.errorLabel.text =  NSLocalizedString(@"* Checking In *", @"Checking In Message");
    
    sender.frame = CGRectOffset( sender.frame, 0, 20);
    
    [ServiceConnect startServiceConnection:2 :team.access andCallback:^(NSDictionary* result){
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id data in result) {
                if([[data objectForKey:@"arrived"] boolValue] == YES){
                    [UIView animateWithDuration:0.2
                                          delay:0.5
                                        options: UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                    
                         [sender setEnabled:FALSE];
                         
                         double delayInSeconds = 0.5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             
                             for (Members *members in self.members) {
                                 if (members.selected.length > 0) {
                                     if ([members.arrived intValue] == 1) {
                                          self.errorLabel.text = NSLocalizedString(@"* You have already checked in *", @"Checked in already Message");
                                     } else {
                                         self.errorLabel.text = NSLocalizedString(@"* Succesfully checked in *", @"Checked in already Message");
                                         
                                         NSString *checkInButtonTitle = NSLocalizedString(@"Checked In", @"Check In Button Title");
                                         [sender setTitle:checkInButtonTitle forState:UIControlStateNormal];
                                         
                                         [self updateTableCellInformation];
                                     }
                                 }
                             }
                         });
                     } completion:^(BOOL finished){
                         double delayInSeconds = 4.0;

                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             sender.frame = CGRectOffset( sender.frame, 0, -20);
                             
                             self.errorLabel.text = NSLocalizedString(@"", @"Early Check In Message");
                             
                             [sender setEnabled:TRUE];
                         });
                     }];
                }else{
                    [ViewFX applyIncorrectPasswordShakeTo:sender];
                    
                    [UIView animateWithDuration:0.2
                                          delay:0.5
                                        options: UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                         [sender setEnabled:FALSE];
                                         
                         double delayInSeconds = 0.5;

                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             self.errorLabel.text = NSLocalizedString(@"* You are too early for your mission. Please try again within one hour of your start time. *", @"Early Check In Message");
                         });
                    } completion:^(BOOL finished){
                            double delayInSeconds = 4.0;

                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                sender.frame = CGRectOffset( sender.frame, 0, -20);
                                
                                self.errorLabel.text = NSLocalizedString(@"", @"Early Check In Message");
                                
                                [sender setEnabled:TRUE];
                            });
                     }];
                }
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            
        });
    }];
}


#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return self.members.count;
}

// Customize the appearance of table view cells.
- (void)configureCell:(CheckInCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Members *members = [self.members objectAtIndex:indexPath.row];
    
    NSString *checkedIn = NSLocalizedString(@"Not Checked In", @"Check In Status");
    
    if ([members.arrived boolValue] == YES) {
        checkedIn = NSLocalizedString(@"Checked In", @"Check In Status");

        cell.memberCheckInStatus.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                                                   green:(195/255.0)
                                                                    blue:(74/255.0)
                                                                   alpha:(1.0)];
    } else {
        cell.memberCheckInStatus.backgroundColor = [UIColor colorWithRed:(183/255.0)
                                                               green:(28/255.0)
                                                                blue:(28/255.0)
                                                               alpha:(1.0)];
    }
    
    cell.memberNameLabel.text = members.name;
    cell.memberCheckInLabel.text = checkedIn;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MADCustomCell";
    
    CheckInCell *cell = (CheckInCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CheckInCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Members *members = [self.members objectAtIndex:indexPath.row];
    
    NSString *emailActionOption =  [NSString  stringWithFormat:@"Email %@", members.name];
    
    emailActionOption = NSLocalizedString(emailActionOption, @"Action Sheet Option");
    
    NSString *actionTitle = NSLocalizedString(@"Connect", @"Action Sheet Title");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                    delegate:self cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles: emailActionOption,nil];
    
    /**
     * Let's use the actionSheet views tag to store the selected index path.
     * This will allow us to retrieve the selected team members email for our action sheet.
     * By using the tag, we don't need another property on our class just to hold a reference.
     */
    actionSheet.tag = (int)[indexPath row];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index {
    Members *members = [self.members objectAtIndex:actionSheet.tag];
    
    switch (index) {
        case 0:{
            
            NSString *emailAddress = members.email;
            NSString *subject = NSLocalizedString(@"MAD Xscape Room", @"Email Subject");
            NSString *email = [NSString stringWithFormat:@"mailto:%@?&subject=%@", emailAddress,subject ];

            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];

            break;
        }
        default:
   
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
