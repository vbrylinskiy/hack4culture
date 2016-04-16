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
#import "EventAnnotation.h"
#import "Event.h"
#import "EventDetailsViewController.h"
#import "RequestHelper.h"

typedef NS_ENUM(NSUInteger, ConnectionType) {
    ConnectionTypeDirect,
    ConnectionTypeRoute
};

@interface ViewController () <MKMapViewDelegate, EventDetailsDelegate>

@property (nonatomic, weak) IBOutlet CustomMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSMutableArray *eventAnnotations;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) NSMutableArray *previousPolylines;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) EventImporterImpl *importer;
@property (nonatomic, strong) NSMutableSet *allEvents;

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
    self.eventAnnotations = [NSMutableArray array];
    self.allEvents = [NSMutableSet set];
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
    [self.mapView removeAnnotations:self.eventAnnotations];
    [self.eventAnnotations removeAllObjects];
    [self.allEvents removeAllObjects];
    
    UIActivityIndicatorView *uiBusy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    uiBusy.hidesWhenStopped = YES;
    [uiBusy startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:uiBusy];

    
    [self.importer importEventsForPolyline:self.polyline withBlock:^(NSSet *events, NSError *error) {
        
        self.allEvents = [NSMutableSet setWithSet:events];
        NSArray *cleanEvents = [self cleanEvents:events];
        
        for (Event *event in cleanEvents) {
            EventAnnotation *ann = [[EventAnnotation alloc] init];
            ann.event = event;
            ann.coordinate = CLLocationCoordinate2DMake([event.location[@"lattiude"] floatValue], [event.location[@"longitude"] floatValue]);
            [self.eventAnnotations addObject:ann];
        }
        
        [self.mapView addAnnotations:self.eventAnnotations];
        
        self.navigationItem.rightBarButtonItem = self.doneButton;
        [self updateBarButtons];
    }];
}

-(NSArray*) cleanEvents:(NSSet*) events {
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSUInteger count = self.polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(count * sizeof(CLLocationCoordinate2D));
    [self.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, count)];
    
    for (Event* event in events) {
        BOOL closeEnough = NO;
        for (int i = 0; i< count; i++) {
            CLLocation* routeLocation = [[CLLocation alloc] initWithLatitude:routeCoordinates[i].latitude longitude:routeCoordinates[i].longitude];
            CLLocation* eventLocation = [[CLLocation alloc] initWithLatitude:[event.location[@"lattiude"] floatValue] longitude:[event.location[@"longitude"] floatValue]];
            if ([routeLocation distanceFromLocation:eventLocation] < self.slider.value) {
                closeEnough = YES;
                break;
            }
        }
        if (closeEnough) {
//            BOOL isEventFiltered = NO;
//            for (NSString *key in [RequestHelper categorieFilters]) {
//                if (event.offer.)
//            }
            
            [array addObject:event];
        }
    }
    
    free(routeCoordinates);
             
    return array;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popoverSegue"] || [segue.identifier isEqualToString:@"categoriesSegue"]) {
        UIViewController *popoverViewController = segue.destinationViewController;
        popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
        popoverViewController.popoverPresentationController.delegate = self;
    }
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
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
//        pinView.animatesDrop = YES;
        pinView.canShowCallout = NO;
//        pinView.image = [UIImage imageNamed:@"pizza_slice_32.png"];
//        pinView.calloutOffset = CGPointMake(0, 32);
    } else {
        pinView.annotation = annotation;
    }
    
    if ([annotation isKindOfClass:[EventAnnotation class]]) {
        pinView.pinTintColor = [UIColor colorWithRed:70./255 green:171./255 blue:183./255 alpha:1.];
    } else {
        pinView.pinTintColor = [UIColor orangeColor];
    }
    
    return pinView;
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    lineView.strokeColor = [UIColor orangeColor];
    lineView.lineWidth = 7;
    return lineView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[EventAnnotation class]]) {
        EventDetailsViewController *popoverController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
        popoverController.preferredContentSize = CGSizeMake(300.0, 500.0);
        popoverController.delegate = self;
        popoverController.modalPresentationStyle = UIModalPresentationPopover;
        popoverController.event = [(EventAnnotation *)view.annotation event];
        popoverController.presentingController = self;
        [popoverController presentPopoverPresentationControllerWithSourceView:self.mapView sourceRect:view.frame];
    }
}

- (IBAction)changeType:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    } else {
        self.mapView.mapType = MKMapTypeSatellite;
    }
}

-(void)didDismissPopover {
    [self.mapView deselectAnnotation:[self.mapView.selectedAnnotations firstObject] animated:NO];
}

- (IBAction)sliderDidChange:(id)sender {
    
    [self.mapView removeAnnotations:self.eventAnnotations];
    [self.eventAnnotations removeAllObjects];
    
    NSArray *cleanEvents = [self cleanEvents:self.allEvents];
        
    for (Event *event in cleanEvents) {
        EventAnnotation *ann = [[EventAnnotation alloc] init];
        ann.event = event;
        ann.coordinate = CLLocationCoordinate2DMake([event.location[@"lattiude"] floatValue], [event.location[@"longitude"] floatValue]);
        [self.eventAnnotations addObject:ann];
    }

    [self.mapView addAnnotations:self.eventAnnotations];
}
@end
