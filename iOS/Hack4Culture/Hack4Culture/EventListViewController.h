//
//  EventListViewController.h
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol EventListViewDelegate <NSObject>

- (void)didDismissPopover;

@end


@interface EventListViewController : UITableViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSArray <Event *> *events;
@property (nonatomic, strong) UIViewController *presentingController;
@property (nonatomic, weak) id <EventListViewDelegate> delegate;

- (void)presentPopoverPresentationControllerWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect;

@end
