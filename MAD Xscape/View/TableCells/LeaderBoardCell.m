//
//  LeaderBoardCell.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-14.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "LeaderBoardCell.h"

@implementation LeaderBoardCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        /** 
         * Rank Label
         */
        self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 10, 30)];
        self.rankLabel.textColor = [UIColor blackColor];
        self.rankLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:18.0f];
        self.rankLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
       
        /**
         * Team Name Label
         */
        self.teamNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 300, 30)];
        self.teamNameLabel.textColor = [UIColor blackColor];
        self.teamNameLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:18.0f];
        self.teamNameLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
        self.teamNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /**
         * Completion Time Label
         */
        self.completionTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, 300, 20)];
        self.completionTimeLabel.textColor = [UIColor blackColor];
        self.completionTimeLabel.font = [UIFont fontWithName:@"Roboto-Italic" size:14.0f];
        self.completionTimeLabel.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
        self.completionTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /**
         * Adding labels to super view (table cell)
         */
        [self addSubview:self.rankLabel];
        [self addSubview:self.teamNameLabel];
        [self addSubview:self.completionTimeLabel];
        
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
