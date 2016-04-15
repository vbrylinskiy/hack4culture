//
//  Location.m
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"latitude":@"lattiude",
             @"longitude":@"longitude",
             @"defined":@"defined"
             };
}

@end
