//
//  DBKLocationManager.m
//  Docbasket
//
//  Created by jaecheol kim on 5/22/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBKLocationManager.h"
#import "GlobalValue.h"
#import "RegionAnnotation.h"
#import "DocbaketAPIClient.h"
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
    }
    return self;
}

+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(void (^)(NSString *address))block
{
    if(IsEmpty(location)) block(@"");
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSString *currentAddress = @"";
         
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             //             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = IsEmpty(locatedAt)? @"" : locatedAt; // [[NSString alloc]initWithString:locatedAt];
             NSString *Area = IsEmpty(placemark.locality) ? @"" : placemark.locality; //[[NSString alloc]initWithString:placemark.locality];
             NSString *subLocality = IsEmpty(placemark.subLocality) ? @"" : placemark.subLocality; //[[NSString alloc]initWithString:(!IsEmpty(placemark.subLocality)?placemark.subLocality:@"")];
             //NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *Name = IsEmpty(placemark.name) ? @"" : placemark.name; //[[NSString alloc]initWithString:placemark.name];
             //NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             
             currentAddress = (!IsEmpty(Address))?Address : @"";
             
             NSLog(@"\nCurrent Location Detected\n");

             NSLog(@"Address : %@", Address);
             NSLog(@"Area : %@", Area);
             NSLog(@"subLocality : %@", subLocality);
             NSLog(@"Name : %@", Name);
             
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             
             currentAddress = @"";
 
         }
         
         
         NSLog(@"%@",currentAddress);
         
         block(currentAddress);

     }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    _currentLocation = [locations objectAtIndex:0];
    
    [DBKLocationManager reverseGeocodeLocation:_currentLocation completionHandler:^(NSString *address) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"currentAddress", @"address":address}];
    }];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];
    
    NSString *event = [NSString stringWithFormat:@"Enter :  %@ at %f / %f", title, [[findBasket valueForKey:@"latitude"] doubleValue], [[findBasket valueForKey:@"longitude"] doubleValue]]; //[NSDate date]
    [self updateWithEvent:event];
    
    
    NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":[NSDate date], @"checkout_at":@""};
    [DocbaketAPIClient postRegionCheck:parameters withBasketID:[findBasket valueForKey:@"basketID"]];
    
    NSLog(@"%@",event);
}

// 37.56202672  126.98963106
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];

    
    NSString *event = [NSString stringWithFormat:@"Exit :  %@ at %f / %f", title, [[findBasket valueForKey:@"latitude"] doubleValue], [[findBasket valueForKey:@"longitude"] doubleValue]]; //[NSDate date]
    [self updateWithEvent:event];
    
    NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"", @"checkout_at":[NSDate date]};
    [DocbaketAPIClient postRegionCheck:parameters withBasketID:[findBasket valueForKey:@"basketID"]];
    
    NSLog(@"%@",event);
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = [findBasket valueForKey:@"title"];
    NSLog(@"Now monitoring for %@", title);
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"monitoringDidFailForRegion", @"region":region}];
    
    
    NSString *title = [findBasket valueForKey:@"title"];

    
    NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", title, error];
    NSLog(@"%@",event);
    //[self updateWithEvent:event];
}



- (void)updateWithEvent:(NSString *)event {

    // Update the icon badge number.
    //[UIApplication sharedApplication].applicationIconBadgeNumber++;

    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *oldNotifications = [app scheduledLocalNotifications];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Clear out the old notification before scheduling a new one.
//    if ([oldNotifications count] > 0)
//        [app cancelAllLocalNotifications];
    
    // Create a new notification
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        noti.fireDate =  [NSDate dateWithTimeIntervalSinceNow:0.1];
        noti.timeZone = [NSTimeZone defaultTimeZone];
        //noti.repeatInterval = 0;
        noti.alertBody = event;
        noti.alertAction = @"GOGO";
        noti.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        [app presentLocalNotificationNow:noti];
    }
    
    NSLog(@"Done.");
    
}



#pragma mark - Public Methods




- (void)startLocationManager
{
    if(nil == self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 50;

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
    // Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;


    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // Stop normal location updates and start significant location change updates for battery efficiency.
        [_locationManager stopUpdatingLocation];
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
        [_locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
    
}


- (void)makeNewRegionMonitoring:( CLLocationCoordinate2D) coord withID:(NSString*)identifier withMap:(MKMapView*)mapView
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {

        CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                                      radius:50
                                                                  identifier:identifier];
        
        if(!IsEmpty(mapView)){
            // Create an annotation to show where the region is located on the map.
            RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
            myRegionAnnotation.coordinate = newRegion.center;
            myRegionAnnotation.radius = newRegion.radius;
            [mapView addAnnotation:myRegionAnnotation];
        }

        
        [self startMonitoringRegion:newRegion];
    }

}


- (void)startMonitoringRegion:(CLCircularRegion *)region
{
    NSLog(@"startMonitoringRegion: %@", region);
    [_locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringRegion:(CLRegion *)region
{
    NSLog(@"stopMonitoringRegion: %@", region);
    [_locationManager stopMonitoringForRegion:region];
}



@end
