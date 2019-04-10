//
//  BeaconRadar.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-08-22.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "BeaconRadar.h"
#import <QuartzCore/QuartzCore.h>


@interface BeaconRadar ()

@property (strong, nonatomic) UIView *hand;
@property (strong, nonatomic) UIView * leftGaugeMonitor;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIView *proximityGraphView;
@property (strong, nonatomic) UIView *proximityGaugeGraphView;
@property (strong, nonatomic) UIView *radarView;
@property (strong, nonatomic) UIView * rightGaugeMonitor;
@property (strong, nonatomic) NSMutableArray *targets;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BeaconRadar

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    
    self.proximityGaugeGraphView.layer.sublayers = nil;
    self.self.proximityGraphView.layer.sublayers = nil;
    
    [self createProximityGraph];
}

- (void)layoutRadarWindowWithFrame :(UIView *)parentView {
    self.parentView = parentView;
    
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 10;
    float x = parentView.frame.size.width / 2 - ((parentView.frame.size.height - 140) / 2);
    float y = statusBarHeight;
    
    self.radarView = [[UIView alloc] initWithFrame:CGRectMake(x,
                                                          y,
                          parentView.frame.size.height - 140,
                         parentView.frame.size.height - 140)];
    
    self.radarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    self.proximityGraphView = [[UIView alloc] initWithFrame:CGRectMake(18,
                                                                     statusBarHeight,
                                                                      parentView.frame.size.width - 35,
                                                                     parentView.frame.size.height - 140)];
    
    self.proximityGraphView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    self.proximityGaugeGraphView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                           parentView.frame.size.width - 35,
                                         parentView.frame.size.height - 140)];
    
    self.proximityGaugeGraphView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    [self createGridSheet];
    [self createContourLine];
    [self createHand];
    [self createProximityGraph];
    
    [parentView addSubview:self.radarView];
}
    
- (void)createContourLine {
    float referenceRadius  = self.radarView.frame.size.height / 2;
    float radius[] = {referenceRadius - 75, referenceRadius - 50, referenceRadius, 3};
    
    for (int i = 0; i < 4; i++) {
        float size = radius[i] * 2.0;
    
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        line.backgroundColor = [UIColor clearColor];
        
        if (i == 3) {
            
            line.backgroundColor =  [UIColor colorWithRed:(139/255.0)
                                                    green:(195/255.0)
                                                     blue:(74/255.0)
                                                    alpha:(1.0)];
        }
        
        line.layer.borderColor = [UIColor colorWithRed:(139/255.0)
                                                 green:(195/255.0)
                                                  blue:(74/255.0)
                                                 alpha:(1.0)].CGColor;
        
        line.layer.borderWidth = 2;
        line.center = CGPointMake(self.radarView.frame.size.height / 2,self.radarView.frame.size.width / 2);
        line.layer.cornerRadius = radius[i];
        
        [self.radarView addSubview:line];
    }
}

- (void)createHand {
    self.hand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.radarView.frame.size.height / 2, 4)];
    self.hand.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                                green:(195/255.0)
                                                 blue:(74/255.0)
                                                alpha:(1.0)];
    
    [self.radarView addSubview:self.hand];
    
    self.hand.layer.anchorPoint = CGPointMake(0, 0.5);
    self.hand.layer.allowsEdgeAntialiasing = YES;
    self.hand.layer.position = CGPointMake(self.radarView.frame.size.height / 2,self.radarView.frame.size.width / 2);
}

- (void)createTargets :(int)numebrOfTargets {
    self.targets = [[NSMutableArray alloc] init];
    
    int allowableRadius = self.radarView.frame.size.height;
    
    for (int i = 0; i < numebrOfTargets; i++) {
        int lowerBound = 60;
        int upperBound = allowableRadius;
        
        float x = lowerBound + arc4random() % (upperBound - lowerBound);
        float y = lowerBound + arc4random() % (upperBound - lowerBound);
    
        UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        t.layer.cornerRadius = 5.0;
        t.center = CGPointMake(x, y);
        t.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                            green:(195/255.0)
                                             blue:(74/255.0)
                                            alpha:(1.0)];
        
        t.alpha = 0.0;

        [self.radarView addSubview:t];
        [self.targets addObject:t];
    }
}

- (void)startRadar{
    [self animateGauges];
    
    self.timer = [NSTimer timerWithTimeInterval:1.5/60.0
                                             target:self
                                           selector:@selector(tick:)
                                           userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer: self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopRadar {
    if(self.timer){
        [self.timer invalidate];
         self.timer = nil;
    }
}

- (void)createProximityGraph {
    CGRect rect = self.proximityGraphView.frame;
    
    UIBezierPath * leftLinePath = [UIBezierPath bezierPath];
    [leftLinePath moveToPoint: CGPointMake(18, 0)];
    [leftLinePath addLineToPoint: CGPointMake(0, 0)];
    [leftLinePath addLineToPoint: CGPointMake(0, rect.size.height)];
    [leftLinePath addLineToPoint: CGPointMake(18, rect.size.height)];
         
    // create a layer that uses your defined path
    CAShapeLayer * leftLineLayer = [CAShapeLayer layer];
    leftLineLayer.lineWidth = 1.8;
    leftLineLayer.strokeColor = [UIColor colorWithRed:(139/255.0)
                                            green:(195/255.0)
                                             blue:(74/255.0)
                                            alpha:(1.0)].CGColor;
    
    leftLineLayer.fillColor = nil;
    leftLineLayer.path = leftLinePath.CGPath;
    
    UIBezierPath* rightLinePath = [UIBezierPath bezierPath];
    [rightLinePath moveToPoint: CGPointMake(rect.size.width - 18, 0)];
    [rightLinePath addLineToPoint: CGPointMake(rect.size.width, 0)];
    [rightLinePath addLineToPoint: CGPointMake(rect.size.width, rect.size.height)];
    [rightLinePath addLineToPoint: CGPointMake(rect.size.width - 18, rect.size.height)];
    
    // create a layer that uses your defined path
    CAShapeLayer * rightLineLayer = [CAShapeLayer layer];
    rightLineLayer.lineWidth = 1.8;
    rightLineLayer.strokeColor = [UIColor colorWithRed:(139/255.0)
                                                green:(195/255.0)
                                                 blue:(74/255.0)
                                                alpha:(1.0)].CGColor;
    
    rightLineLayer.fillColor = nil;
    rightLineLayer.path = rightLinePath.CGPath;
    
    int gaugeLineCount = rect.size.height / 16;
    int yIncrement = 16;
    
    for (int i = 0; i < gaugeLineCount; i++) {
        UIBezierPath* leftGaugeLinePath = [UIBezierPath bezierPath];
        [leftGaugeLinePath moveToPoint: CGPointMake(0, yIncrement)];
        [leftGaugeLinePath addLineToPoint: CGPointMake(10, yIncrement)];
        
        // create a layer that uses your defined path
        CAShapeLayer * leftGaugeLineLayer = [CAShapeLayer layer];
        leftGaugeLineLayer.lineWidth = 1.5;
        leftGaugeLineLayer.strokeColor = [UIColor colorWithRed:(139/255.0)
                                                     green:(195/255.0)
                                                      blue:(74/255.0)
                                                     alpha:(1.0)].CGColor;
        leftGaugeLineLayer.fillColor = nil;
        leftGaugeLineLayer.path = leftGaugeLinePath.CGPath;
        
        [self.proximityGraphView.layer addSublayer:leftGaugeLineLayer];
        
        UIBezierPath* rightGaugeLinePath = [UIBezierPath bezierPath];
        [rightGaugeLinePath moveToPoint: CGPointMake(rect.size.width - 10, yIncrement)];
        [rightGaugeLinePath addLineToPoint: CGPointMake(rect.size.width , yIncrement)];
        
        // create a layer that uses your defined path
        CAShapeLayer * rightGaugeLineLayer = [CAShapeLayer layer];
        rightGaugeLineLayer.lineWidth = 1.5;
        rightGaugeLineLayer.strokeColor = [UIColor colorWithRed:(139/255.0)
                                                         green:(195/255.0)
                                                          blue:(74/255.0)
                                                         alpha:(1.0)].CGColor;
        rightGaugeLineLayer.fillColor = nil;
        rightGaugeLineLayer.path = rightGaugeLinePath.CGPath;
        
        [self.proximityGraphView.layer addSublayer:rightGaugeLineLayer];
        
        yIncrement = yIncrement + 15;
    }
    
    [self.proximityGraphView.layer addSublayer:leftLineLayer];
    [self.proximityGraphView.layer addSublayer:rightLineLayer];
    
    //CRASH CHECK HERE
    //[self.proximityGraphView addSubview:self.proximityGaugeGraphView];
    [self.parentView addSubview:self.proximityGraphView];
}

- (void)animateGauges {
    /*
    CGRect rect = self.proximityGraphView.frame;
    
    self.leftGaugeMonitor = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     rect.size.height - 20,
                                                                     18,
                                                                     20)];
    
    self.leftGaugeMonitor.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                                            green:(195/255.0)
                                                             blue:(74/255.0)
                                                            alpha:(1.0)];
    
    self.leftGaugeMonitor.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    
    self.rightGaugeMonitor = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width - 18,
                                                                      rect.size.height - 20,
                                                                      18,
                                                                      20)];
    
    self.rightGaugeMonitor.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                                             green:(195/255.0)
                                                              blue:(74/255.0)
                                                             alpha:(1.0)];
    
    self.rightGaugeMonitor.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    [self.proximityGaugeGraphView addSubview:self.leftGaugeMonitor];
    [self.proximityGaugeGraphView addSubview:self.rightGaugeMonitor];
    
    float originalY = self.leftGaugeMonitor.frame.origin.y;
    float originalH = self.leftGaugeMonitor.bounds.size.height;
    
    
    [UIView animateKeyframesWithDuration:10.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat  animations:^{
        
        self.leftGaugeMonitor.frame = CGRectMake(self.leftGaugeMonitor.frame.origin.x,
                                                 (originalY + originalH),
                                                 self.leftGaugeMonitor.bounds.size.width,
                                                 0);
        
        self.rightGaugeMonitor.frame = CGRectMake(self.rightGaugeMonitor.frame.origin.x,
                                                  (originalY + originalH),
                                                  self.rightGaugeMonitor.bounds.size.width,
                                                  0);
        
    }completion:^(BOOL finished) {
        
        NSLog(@"Animation is complete");
        
    }];
     */
}

- (void)tick:(NSTimer*)sender{
    self.hand.transform = CGAffineTransformRotate(self.hand.transform, M_PI * 0.01);
    
    float angle = [[self.hand.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    CALayer *line = [CALayer layer];
    
    line.frame = CGRectMake(0, 0, self.radarView.frame.size.height / 2, 3);
    line.allowsEdgeAntialiasing = YES;
    line.anchorPoint = CGPointMake(0, 0.5);
    line.position = CGPointMake(self.radarView.frame.size.height / 2,self.radarView.frame.size.width / 2);
    line.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    line.backgroundColor = [UIColor colorWithRed:(139/255.0)
                                           green:(195/255.0)
                                            blue:(74/255.0)
                                           alpha:(1.0)].CGColor;
    
    line.opacity = 0;
    
    [self.radarView.layer addSublayer:line];
    
    for (int i=0; i < [self.targets count]; i++) {
        UIView *t = [self.targets objectAtIndex:i];
        
        if ([self.hand.layer.presentationLayer hitTest:t.center]) {
            t.alpha = 0.95;
            [UIView animateWithDuration:1.5 animations:^{
                t.alpha = 0.0;
            }];
        }
    }
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    fade.fromValue = @1.0;
    fade.toValue = @0;
    fade.duration = 0.5;
    
    [line addAnimation:fade forKey:nil];
    
    [line performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:0.5];
}

- (void)createGridSheet{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float size = 32;
    
    for (int i = 0; i < 5220 / size; i++) {
        [path moveToPoint:CGPointMake(i * size, 0)];
        [path addLineToPoint:CGPointMake(i * size, 7000)];
    }
    
    for (int i = 0; i < 7000 / size; i++) {
        [path moveToPoint:CGPointMake(0, i*size)];
        [path addLineToPoint:CGPointMake(5220, i*size)];
    }
    
    CAShapeLayer *sl = [[CAShapeLayer alloc] init];
    
    sl.strokeColor = [UIColor colorWithRed:(75/255.0f) green:(115/255.0f) blue:(57/255.0f) alpha:1.0f].CGColor;
    sl.lineWidth = 1;
    sl.path = path.CGPath;
    
    [self.parentView.layer addSublayer:sl];
}

@end
