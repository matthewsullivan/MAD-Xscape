//
//  MembersVC.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

//MAD Xscape Imports
#import "AppDelegate.h"
#import "Constants.h"
#import "MembersVC.h"
#import "Member+CoreDataProperties.h"
#import "Teams.h"
#import "Team+CoreDataProperties.h"
#import "ViewFX.h"

//MAD Xscape Extensions
#import "UIScrollView+MSParallaxHeader.h"

@interface MembersVC () <UITableViewDataSource,
                        UITableViewDelegate,
                        MSParallaxViewDelegate,
                        NSFetchedResultsControllerDelegate,
                        UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *membersTable;
@property (nonatomic, strong) UILabel *teamBookingTimeCountDown;
@property NSTimer *timer;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MembersVC

#pragma mark - Core Data Managed Object Reference.
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }

    return context;
}

#pragma mark - Keep status bar even in landscape
- (BOOL)prefersStatusBarHidden {return NO;}

- (void)viewWillLayoutSubviews {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - View Controller Tear Down and Setup Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //Check core data to see if a Members object exists. If not we need to login.
    if ([Teams isTeamSaved]) {
        //Do a fetch for our table view and other view setup!
        NSError *error;
        
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
        
        [self.membersTable reloadData];
        
        [self teamInformation];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (![Teams isTeamSaved]) {
        [self performSegueWithIdentifier:LoginSegue sender: self];
    }
}

#pragma mark - UITableView Customization Methods
- (void)teamInformation {
    [self.timer invalidate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSEntityDescription *venueEntity = [NSEntityDescription entityForName:@"Team"
                                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:venueEntity];
    
    NSMutableArray *allRecords = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    Team *team = [allRecords objectAtIndex:0];
    
    /**
     * Member Information View
     */
    UIView *teamInformationView = [[UIView alloc] initWithFrame: CGRectMake(0,
                                                                         0,
                                                 self.view.bounds.size.width,
                                                                     220)];
    /**
     * Member Information View Background Image
     */
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maps"]];
    
    //The frame should be the same as the teamInformationView, but we need to account for our Tilt View Effect
    [backgroundImageView setFrame: CGRectMake(-20,
                                            -20,
                                            self.view.bounds.size.width + 40,
                                            260)];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [ViewFX applyTiltEffectTo:teamInformationView];
    [ViewFX applyBlurEffectTo:backgroundImageView];
    
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    /**
     * Member Information Labels
     */
    UILabel *teamName = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                40,
                      (teamInformationView.bounds.size.width - 45),
                                                             35)];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Team:", @"Team Label"),team.name];
    
    teamName.text = name;
    teamName.textColor = [UIColor whiteColor];
    teamName.font = [UIFont fontWithName:@"Roboto-Regular" size:18];
    teamName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    UILabel *teamBookingDate = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                  75,
                                                                  (teamInformationView.bounds.size.width - 45),
                                                                  35)];
    
    teamBookingDate.text = team.date;
    teamBookingDate.textColor = [UIColor whiteColor];
    teamBookingDate.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    teamBookingDate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *teamBookingTime = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                         110,
                                                                         (teamInformationView.bounds.size.width - 45),
                                                                         35)];
    
    teamBookingTime.text = team.time;
    teamBookingTime.textColor = [UIColor whiteColor];
    teamBookingTime.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    teamBookingTime.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.teamBookingTimeCountDown = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                         145,
                                                                         (teamInformationView.bounds.size.width - 45),
                                                                         35)];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:s"];
    NSDate *date = [dateFormat dateFromString:team.countDown];
    
    self.timer = [NSTimer timerWithTimeInterval:1.5/60.0
                                             target:self
                                           selector:@selector(updateCountdown:)
                                           userInfo:@{@"date": date} repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    self.teamBookingTimeCountDown.textColor = [UIColor whiteColor];
    self.teamBookingTimeCountDown.font = [UIFont fontWithName:@"Roboto-Italic" size:14];
    self.teamBookingTimeCountDown.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    /**
     * Add Member Information Subviews
     */
    [teamInformationView addSubview:backgroundImageView];
    [teamInformationView addSubview:teamName];
    [teamInformationView addSubview:teamBookingDate];
    [teamInformationView addSubview:teamBookingTime];
    [teamInformationView addSubview:self.teamBookingTimeCountDown];
    
    
    [self.membersTable addParallaxWithView:teamInformationView
                            andHeight:teamInformationView.frame.size.height
                             andWidth:self.view.bounds.size.width
                          andRotation:YES];
    
       
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.membersTable.frame.size.width,
                                                                  50)];
    
    
    UILabel *teamLeaderLabelView = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                   0,
                                                                   (self.membersTable.frame.size.width - 40),
                                                                   50)];
    teamLeaderLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    fetchRequest = [[NSFetchRequest alloc] init];
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"type == %i",1];
    [fetchRequest setPredicate:fetchPredicate];
    
    NSEntityDescription *memeberEntity = [NSEntityDescription entityForName:@"Member"
                                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:memeberEntity];
    [fetchRequest setPredicate:fetchPredicate];
    
    allRecords = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    Member *member = [allRecords objectAtIndex:0];
    
    NSString *leader = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Team Leader: ", @"Team Label"),member.name];
    
    [headerView addSubview:teamLeaderLabelView];
    teamLeaderLabelView.text = leader;
    teamLeaderLabelView.font = [UIFont fontWithName:@"RobotoCondensed-Medium" size:16];
    teamLeaderLabelView.textColor = [UIColor whiteColor];
    headerView.backgroundColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
    
    self.membersTable.tableHeaderView = headerView;
}

- (void)updateCountdown :(NSTimer *)timer {
    NSDate *date = [[timer userInfo] objectForKey:@"date"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *startingDate = [NSDate date];
    NSDate *endingDate = date;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear |
                          NSCalendarUnitMonth |
                          NSCalendarUnitDay |
                          NSCalendarUnitHour|
                          NSCalendarUnitMinute|
                          NSCalendarUnitSecond;
    
    
    NSDateComponents *dateComponents = [calendar components:unitFlags
                                                  fromDate:startingDate
                                                    toDate:endingDate options:0];
    
    NSDateComponents *dayComponent = [calendar components:NSCalendarUnitDay
                                                 fromDate:startingDate
                                                   toDate:endingDate options:0];
    int day = (int)dayComponent.day;
    
    NSInteger hours    = [dateComponents hour];
    NSInteger minutes  = [dateComponents minute];
    NSInteger seconds  = [dateComponents second];
    
    NSString *countdownText;
    
    if (day <= 0 && hours <= 0 && minutes <= 0 && seconds <=0) {
        countdownText = NSLocalizedString(@"The day has come..", @"Countdown Text Label");
    } else {
        NSString *locDay = NSLocalizedString(@"Days", @"Count Down Text");
        if (day == 1) { locDay = NSLocalizedString(@"Day", @"Count Down Text");}
        
        NSString *locHours = NSLocalizedString(@"Hours", @"Count Down Text");
        if (hours == 1) { locHours = NSLocalizedString(@"Hour", @"Count Down Text");}

        NSString *locMinutes = NSLocalizedString(@"Minutes", @"Count Down Text");
        if (minutes == 1) { locMinutes = NSLocalizedString(@"Minute", @"Count Down Text");}
        
        NSString *locSeconds = NSLocalizedString(@"Seconds", @"Count Down Text");
        if (seconds == 1) { locSeconds = NSLocalizedString(@"Second", @"Count Down Text");}
        
        countdownText = [NSString stringWithFormat:@"%i %@ %ld %@ %ld %@ %ld %@",day,locDay,(long)hours,locHours,(long)minutes,locMinutes,(long)seconds,locSeconds];
    }
    
    self.teamBookingTimeCountDown.text = countdownText;
}

#pragma mark - UITableView Delegate Methods
// The data source methods are handled primarily by the fetch results controller
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell to show the book's title
    Member *member = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSString *cellTitle = [NSString stringWithFormat:@"%@ %i: %@",
            NSLocalizedString(@"Member", @"Member Cell Label."),
                                             member.memberID,
                                                member.name];
    
    cell.textLabel.text = cellTitle;
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:18.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MADCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Member *member = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *emailActionOption =  [NSString  stringWithFormat:@"Email %@", member.name];
    
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
    actionSheet.tag = (int)[indexPath section];
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index {
    Member *member = [[self.fetchedResultsController fetchedObjects] objectAtIndex:actionSheet.tag];
    
    switch (index) {
        case 0:{
            
            NSString *emailAddress = member.email;
            
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


/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Member" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"memberID" ascending:YES];
    NSArray *sortDescriptors = @[typeDescriptor,nameDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.membersTable beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.membersTable endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.membersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.membersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];

            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];

            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.membersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.membersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
