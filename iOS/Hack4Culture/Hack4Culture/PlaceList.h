//
//  EventList.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "Place.h"

@interface PlaceList : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSNumber *listSize;
@property (nonatomic, copy, readonly) NSNumber *pageSize;
@property (nonatomic, copy, readonly) NSString *next;
@property (nonatomic, copy, readonly) NSArray<Place*> *items;


@end
