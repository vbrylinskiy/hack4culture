//
//  CustomMapView.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "CustomMapView.h"

NSString* const MapViewDidTapMap = @"MapViewDidTapMap";
NSString* const MapViewDidLongTapMap = @"MapViewDidLongTapMap";

NSString* const MapViewUserInfoMap = @"MapViewUserInfoMap";

@interface CustomMapView ()

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGesture;

@end

@implementation CustomMapView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initGestures];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initGestures];
    }
    
    return self;
}

-(void)initGestures{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [self addGestureRecognizer:self.tapGesture];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGesture.minimumPressDuration = 0.2;
    
    [self addGestureRecognizer:self.longPressGesture];
    
    [self.tapGesture requireGestureRecognizerToFail:self.longPressGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self];
    NSUInteger numberOfTouches = [tapGesture numberOfTouches];
    
    if (numberOfTouches == 1 && tapGesture.state == UIGestureRecognizerStateEnded) {
        id v = [self hitTest:tapPoint withEvent:nil];
        
        if ([v isKindOfClass:[MKPinAnnotationView class]] || [v isKindOfClass:[MKAnnotationView class]]) {
            [self selectAnnotation:[v annotation] animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:MapViewDidTapMap object:self userInfo:@{ MapViewUserInfoMap:self }];
        }
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MapViewDidLongTapMap object:self userInfo:@{ MapViewUserInfoMap:self }];
    }
}



@end
