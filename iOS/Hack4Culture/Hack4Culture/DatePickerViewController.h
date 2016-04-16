//
//  DatePickerViewController.h
//  Hack4Culture
//
//  Created by Prometheus on 4/16/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DatePickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)datePickerValueChanged:(UIDatePicker*)sender;

@end
