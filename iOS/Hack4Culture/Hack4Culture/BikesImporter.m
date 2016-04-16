//
//  BikesImporter.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "BikesImporter.h"

@implementation Bike

@end

@implementation BikesImporter

+ (NSArray <Bike *> *)importBikes {
    NSMutableArray *result = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bikes-light" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    for (NSDictionary *dict in json[@"places"]) {
        Bike *bike = [[Bike alloc] init];
        bike.title = dict[@"name"];
        bike.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] floatValue], [dict[@"lng"] floatValue]);
        [result addObject:bike];
    }
    
    return [result copy];
}

@end
