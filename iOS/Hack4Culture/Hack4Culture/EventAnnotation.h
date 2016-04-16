//
//  EventAnnotation.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface EventAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Event *event;

@end
