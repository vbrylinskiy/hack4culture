//
//  EventImporter.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@protocol EventImporter <NSObject>

@required
- (void)importEventsForPolyline:(MKPolyline *)polyline withBlock:(void(^)(NSArray *events, NSError *error))block;

@end
