//
//  ViewController.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "ViewController.h"
@import MapKit;

@interface ViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButton;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];
    self.points = [NSMutableArray array];
    self.doneButton.enabled = NO;
    self.clearButton.enabled = NO;
}

- (IBAction)done:(id)sender {
    
}

- (IBAction)clear:(id)sender {
    [self.points removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateBarButtons];
}

- (void)updateBarButtons {
    if (self.points.count > 1) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
    
    if (self.points.count > 0) {
        self.clearButton.enabled = YES;
    } else {
        self.clearButton.enabled = NO;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.mapView];
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [self.points addObject:location];
    
    [self updateBarButtons];
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = coord;
    pointAnnotation.title = [NSString stringWithFormat:@"Annotation %i", [self.points indexOfObject:location]];
    pointAnnotation.subtitle = [location description];
    
    [[self mapView] addAnnotation:pointAnnotation];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
//        pinView.image = [UIImage imageNamed:@"pizza_slice_32.png"];
//        pinView.calloutOffset = CGPointMake(0, 32);
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}


@end
