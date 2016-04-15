//
//  Event.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "Event.h"

@implementation Event

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier":@"identifier",
             @"modified":@"modified",
             @"title":@"title",
             @"shortTitle":@"shortTitle",
             @"alias":@"alias",
             @"longDescription":@"longDescription",
             @"externalLink":@"externalLink",
             @"pageLink":@"pageLink",
             @"type":@"type",
             @"categories":@"categories",
             @"mainImage":@"mainImage",
             @"priority":@"priority",
             @"source":@"source",
             @"language":@"language",
             @"location":@"location",
             @"address":@"address",
             @"lastPublished":@"lastPublished"};
}

@end
