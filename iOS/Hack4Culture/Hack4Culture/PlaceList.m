//
//  EventList.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "PlaceList.h"

@implementation PlaceList

+ (NSValueTransformer *)itemsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:Place.class];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"listSize":@"listSize",
             @"pageSize":@"pageSize",
             @"next":@"next",
             @"items":@"items"};
}

@end
