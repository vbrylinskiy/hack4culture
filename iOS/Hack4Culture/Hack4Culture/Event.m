//
//  Event.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "Event.h"

@implementation Event

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier":@"identifier",
             @"modified":@"modified",
             @"url":@"url",
             @"eventDuration":@"eventDuration",
             @"location":@"location",
             @"address":@"address",
             @"offer":@"offer",
             @"placeName":@"placeName",
             @"premiere":@"premiere",
             @"priceMin":@"priceMin",
             @"priceMax":@"priceMax",
             @"ticketing":@"ticketing",
             @"urbancardPremium":@"urbancardPremium",
             @"priority":@"priority"
             };
}
@end
