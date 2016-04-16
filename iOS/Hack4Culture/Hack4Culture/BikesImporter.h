//
//  BikesImporter.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface Bike : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@interface BikesImporter : NSObject

+ (NSArray <Bike *> *)importBikes;

@end
