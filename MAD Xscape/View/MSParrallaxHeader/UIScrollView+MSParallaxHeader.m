//
//  UIScrollView+MSParallaxHeader.m
//  MSme
//
//  Created by Matthew Sullivan on 2017-03-30.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//


#import "UIScrollView+MSParallaxHeader.h"

#import <QuartzCore/QuartzCore.h>

@interface MSParallaxView ()


@property(nonatomic, assign) BOOL isObserving;
@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic) CGFloat parallaxHeight;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) MSParallaxTrackingState state;

@end

#pragma mark - UIScrollView (MSParallaxHeader)
#import <objc/runtime.h>

static char UIScrollViewParallaxView;

@implementation UIScrollView (MSParallaxHeader)


- (void)addParallaxWithView:(UIView*)view
                  andHeight:(CGFloat)height
                   andWidth:(CGFloat) width
                  andRotation:(BOOL)rotation {
    
    if (self.parallaxView) {
        [self.parallaxView.currentSubView removeFromSuperview];

        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        [self.parallaxView setCustomView:view];
        
    } else {
        MSParallaxView *parallaxView = [[MSParallaxView alloc] initWithFrame:CGRectMake(0, 0, width, height) andRotation:rotation];
        [parallaxView setClipsToBounds:YES];
        
        [parallaxView setCustomView:view];
        
        parallaxView.scrollView = self;
        parallaxView.parallaxHeight = height;
        [self addSubview:parallaxView];

        parallaxView.originalTopInset = self.contentInset.top;
        
        UIEdgeInsets newInset = self.contentInset;
        newInset.top = height;
        self.contentInset = newInset;
        
        self.parallaxView = parallaxView;
        self.showsParallax = YES;
    }
}

- (void)setParallaxView:(MSParallaxView *)parallaxView {
    objc_setAssociatedObject(self, &UIScrollViewParallaxView,
                             parallaxView,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (MSParallaxView *)parallaxView {
    return objc_getAssociatedObject(self, &UIScrollViewParallaxView);
}

- (void)setShowsParallax:(BOOL)showsParallax {
    self.parallaxView.hidden = !showsParallax;
    
    if (!showsParallax) {
        if (self.parallaxView.isObserving) {
            
            [self removeObserver:self.parallaxView forKeyPath:@"contentOffset"];
            [self removeObserver:self.parallaxView forKeyPath:@"frame"];
            self.parallaxView.isObserving = NO;
            
        }
    } else {
        if (!self.parallaxView.isObserving) {
            [self addObserver:self.parallaxView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.parallaxView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

            self.parallaxView.isObserving = YES;
        }
    }
}

- (BOOL)showsParallax {
    return !self.parallaxView.hidden;
}

@end

#pragma mark - MSParallaxView
@implementation MSParallaxView

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame andRotation:NO];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andRotation:(BOOL)rotate {
    if(self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        // default styling values
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        
        [self setState:MSParallaxTrackingActive];
        
        self.imageView = [[UIImageView alloc] init];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setClipsToBounds:YES];
        [self addSubview:self.imageView];
        
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView" : self.imageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:@{@"imageView" : self.imageView}]];
        
        if (rotate) {
            [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        }
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsParallax) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "MSParallaxView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"frame"];

                self.isObserving = NO;
            }
        }
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];

    self.currentSubView = view;
}

- (void)setCustomView:(UIView *)customView {
    if (_customView) {
        [_customView removeFromSuperview];
    }
    
    _customView = customView;
    
    [self addSubview:customView];
    [customView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:nil views:@{@"customView" : customView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView" : customView}]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    } else if ([keyPath isEqualToString:@"frame"]) {
        [self layoutSubviews];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    // We do not want to track when the parallax view is hidden
    if (contentOffset.y > 0) {
        [self setState:MSParallaxTrackingInactive];
    } else {
        [self setState:MSParallaxTrackingActive];
    }
    
    if(self.state == MSParallaxTrackingActive) {
        CGFloat yOffset = contentOffset.y*-1;
        if ([self.delegate respondsToSelector:@selector(parallaxView:willChangeFrame:)]) {
            [self.delegate parallaxView:self willChangeFrame:self.frame];
        }
        
        [self setFrame:CGRectMake(0, contentOffset.y, CGRectGetWidth(self.frame), yOffset)];
        
        if ([self.delegate respondsToSelector:@selector(parallaxView:didChangeFrame:)]) {
            [self.delegate parallaxView:self didChangeFrame:self.frame];
        }
    }
}

@end
