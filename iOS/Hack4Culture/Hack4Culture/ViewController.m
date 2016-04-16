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
#import "BikesImporter.h"
#import "GroupedEventAnnotation.h"
#import "EventListViewController.h"

#define CLCOORDINATE_EPSILON 0.0000000005f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)


typedef NS_ENUM(NSUInteger, ConnectionType) {
    ConnectionTypeDirect,
    ConnectionTypeRoute
};

@interface ViewController () <MKMapViewDelegate, EventDetailsDelegate, EventListViewDelegate>

@property (nonatomic, weak) IBOutlet CustomMapView *mapView;
@property (nonatomic, strong) NSMutableArray <id <MKAnnotation>> *annotations;
@property (nonatomic, strong) NSMutableArray *eventAnnotations;
@property (nonatomic, strong) NSMutableArray *groupedEventAnnotations;
@property (nonatomic, strong) NSArray *bikeAnnotations;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) NSMutableArray *previousPolylines;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) EventImporterImpl *importer;
@property (nonatomic, strong) NSMutableSet *allEvents;
@property (nonatomic, assign) BOOL resultIsShown;

@end

@implementation ViewController


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("com.requests.queue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoriesDidChange) name:@"CategoriesChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewTap:) name:MapViewDidTapMap object:self.mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewLongTap:) name:MapViewDidLongTapMap object:self.mapView];
    
    self.annotations = [NSMutableArray array];
    self.previousPolylines = [NSMutableArray array];
    self.eventAnnotations = [NSMutableArray array];
    self.groupedEventAnnotations = [NSMutableArray array];
    self.allEvents = [NSMutableSet set];
    self.doneButton.enabled = NO;
    self.clearButton.enabled = NO;
    self.undoButton.enabled = NO;
    
    [self importBikes];
    
    MKMapCamera *camera = [self.mapView.camera copy];
    camera.centerCoordinate = CLLocationCoordinate2DMake(51.109633, 17.032053);
    camera.altitude = 1000.;
    [self.mapView setCamera:camera];
    self.importer = [[EventImporterImpl alloc] init];
}

- (void)importBikes {
    self.bikeAnnotations = [BikesImporter importBikes];
    [self.mapView addAnnotations:self.bikeAnnotations];
}

- (IBAction)done:(id)sender {
//    for (int i = 0; i < self.polyline.pointCount; i++) {
//        NSLog(@"%@", MKStringFromMapPoint(self.polyline.points[i]));
//    }
    
    [self.mapView removeAnnotations:self.eventAnnotations];
    [self.mapView removeAnnotations:self.groupedEventAnnotations];
    [self.eventAnnotations removeAllObjects];
    [self.groupedEventAnnotations removeAllObjects];
    [self.allEvents removeAllObjects];
    
    UIActivityIndicatorView *uiBusy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    uiBusy.hidesWhenStopped = YES;
    [uiBusy startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:uiBusy];
    
    [self.importer importEventsForPolyline:self.polyline withBlock:^(NSSet *events, NSError *error) {
        
        if (!error && [events count] > 0) {
            self.allEvents = [NSMutableSet setWithSet:events];
            NSArray *cleanEvents = [self cleanEvents:events];
            
            for (Event *event in cleanEvents) {
                EventAnnotation *ann = [[EventAnnotation alloc] init];
                ann.event = event;
                ann.coordinate = CLLocationCoordinate2DMake([event.location[@"lattiude"] floatValue], [event.location[@"longitude"] floatValue]);
                [self.eventAnnotations addObject:ann];
            }
            
            [self groupEvents];
            
            [self.mapView addAnnotations:self.eventAnnotations];
            [self.mapView addAnnotations:self.groupedEventAnnotations];
            
            self.navigationItem.rightBarButtonItem = self.doneButton;
        }
        
        self.resultIsShown = YES;
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
            // category filtering
            for (int i=0; i < [[RequestHelper categorieFilters] count]; i++) {
                if ([[[RequestHelper categorieFilters] objectAtIndex:i] boolValue]) {//if filter active
                    if ([[event.offer objectForKey:@"type"] objectForKey:@"id"]// if id matches
                        == [[RequestHelper categories] objectForKey:[[[RequestHelper categories] allKeys] objectAtIndex:i]]) {
                        [array addObject:event];
                        break;
                    }
                }
            }
        }
    }
    
    free(routeCoordinates);
             
    return array;
}

- (IBAction)clear:(id)sender {
    self.resultIsShown = NO;
    [self.annotations removeAllObjects];
    [self.previousPolylines removeAllObjects];
    self.polyline = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addAnnotations:self.bikeAnnotations];
    [self updateBarButtons];
    
    [UIView transitionWithView:self.helpBox duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self.helpBox.hidden = NO;
    } completion:nil];
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
    if (self.annotations.count > 1 && !self.resultIsShown) {
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
    
    if (self.resultIsShown)
        return;
    
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
    if (self.annotations.count < 2) {
        return;
    }
    [UIView transitionWithView:self.helpBox duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self.helpBox.hidden = YES;
    } completion:nil];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addOverlay:self.polyline];
    });
}

- (void)mapViewLongTap:(NSNotification*)notif {
    
    CGPoint point = [self.mapView.longPressGesture locationInView:self.mapView];
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];

    id v = [self.mapView hitTest:point withEvent:nil];
    
    if ([v isKindOfClass:[MKPinAnnotationView class]]) {
        [self.mapView selectAnnotation:[v annotation] animated:YES];
        return;
    }
    
    if (self.resultIsShown)
        return;

    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = coord;
    
    [[self mapView] addAnnotation:pointAnnotation];
    [self.annotations addObject:pointAnnotation];
    
    [self addRouteToLastPointWithType:ConnectionTypeDirect];
    [self updateBarButtons];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[Bike class]]) {
        MKAnnotationView *pinView = nil;
        static NSString *defaultPinID = @"com.pin";
        pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
        pinView = [[MKAnnotationView alloc]
                   initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        //pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        //pinView.animatesDrop = YES;
        pinView.image = [UIImage imageNamed:@"bike.png"];
        
        return pinView;
    } else {
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
        } else if ([annotation isKindOfClass:[GroupedEventAnnotation class]]) {
            pinView.pinTintColor = [UIColor redColor];
        } else {
            pinView.pinTintColor = [UIColor orangeColor];
        }
        
        return pinView;
    }
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    lineView.strokeColor = [UIColor orangeColor];
    lineView.lineWidth = 3;
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
    } else if ([view.annotation isKindOfClass:[GroupedEventAnnotation class]]) {
        EventListViewController *popoverController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventListViewController"];
        popoverController.preferredContentSize = CGSizeMake(300.0, 500.0);
        popoverController.delegate = self;
        popoverController.modalPresentationStyle = UIModalPresentationPopover;
        popoverController.events = [(GroupedEventAnnotation *)view.annotation events];
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
    [self.mapView removeAnnotations:self.groupedEventAnnotations];
    
    [self.eventAnnotations removeAllObjects];
    [self.groupedEventAnnotations removeAllObjects];
    
    NSArray *cleanEvents = [self cleanEvents:self.allEvents];
        
    for (Event *event in cleanEvents) {
        EventAnnotation *ann = [[EventAnnotation alloc] init];
        ann.event = event;
        ann.coordinate = CLLocationCoordinate2DMake([event.location[@"lattiude"] floatValue], [event.location[@"longitude"] floatValue]);
        [self.eventAnnotations addObject:ann];
    }
    
    [self groupEvents];

    [self.mapView addAnnotations:self.eventAnnotations];
    [self.mapView addAnnotations:self.groupedEventAnnotations];
}

-(void) categoriesDidChange {
    
    [self.mapView removeAnnotations:self.eventAnnotations];
    [self.mapView removeAnnotations:self.groupedEventAnnotations];
    
    [self.eventAnnotations removeAllObjects];
    [self.groupedEventAnnotations removeAllObjects];

    NSArray *cleanEvents = [self cleanEvents:self.allEvents];
    
    for (Event *event in cleanEvents) {
        EventAnnotation *ann = [[EventAnnotation alloc] init];
        ann.event = event;
        ann.coordinate = CLLocationCoordinate2DMake([event.location[@"lattiude"] floatValue], [event.location[@"longitude"] floatValue]);
        [self.eventAnnotations addObject:ann];
    }
    
    [self groupEvents];

    
    [self.mapView addAnnotations:self.eventAnnotations];
    [self.mapView addAnnotations:self.groupedEventAnnotations];
}

- (void)groupEvents {
    NSMutableArray *alreadyInGroup = [NSMutableArray array];
    for (int i = 0; i < self.eventAnnotations.count; ++i) {
        
        id <MKAnnotation> ann = self.eventAnnotations[i];
        
        if ([alreadyInGroup containsObject:ann])
            continue;
        
        NSMutableArray *group = [NSMutableArray array];
        for (int j = i + 1; j < self.eventAnnotations.count; j++) {
            id <MKAnnotation> ann2 = self.eventAnnotations[j];

            if ([alreadyInGroup containsObject:ann2]) {
                continue;
            } else {
                NSLog(@"%f %f \n %f %f", [ann coordinate].latitude, [ann coordinate].longitude, [ann2 coordinate].latitude, [ann2 coordinate].longitude);
                if (CLCOORDINATES_EQUAL2([ann coordinate], [ann2 coordinate])) {
                    [group addObject:ann2];
                    [alreadyInGroup addObject:ann2];
                }
            }
        }
        
        if (group.count > 0) {
            [alreadyInGroup addObject:ann];
            [group addObject:ann];
            GroupedEventAnnotation *groupAnn = [[GroupedEventAnnotation alloc] init];
            groupAnn.coordinate = ann.coordinate;
            groupAnn.events = [group valueForKey:@"event"];
            [self.groupedEventAnnotations addObject:groupAnn];
        }
    }
    
    [self.eventAnnotations removeObjectsInArray:alreadyInGroup];
    
}


@end
