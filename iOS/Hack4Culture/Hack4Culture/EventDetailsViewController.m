//
//  EventDetailsViewController.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 16.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "EventDetailsViewController.h"
#import <UIImageView+AFNetworking.h>
#import <EventKit/EventKit.h>

@interface EventDetailsViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;

@end

@implementation EventDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.modalPresentationStyle = UIModalPresentationPopover;
    self.titleLabel.text = self.event.offer[@"title"];
    NSString* source = self.event.offer[@"longDescription"];
    NSString *aux = [NSString stringWithFormat:@"<span style=\"font-family: HelveticaNeue-Thin; font-size: 17\">%@</span>", source];

    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData:[aux dataUsingEncoding:NSUTF8StringEncoding]
                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType , NSFontAttributeName : [UIFont systemFontOfSize:16.]}
                                            documentAttributes: nil
                                            error: nil
                                            ];
    self.descriptionTextView.attributedText = attributedString;

    self.descriptionTextView.editable = NO;
    self.descriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.dateLabel.text = [NSString stringWithFormat:@"From %@", [self.event transformedStartDate]];
    self.endDateLabel.text = [NSString stringWithFormat:@"To %@", [self.event transformedEndDate]];

    [self.imageView setImageWithURL:[NSURL URLWithString:self.event.offer[@"mainImage"][@"tile"]]];
}

- (void)presentPopoverPresentationControllerWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect {

    UIPopoverPresentationController *popoverController = self.popoverPresentationController;
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.sourceView = sourceView;
    popoverController.sourceRect = sourceRect;
    popoverController.delegate = self;
    
    [self.presentingController presentViewController:self animated:YES completion:nil];

}

- (IBAction)readMore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.offer[@"pageLink"]]];
}
- (IBAction)addToCalendar:(id)sender {
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = self.event.offer[@"title"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
        
        event.startDate = [dateFormatter dateFromString:self.event.startDate];
        event.endDate = [dateFormatter dateFromString:self.event.endDate];
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];
}

#pragma mark - UIPopoverPresentationControllerDelegate

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
