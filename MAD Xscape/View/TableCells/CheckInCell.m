//
//  CheckInCell.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "CheckInCell.h"

@implementation CheckInCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        /** 
         * Status Circle View
         */
        self.memberCheckInStatus = [[UILabel alloc] initWithFrame:CGRectMake(15, 22, 20, 20)];
        
        CGPoint saveCenter = self.memberCheckInStatus.center;
        CGRect newFrame = CGRectMake(self.memberCheckInStatus.frame.origin.x, self.memberCheckInStatus.frame.origin.y, 20, 20);

        self.memberCheckInStatus.frame = newFrame;
        self.memberCheckInStatus.clipsToBounds = YES;
        self.memberCheckInStatus.layer.cornerRadius = 20 / 2.0;
        self.memberCheckInStatus.center = saveCenter;
        self.memberCheckInStatus.backgroundColor = [UIColor colorWithRed:(183/255.0) green:(28/255.0) blue:(28/255.0) alpha:(1.0)];
        
        /**
         * Member Name Label
         */
        self.memberNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 300, 30)];
        self.memberNameLabel.textColor = [UIColor blackColor];
        self.memberNameLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:18.0f];
        self.memberNameLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
        self.memberNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /**
         * Member Check In Status Label
         */
        self.memberCheckInLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 35, 300, 20)];
        self.memberCheckInLabel.textColor = [UIColor blackColor];
        self.memberCheckInLabel.font = [UIFont fontWithName:@"Roboto-Italic" size:14.0f];
        self.memberCheckInLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
        self.memberCheckInLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /**
         * Adding labels to super view (table cell)
         */
        [self addSubview:self.memberCheckInStatus];
        [self addSubview:self.memberNameLabel];
        [self addSubview:self.memberCheckInLabel];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
