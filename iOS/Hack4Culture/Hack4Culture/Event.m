//
//  Event.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "Event.h"
#import "Location.h"

@implementation Event

//+ (NSValueTransformer *)locationJSONTransformer {
//    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Location.class];
//}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier":@"id",
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

-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:Event.class]) {
        return self.identifier == ((Event*)object).identifier;
    } else {
        return [super isEqual:object];
    }
}

@end
