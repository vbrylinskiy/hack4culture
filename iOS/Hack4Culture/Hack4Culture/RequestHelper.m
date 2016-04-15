//
//  RequestHelper.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "RequestHelper.h"

@implementation RequestHelper

-(instancetype) init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

- (void) fetchEventsForPlaceId:(NSNumber*)placeId withBlock:(void (^)(EventList* list))block {
    NSString *address = [NSString stringWithFormat:@"http://go.wroclaw.pl/api/v1.0/events?key=928012495102009594014322187345717861707&time-from=1460753233910&time-to=1462053600000&place-id=%d",[placeId intValue]];
    NSURL *URL = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSError *error;
            EventList *list = [MTLJSONAdapter modelOfClass:[EventList class] fromJSONDictionary:responseObject error:&error];
            block(list);
        }
    }];
    [dataTask resume];
}


- (void) fetchPlacesForLat:(CGFloat) lat lon:(CGFloat) lon withBlock:(void (^)(PlaceList* list))block {
    NSString *address = [NSString stringWithFormat:@"%@%f,%f?key=928012495102009594014322187345717861707",@"http://go.wroclaw.pl/api/v1.0/places/nearLocation/",lat,lon];
    NSURL *URL = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSError *error;
            PlaceList *list = [MTLJSONAdapter modelOfClass:[PlaceList class] fromJSONDictionary:responseObject error:&error];
            block(list);
        }
    }];
    [dataTask resume];
}

@end
