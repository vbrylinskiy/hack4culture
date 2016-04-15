//
//  Event.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface Place : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSNumber *identifier;
@property (nonatomic, copy, readonly) NSString *modified;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *shortTitle;
@property (nonatomic, copy, readonly) NSString *alias;
@property (nonatomic, copy, readonly) NSString *longDescription;
@property (nonatomic, copy, readonly) NSString *externalLink;
@property (nonatomic, copy, readonly) NSString *pageLink;
@property (nonatomic, copy, readonly) NSDictionary *type;
@property (nonatomic, copy, readonly) NSArray *categories;
@property (nonatomic, copy, readonly) NSDictionary *mainImage;
@property (nonatomic, copy, readonly) NSNumber *priority;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, copy, readonly) NSDictionary *location;
@property (nonatomic, copy, readonly) NSDictionary *address;
@property (nonatomic, copy, readonly) NSString *lastPublished;


@end
