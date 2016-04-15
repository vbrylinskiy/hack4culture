//
//  RequestHelper.h
//  Hack4Culture
//
//  Created by Prometheus on 4/15/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "EventList.h"

@interface RequestHelper : NSObject
@property (strong, nonatomic) AFURLSessionManager *manager;

- (void) fetchIdentifiersForLat:(CGFloat) lat lon:(CGFloat) lon withBlock:(void (^)(EventList* list))block;
@end
