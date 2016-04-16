//
//  CategoryCell.h
//  Hack4Culture
//
//  Created by Prometheus on 4/16/16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *categorySwitch;
@property (nonatomic) NSInteger row;
- (IBAction)valueChanged:(UISwitch*)sender;
@end
