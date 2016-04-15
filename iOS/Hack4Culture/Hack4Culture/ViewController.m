//
//  ViewController.m
//  Hack4Culture
//
//  Created by Vladislav Brylinskiy on 15.04.16.
//  Copyright © 2016 Triad. All rights reserved.
//

#import "ViewController.h"
@import MapKit;
#import "CustomMapView.h"
#import "EventImporterImpl.h"

typedef NS_ENUM(NSUInteger, ConnectionType) {
    ConnectionTypeDirect,
    ConnectionTypeRoute
};

@interface ViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet CustomMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) NSMutableArray *previousPolylines;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) EventImporterImpl *importer;

@end

@implementation ViewController


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("com.requests.queue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewTap:) name:MapViewDidTapMap object:self.mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewLongTap:) name:MapViewDidLongTapMap object:self.mapView];
    
    self.annotations = [NSMutableArray array];
    self.previousPolylines = [NSMutableArray array];
    self.doneButton.enabled = NO;
    self.clearButton.enabled = NO;
    self.undoButton.enabled = NO;
    
    MKMapCamera *camera = [self.mapView.camera copy];
    camera.centerCoordinate = CLLocationCoordinate2DMake(51.109633, 17.032053);
    camera.altitude = 1000.;
    [self.mapView setCamera:camera];
    self.importer = [[EventImporterImpl alloc] init];
}

- (IBAction)done:(id)sender {
//    for (int i = 0; i < self.polyline.pointCount; i++) {
//        NSLog(@"%@", MKStringFromMapPoint(self.polyline.points[i]));
//    }
    [self.importer importEventsForPolyline:self.polyline withBlock:^(NSSet *events, NSError *error) {
        NSLog(@"%@", events);
    }];
}

- (IBAction)clear:(id)sender {
    [self.annotations removeAllObjects];
    [self.previousPolylines removeAllObjects];
    self.polyline = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self updateBarButtons];
}

- (IBAction)undo:(id)sender {
    self.polyline = [self.previousPolylines lastObject];
    [self.previousPolylines removeLastObject];
    [self.mapView removeAnnotation:[self.annotations lastObject]];
    [self.annotations removeLastObject];
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.polyline)
        [self.mapView addOverlay:self.polyline];
    [self updateBarButtons];
}

- (void)updateBarButtons {
    if (self.annotations.count > 1) {
        self.doneButton.enabled = YES;
        self.undoButton.enabled = YES;
    } else {
        self.undoButton.enabled = NO;
        self.doneButton.enabled = NO;
    }
    
    if (self.annotations.count > 0) {
        self.clearButton.enabled = YES;
    } else {
        self.clearButton.enabled = NO;
    }
}

- (void)mapViewTap:(NSNotification*)notif {
    
    CGPoint point = [self.mapView.tapGesture locationInView:self.mapView];
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    id v = [self.mapView hitTest:point withEvent:nil];
    
    if ([v isKindOfClass:[MKPinAnnotationView class]]) {
        [self.mapView selectAnnotation:[v annotation] animated:YES];
        return;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = coord;
    pointAnnotation.title = [NSString stringWithFormat:@"Annotation %i", [self.annotations indexOfObject:location]];
    pointAnnotation.subtitle = [location description];
    
    [[self mapView] addAnnotation:pointAnnotation];
    [self.annotations addObject:pointAnnotation];
    
    [self addRouteToLastPointWithType:ConnectionTypeRoute];
    [self updateBarButtons];
}

- (void)addRouteToLastPointWithType:(ConnectionType)type {
    if (self.annotations.count < 2)
        return;
    
    dispatch_async(self.queue, ^{
        if (type == ConnectionTypeRoute) {
            MKMapItem* mapItemSrc = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:[(MKPointAnnotation *)self.annotations[self.annotations.count-2] coordinate] addressDictionary:nil]];
            MKMapItem *mapItemDst = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:[(MKPointAnnotation *)self.annotations[self.annotations.count-1] coordinate] addressDictionary:nil]];
            
            MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
            [directionsRequest setTransportType:MKDirectionsTransportTypeWalking];
            [directionsRequest setSource:mapItemSrc];
            [directionsRequest setDestination:mapItemDst];
            
            MKDirections *direction = [[MKDirections alloc] initWithRequest:directionsRequest];
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            [direction calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
                if (!error && response.routes.count > 0) {
                    MKRoute *route = [response.routes firstObject];
                    [self addPolyline:route.polyline];
                } else {
                    [self addDirectRoute];
                }
                dispatch_semaphore_signal(sema);
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else if (type == ConnectionTypeDirect) {
            [self addDirectRoute];
        }
    });
}

- (void)addDirectRoute {
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)calloc(2, sizeof(CLLocationCoordinate2D));
    
    coordinates[0] = [[self.annotations objectAtIndex:self.annotations.count - 2] coordinate];
    coordinates[1] = [[self.annotations objectAtIndex:self.annotations.count - 1] coordinate];

    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
    
    free(coordinates);
    
    [self addPolyline:polyline];
}

- (void)addPolyline:(MKPolyline *)polyline {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    NSUInteger pointsCount = self.polyline.pointCount + polyline.pointCount;
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)calloc(pointsCount, sizeof(CLLocationCoordinate2D));
    
    for (int i=0; i < self.polyline.pointCount; i++) {
        coordinates[i] = MKCoordinateForMapPoint(self.polyline.points[i]);
    }
    
    for (int i=0; i < polyline.pointCount; i++) {
        coordinates[i+self.polyline.pointCount] = MKCoordinateForMapPoint(polyline.points[i]);
    }
    
    if (self.polyline)
        [self.previousPolylines addObject:self.polyline];
    
    // create a polyline with all cooridnates
    self.polyline = [MKPolyline polylineWithCoordinates:coordinates count:pointsCount];
    
    free(coordinates);
    
    [self.mapView addOverlay:self.polyline];
}

- (void)mapViewLongTap:(NSNotification*)notif {
    
    CGPoint point = [self.mapView.longPressGesture locationInView:self.mapView];
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];

    id v = [self.mapView hitTest:point withEvent:nil];
    
    if ([v isKindOfClass:[MKPinAnnotationView class]]) {
        [self.mapView selectAnnotation:[v annotation] animated:YES];
        return;
    }
    
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
//    [self.annotations addObject:location];
    
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = coord;
    
    [[self mapView] addAnnotation:pointAnnotation];
    [self.annotations addObject:pointAnnotation];
    
    [self addRouteToLastPointWithType:ConnectionTypeDirect];
    [self updateBarButtons];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = NO;
//        pinView.image = [UIImage imageNamed:@"pizza_slice_32.png"];
//        pinView.calloutOffset = CGPointMake(0, 32);
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    lineView.strokeColor = [UIColor colorWithRed:70./255 green:171./255 blue:183./255 alpha:1.];
    lineView.lineWidth = 7;
    return lineView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"here");
}

- (IBAction)changeType:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    } else {
        self.mapView.mapType = MKMapTypeSatellite;
    }
}

@end
