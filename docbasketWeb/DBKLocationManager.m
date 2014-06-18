//
//  DBKLocationManager.m
//  Docbasket
//
//  Created by jaecheol kim on 5/22/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBKLocationManager.h"
#import "GlobalValue.h"

@implementation DBKLocationManager

+(DBKLocationManager*)sharedInstance
{
    static DBKLocationManager* locationMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationMgr = [[DBKLocationManager alloc] init];
    });
    return locationMgr;
}

-(id)init
{
    self = [super init];
    if (self){
        
        // Initialize CLLocationManager to receive updates in current location
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//
//        self.locationManager.delegate = self;
//        [self.locationManager requestWhenInUseAuthorization];
//        
//        [self.locationManager startUpdatingLocation];
        

//        // Create location manager with filters set for battery efficiency.
//        _locationManager = [[CLLocationManager alloc] init];
//
//        _locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        _locationManager.delegate = self;
//        
//        
//        // user activated automatic attraction info mode
//        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
//        if (authorizationStatus == kCLAuthorizationStatusDenied ||
//            authorizationStatus == kCLAuthorizationStatusNotDetermined) {
//            // present an alert indicating location authorization required
//            // and offer to take the user to Settings for the app via
//            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
//            //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
//            NSLog(@"please turn on Location setting ");
//        }
//        [_locationManager requestAlwaysAuthorization];
////        [_locationManager startMonitoringForRegion:region];

//        [self.locationManager startUpdatingLocation];
        
    }
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
    
//    // Work around a bug in MapKit where user location is not initially zoomed to.
//    if (oldLocation == nil) {
//        // Zoom to the current user location.
////        MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
////        [_mapView setRegion:userLocation animated:YES];
//    }
    
    
    _currentLocation = [locations objectAtIndex:0];
    //[_locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             NSLog(@"%@",CountryArea);
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
//             CountryArea = NULL;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];
    
    NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", title, [NSDate date]];
    
    [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];

    
    NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", title, [NSDate date]];
    
    [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];

    
    NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", title, error];
    
    [self updateWithEvent:event];
}



- (void)updateWithEvent:(NSString *)event {

    // Update the icon badge number.
    [UIApplication sharedApplication].applicationIconBadgeNumber++;

    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    // Create a new notification
    UILocalNotification *alarm = [[UILocalNotification alloc] init];
    if (alarm) {
        alarm.fireDate =  [NSDate dateWithTimeIntervalSinceNow:1];
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.alertBody = event;
        
        [app scheduleLocalNotification:alarm];
    }
    
    NSLog(@"Done.");
    
    if (![[defaults objectForKey:@"Helped the User"] isEqualToString:@"Yes"]) {
        UIAlertView *alert = [UIAlertView new];
        [alert initWithTitle:@"New Event!" message:@"Your got new event!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        [defaults setObject:@"Yes" forKey:@"Helped the User"];
        [defaults synchronize];
    }

}



#pragma mark - Public Methods

- (void)startLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.locationManager.delegate = self;
    //[self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];

}


- (CLLocationCoordinate2D)getCurrentCoordinate
{
    CLLocation *location = [_locationManager location];
    
    CLLocationCoordinate2D coord;
    coord.longitude = location.coordinate.longitude;
    coord.latitude = location.coordinate.latitude;
    // or a one shot fill
    coord = [location coordinate];
    
    return coord;
    
}


- (void)startMonitoringSignificantLocationChanges
{

    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // Stop normal location updates and start significant location change updates for battery efficiency.
        //[_locationManager stopUpdatingLocation];
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
}

- (void)stopMonitoringSignificantLocationChanges
{
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // Stop significant location updates and start normal location updates again since the app is in the forefront.
        [_locationManager stopMonitoringSignificantLocationChanges];
        //[_locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
    
}


- (void)makeNewRegionMonitoring:( CLLocationCoordinate2D) coord withID:(NSString*)identifier
{
    if ([CLLocationManager regionMonitoringAvailable]) {
        //CLLocationCoordinate2DMake(checkpoint.lat, checkpoint.lon);
        CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
                                                                      radius:100
                                                                  identifier:identifier];
        
        // Create an annotation to show where the region is located on the map.
        //    RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
        //    myRegionAnnotation.coordinate = newRegion.center;
        //    myRegionAnnotation.radius = newRegion.radius;
        //
        //    [_mapView addAnnotation:myRegionAnnotation];
        
        
        // Start monitoring the newly created region.
        [_locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
    }

}


- (void)startMonitoringRegion:(CLRegion *)region
{
    [_locationManager startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyBest];
}
- (void)stopMonitoringRegion:(CLRegion *)region
{
    [_locationManager stopMonitoringForRegion:region];
}



@end
