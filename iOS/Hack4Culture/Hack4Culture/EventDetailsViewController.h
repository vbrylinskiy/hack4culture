//
//  EventDetailsViewController.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol EventDetailsDelegate <NSObject>

- (void)didDismissPopover;

@end

@interface EventDetailsViewController : UITableViewController

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) UIViewController *presentingController;
@property (nonatomic, weak) id <EventDetailsDelegate> delegate;

- (void)presentPopoverPresentationControllerWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect;

@end
