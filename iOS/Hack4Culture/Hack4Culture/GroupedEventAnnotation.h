//
//  GroupedEventAnnotation.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;
#import "Event.h"

@interface GroupedEventAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSArray <Event *> *events;

@end
