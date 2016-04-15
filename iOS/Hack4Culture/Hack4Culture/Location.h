//
//  Location.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface Location : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSNumber *longitude;
@property (nonatomic, readonly) BOOL defined;
@end
