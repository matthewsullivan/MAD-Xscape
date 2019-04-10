//
//  UIScrollView+MSParallaxHeader.h
//  MSme
//
//  Created by Matthew Sullivan on 2017-03-30.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSParallaxView;
@class MSParallaxShadowView;

#pragma mark UIScrollView Category
@interface UIScrollView (MSParallaxHeader)

- (void)addParallaxWithView:(UIView*)view
                  andHeight:(CGFloat)height
                   andWidth:(CGFloat)width
                  andRotation:(BOOL)rotation;

@property (nonatomic, strong, readonly) MSParallaxView *parallaxView;
@property (nonatomic, assign) BOOL showsParallax;

@end

#pragma mark MSParallaxView

@protocol MSParallaxViewDelegate;

typedef NS_ENUM(NSUInteger, MSParallaxTrackingState) {
    MSParallaxTrackingActive = 0,
    MSParallaxTrackingInactive
};

@interface MSParallaxView : UIView

@property (weak) id<MSParallaxViewDelegate> delegate;
@property (nonatomic, strong) UIView *currentSubView;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly)MSParallaxTrackingState state;

- (id)initWithFrame:(CGRect)frame andRotation:(BOOL)rotate;

@end

@protocol MSParallaxViewDelegate <NSObject>
@optional
- (void)parallaxView:(MSParallaxView *)view willChangeFrame:(CGRect)frame;
- (void)parallaxView:(MSParallaxView *)view didChangeFrame:(CGRect)frame;
@end

#pragma mark MSParallaxShadowView

@interface MSParallaxShadowView : UIView

@end
