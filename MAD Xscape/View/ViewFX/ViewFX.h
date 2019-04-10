//
//  ViewFX.h
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-22.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewFX : UIView


+ (void)applyBlurEffectTo: (UIView *)view;
+ (void)applyDropShadowOn : (UIView *)view;
+ (void)applyIncorrectPasswordShakeTo :(UIView *)view;
+ (void)applyTiltEffectTo: (UIView *)view;



@end
