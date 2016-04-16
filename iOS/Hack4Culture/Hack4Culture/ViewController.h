//
//  ViewController.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *helpBox;
@property (weak, nonatomic) IBOutlet UILabel *helpText;
@property (weak, nonatomic) IBOutlet UISlider *slider;
- (IBAction)sliderDidChange:(id)sender;

@end

