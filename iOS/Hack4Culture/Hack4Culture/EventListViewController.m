//
//  EventListViewController.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "EventListViewController.h"

@implementation EventListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [self.events[indexPath.row] offer][@"title"];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.;
}

- (void)presentPopoverPresentationControllerWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect {
    
    UIPopoverPresentationController *popoverController = self.popoverPresentationController;
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.sourceView = sourceView;
    popoverController.sourceRect = sourceRect;
    popoverController.delegate = self;
    
    [self.presentingController presentViewController:self animated:YES completion:nil];
    
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(nonnull UITraitCollection *)traitCollection {
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        return UIModalPresentationFullScreen;
    } else {
        return UIModalPresentationNone;
    }
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if ([self.delegate respondsToSelector:@selector(didDismissPopover)]) {
        [self.delegate didDismissPopover];
    }
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    if (style == UIModalPresentationPopover) {
        return self;
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(dismissPopover)];
        return nav;
    }
}

- (void)dismissPopover {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(didDismissPopover)]) {
            [self.delegate didDismissPopover];
        }
    }];
}


@end
