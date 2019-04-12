//
//  ViewFX.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-22.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "ViewFX.h"

@implementation ViewFX

+ (void)applyTiltEffectTo: (UIView *)view {
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    [view addMotionEffect:group];

    
}

+ (void)applyBlurEffectTo: (UIView *)view {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        view.backgroundColor = [UIColor blackColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

        blurEffectView.frame = view.bounds;
        blurEffectView.alpha = 0.7;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [view addSubview:blurEffectView];
    } else {
        view.backgroundColor = [UIColor blackColor];
    }
}

+ (void)applyIncorrectPasswordShakeTo:(UIView *)view {
    view.transform = CGAffineTransformMakeTranslation(20, 0);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = CGAffineTransformIdentity;
    } completion:nil];
}

+ (void)applyDropShadowOn : (UIView *)view {
    view.layer.shadowRadius = 3.0f;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.masksToBounds = NO;
}

@end
