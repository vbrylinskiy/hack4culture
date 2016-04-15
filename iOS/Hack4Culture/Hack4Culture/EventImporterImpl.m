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
    __block NSMutableArray *events = [NSMutableArray array];
    __block RequestHelper* requestHelper = [[RequestHelper alloc] init];
    NSUInteger count = polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(count * sizeof(CLLocationCoordinate2D));
    [polyline getCoordinates:routeCoordinates range:NSMakeRange(0, count)];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (int c=0; c < count; c++){
        dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            [requestHelper fetchIdentifiersForLat:routeCoordinates[c].latitude lon:routeCoordinates[c].longitude withBlock:^(EventList *list) {
                [events addObjectsFromArray:list.items];
            }];
        });
    }
    
    dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        block(events, NULL);
    });

    free(routeCoordinates);
}

@end
