//
//  CustomMapView.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <MapKit/MapKit.h>

FOUNDATION_EXPORT NSString* const MapViewDidTapMap;
FOUNDATION_EXPORT NSString* const MapViewDidLongTapMap;

FOUNDATION_EXPORT NSString* const MapViewUserInfoMap;

@interface CustomMapView : MKMapView

@property (nonatomic, readonly, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, readonly, strong) UILongPressGestureRecognizer* longPressGesture;

@end
