//
//  Event.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "Location.h"

@interface Event : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *identifier;
@property (nonatomic, copy, readonly) NSString *modified;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, readonly) NSString *startDate;
@property (nonatomic, readonly) NSString *endDate;
@property (nonatomic, copy, readonly) NSString *eventDuration;
@property (nonatomic, copy, readonly) NSDictionary *location;
@property (nonatomic, copy, readonly) NSDictionary *address;
@property (nonatomic, copy, readonly) NSDictionary *offer;
@property (nonatomic, copy, readonly) NSString *placeName;
@property (nonatomic, copy, readonly) NSNumber *premiere;
@property (nonatomic, copy, readonly) NSString *ticketing;
@property (nonatomic, copy, readonly) NSString *priceMin;
@property (nonatomic, copy, readonly) NSString *priceMax;
@property (nonatomic, copy, readonly) NSNumber *urbancardPremium;
@property (nonatomic, copy, readonly) NSNumber *priority;

- (NSString *)transformedStartDate;
- (NSString *)transformedEndDate;
@end
