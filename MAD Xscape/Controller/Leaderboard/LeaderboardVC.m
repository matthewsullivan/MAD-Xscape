//
//  LeaderboardVC.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

//MAD Xscape Imports
#import "AppDelegate.h"
#import "Leaderboard.h"
#import "LeaderBoardCell.h"
#import "LeaderboardVC.h"
#import "ServiceConnect.h"
#import "Teams.h"
#import "ViewFX.h"

//MAD Xscape Extensions
#import "UIScrollView+MSParallaxHeader.h"

@interface LeaderboardVC ()<UITableViewDataSource, UITableViewDelegate, MSParallaxViewDelegate>

@property (strong, nonatomic) NSString *lastUpdate;
@property (strong, nonatomic) UILabel *lastUpdatedLabelView;
@property (strong, nonatomic) NSMutableArray *leaders;
@property (strong, nonatomic) IBOutlet UITableView *leaderboardTable;
@property (strong, nonatomic) UIView *loaderView;

@end

@implementation LeaderboardVC

#pragma mark - Keep status bar even in landscape
- (BOOL)prefersStatusBarHidden {return NO;}

- (void)viewWillLayoutSubviews {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * Leaders table configuration
     */
    self.leaderboardTable.delegate = self;
    self.leaderboardTable.dataSource = self;
    
    /**
     * Adjust Leader table height to account for tab bar.
     */
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.leaderboardTable.contentInset = adjustForTabbarInsets;
    self.leaderboardTable.scrollIndicatorInsets = adjustForTabbarInsets;
    
    /**
     * Custom Table View Extensions  setup
     */
    self.leaderboardTable.parallaxView.delegate = self;
    
    [self teamInformation];
    
    /**
     * Will eventually call custom leader object Alloc Init method.
     */
    self.leaders = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    Team *team = [Teams currentRegisteredTeam];
    
    [ServiceConnect startServiceConnection:1 :team.access andCallback:^(NSDictionary* result){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *topLeaders = [[NSMutableArray alloc] init];
            
            if (result.count > 0) {
                for (id data in result) {
                    Leaderboard *leaders = [[Leaderboard alloc] initWithTitle:[data objectForKey:@"name"]
                                                                       TeamID:[data objectForKey:@"id"]
                                                                       Result:[data objectForKey:@"result"]
                                                                       Rating:[data objectForKey:@"place"]];
                    
                    
                    [topLeaders addObject:leaders];
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"place" ascending:YES];
                NSArray *sortedArray = [topLeaders sortedArrayUsingDescriptors:@[sortDescriptor]];
                
                self.leaders = [[NSMutableArray alloc] initWithArray:sortedArray];
            } else {
                NSString *noTeam = NSLocalizedString(@"No Teams Complete", @"No Team Table Cells");
                
                Leaderboard *leaders = [[Leaderboard alloc] initWithTitle:noTeam
                                                                   TeamID:0
                                                                   Result:@"N/A"
                                                                    Rating:0];
                
                [self.leaders removeAllObjects];
                [self.leaders addObject:leaders];
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
            
            [self.leaderboardTable reloadData];
        
        });
    }];
}

#pragma mark - UITableView Customization Methods
- (void)teamInformation {
    Team *team = [Teams currentRegisteredTeam];
    
    /**
     * leader Information View
     */
    UIView *teamInformationView = [[UIView alloc] initWithFrame: CGRectMake(0,
                                                                            0,
                                                                            self.view.bounds.size.width,
                                                                            140)];
    /**
     * leader Information View Background Image
     */
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maps"]];
    [backgroundImageView setFrame:teamInformationView.frame];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundImageView setFrame: CGRectMake(-20,
                                              -20,
                                              self.view.bounds.size.width + 40,
                                              180)];
    
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
   
    [ViewFX applyTiltEffectTo:teamInformationView];
    [ViewFX applyBlurEffectTo:backgroundImageView];
    
    /**
     * leader Information Labels
     */
    UILabel *teamName = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                  40,
                                                                  (teamInformationView.bounds.size.width - 45),
                                                                  35)];
    
    teamName.text = [NSString stringWithFormat:@"Team: %@", team.name];
    teamName.textColor = [UIColor whiteColor];
    teamName.font = [UIFont fontWithName:@"Roboto-Regular" size:20];
    teamName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    UILabel *teamCompletionTime = [[UILabel alloc] initWithFrame:CGRectMake(18,
                                                                         75,
                                                                         (teamInformationView.bounds.size.width - 45),
                                                                         35)];
    
    teamCompletionTime.text = @"5 of 10 in 45:36 minutes";
    teamCompletionTime.textColor = [UIColor whiteColor];
    teamCompletionTime.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    teamCompletionTime.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    

    /**
     * Add leader Information Subviews
     */
    [teamInformationView addSubview:backgroundImageView];
    [teamInformationView addSubview:teamName];
    [teamInformationView addSubview:teamCompletionTime];
    
    [self.tableView addParallaxWithView:teamInformationView
                              andHeight:teamInformationView.frame.size.height
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


#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return self.leaders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MADCustomCell";
    
    // Similar to UITableViewCell, but
    LeaderBoardCell *cell = (LeaderBoardCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[LeaderBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    Leaderboard *leader = self.leaders[indexPath.row];
    
    cell.rankLabel.text = [leader.place stringValue];
    cell.teamNameLabel.text = leader.name;
    cell.completionTimeLabel.text = leader.result;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
