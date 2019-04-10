//
//  BeaconRadar.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-08-22.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BeaconRadar : UIView

- (void)createTargets :(int)numebrOfTargets;
- (void)layoutRadarWindowWithFrame :(UIView *)parentView;
- (void)startRadar;
- (void)stopRadar;

@end
