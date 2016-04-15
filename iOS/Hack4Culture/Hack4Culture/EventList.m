//
//  EventList.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "EventList.h"

@implementation EventList


+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSValueTransformer *)itemsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:Event.class];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"listSize":@"listSize",
             @"pageSize":@"pageSize",
             @"next":@"next",
             @"items":@"items"};
}

@end
