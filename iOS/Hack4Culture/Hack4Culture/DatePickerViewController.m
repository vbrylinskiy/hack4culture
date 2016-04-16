//
//  DatePickerViewController.m
//  Hack4Culture
//
//  Created by Prometheus on 4/16/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "DatePickerViewController.h"
#import "RequestHelper.h"

@implementation DatePickerViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.datePicker setDate:[NSDate dateWithTimeIntervalSince1970:[RequestHelper maxDate]]];
}

- (IBAction)datePickerValueChanged:(UIDatePicker*)sender {
    [RequestHelper setMaxDate:sender.date.timeIntervalSince1970];
}

@end
