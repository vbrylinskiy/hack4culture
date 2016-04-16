//
//  CategoryCell.m
//  Hack4Culture
//
//  Created by Prometheus on 4/16/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "CategoryCell.h"
#import "RequestHelper.h"

@implementation CategoryCell

- (IBAction)valueChanged:(UISwitch*)sender {
    [RequestHelper updateFilterAtIndex:self.row withValue:[NSNumber numberWithBool:sender.isOn]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoriesChanged" object:self];
}
@end
