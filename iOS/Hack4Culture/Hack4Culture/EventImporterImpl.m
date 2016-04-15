//
//  EventImporterImpl.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "EventImporterImpl.h"
#import "RequestHelper.h"

@implementation EventImporterImpl


-(void)importEventsForPolyline:(MKPolyline *)polyline withBlock:(void (^)(NSArray *, NSError *))block {
    __block NSMutableArray *places = [NSMutableArray array];
    __block RequestHelper* requestHelper = [[RequestHelper alloc] init];
    NSUInteger count = polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(count * sizeof(CLLocationCoordinate2D));
    [polyline getCoordinates:routeCoordinates range:NSMakeRange(0, count)];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (int c=0; c < count; c++){
        dispatch_group_enter(group);
        [requestHelper fetchPlacesForLat:routeCoordinates[c].latitude lon:routeCoordinates[c].longitude withBlock:^(PlaceList *list) {
            [places addObjectsFromArray:list.items];
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group,dispatch_get_main_queue(), ^ {
        [self getEventsForPlaces:places withBlock:block];
    });
    free(routeCoordinates);
}


-(void)getEventsForPlaces:(NSArray*)places withBlock:(void (^)(NSArray *, NSError *))block {
    __block NSMutableArray *events = [NSMutableArray array];
    __block RequestHelper* requestHelper = [[RequestHelper alloc] init];
    dispatch_group_t group = dispatch_group_create();
    
    for (Place *place in places) {
        dispatch_group_enter(group);
        [requestHelper fetchEventsForPlaceId:place.identifier withBlock:^(EventList *list) {
            [events addObjectsFromArray:list.items];
            NSLog(@"updated event count %lu", (unsigned long)events.count);
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group,dispatch_get_main_queue(), ^ {
        block(events, NULL);
    });
    
}



@end
