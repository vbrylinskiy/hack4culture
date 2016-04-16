//
//  RequestHelper.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <Mantle.h>
#import "PlaceList.h"
#import "EventList.h"

@interface RequestHelper : NSObject
@property (strong, nonatomic) AFURLSessionManager *manager;

- (void) fetchPlacesForLat:(CGFloat) lat lon:(CGFloat) lon withBlock:(void (^)(PlaceList* list))block;
- (void) fetchEventsForPlaceId:(NSNumber*)placeId withBlock:(void (^)(EventList* list))block;

+(void)setMaxDate:(NSTimeInterval)maxDate;
+(NSTimeInterval)maxDate;

+(NSDictionary*) categories;
+(void) updateFilterAtIndex:(NSInteger)index withValue:(NSNumber*)boolean;
+(NSArray*) categorieFilters;

@end
