//
//  CheckInCell.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CheckInCell : UITableViewCell

@property (nonatomic, strong) UILabel *memberCheckInLabel;
@property (nonatomic, strong) UIView *memberCheckInStatus;
@property (nonatomic, strong) UILabel *memberNameLabel;

@end
