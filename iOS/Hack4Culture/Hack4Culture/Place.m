//
//  Event.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "Place.h"

@implementation Place

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier":@"id",
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
