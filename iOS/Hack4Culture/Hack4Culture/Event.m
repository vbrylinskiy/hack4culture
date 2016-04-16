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
             @"priority":@"priority",
             @"startDate" : @"startDate",
             @"endDate" : @"endDate",
             };
}

-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:Event.class]) {
        return [self.identifier intValue] == [((Event*)object).identifier intValue];
    } else {
        return [super isEqual:object];
    }
}

- (NSString *)transformedStartDate {
    return [NSString stringWithFormat:@"%@ %@", [self.startDate componentsSeparatedByString:@"T"][0], [self.startDate componentsSeparatedByString:@"T"][1]];
    
}

- (NSString *)transformedEndDate {
    return [NSString stringWithFormat:@"%@ %@", [self.endDate componentsSeparatedByString:@"T"][0], [self.startDate componentsSeparatedByString:@"T"][1]];
    
}


@end
