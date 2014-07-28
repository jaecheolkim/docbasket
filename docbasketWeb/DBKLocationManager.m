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
#import "DocbasketService.h"

@interface DBKLocationManager ()
{
    
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *startTime;

@end

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
             
//             NSLog(@"\nCurrent Location Detected\n");
//
//             NSLog(@"Address : %@", Address);
//             NSLog(@"Area : %@", Area);
//             NSLog(@"subLocality : %@", subLocality);
//             NSLog(@"Name : %@", Name);
             
         }
         else
         {
             //NSLog(@"Geocode failed with error %@", error);
             
             currentAddress = @"";
 
         }

         //NSLog(@"%@",currentAddress);
         
         block(currentAddress);

     }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if([region containsCoordinate:GVALUE.currentLocation.coordinate]){
        Docbasket *findBasket = [GVALUE findGeoFenceBasketWithID:region.identifier];
        NSString *title = (IsEmpty(findBasket.title))?@"":findBasket.title;
        
        //NSString *title = findBasket.title;// [findBasket valueForKey:@"title"];
        if(state == CLRegionStateInside) {
            
            NSString *msg = [NSString stringWithFormat:@"DetermineState: %@ / %@", title, @"Enter"];
            [GVALUE addLog:msg];

            [DBKSERVICE pushLocalNotification:msg basket:findBasket];
        }
    }

}


//위치 정보 모니터링
/*
 
 Invalid locations - E.g. if the location is nil, or has a latitude and longitude of 0, or has a negative accuracy.  Note, these all sound unbelievable but they do happen!
 
 Old locations - Check the CLLocation.timestamp, and if it is older than 60 seconds, discard it.  This usually happens if the location service is turned off, then turned on 5 minutes later.  When the location service is turned on, it immediately calls the callback with the stale location from 5 minutes ago.  This is useful to get an initial position if plotting it on a map, but in cases when you’re not plotting a location on a map, this isn’t worth sending to the server
 
 Locations with bad accuracy - If the accuracy is bad enough, e.g. a few kilometres large, don’t bother sending it
 
 Overlapping locations - If the location you’re about to send is overlapping the last location sent, then you don’t really need to send it.  The distanceFilter I mentioned above should handle this, but I’ve found in iOS6 this is sometimes a little unreliable (especially if the accuracy is always changing) so this is just a little check you can add to make sure

 
*/
- (void)locationLog:(NSArray *)locations
{
    NSLog(@"check location=====%d======", (int)[locations count]);
    for(CLLocation *location in locations){
        double horizontalAccuracy = location.horizontalAccuracy;
        double verticalAccuracy = location.verticalAccuracy;
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = fabs([eventDate timeIntervalSinceNow]);
        double longitude = location.coordinate.longitude;
        double latitude = location.coordinate.latitude;
        
        NSLog(@"Location lat = %0.4f / long=%0.4f / howRecent = %0.f / hAccuracy = %0.f (desired = %0.f)/ vAccuracy = %0.f",
              latitude, longitude, howRecent, horizontalAccuracy, _locationManager.desiredAccuracy, verticalAccuracy);
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 가장 최근의 로케이션 정보 : [locations lastObject]
    // 가장 오래된 로케이션 정보 : [locations firstObject]
    [self locationLog:locations];
    
    if (!self.startTime) {
        self.startTime = [NSDate date];
        return; // ignore first attempt
    }
    
    CLLocation* newLocation = [locations lastObject];
    CLLocation* oldLocation = [locations firstObject];
    
    NSLog(@"speed = %f", newLocation.speed);
    
    if( newLocation.coordinate.latitude == 0 && newLocation.coordinate.latitude == 0) return;

    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if( abs(howRecent) > 15.0 ) return;

    if( newLocation.horizontalAccuracy < 0 ) return;
 
    if(!_isLocationServiceStarted)
    {
        
        GVALUE.currentLocation = newLocation;
        GVALUE.lastLocation = oldLocation;
        GVALUE.longitude = newLocation.coordinate.longitude;
        GVALUE.latitude = newLocation.coordinate.latitude;
        GVALUE.lastRegionDistanceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        GVALUE.lastAPICallLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        
        _isLocationServiceStarted = YES;

        NSString *event = [NSString stringWithFormat:@"checkGeoFence==F====== lat %+.6f / lon %+.6f ", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
        [GVALUE addLog:event];
        
        [DBKSERVICE checkGeoFence];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"locationServiceStarted", @"currentLocation":GVALUE.currentLocation}];
        
        
    } else {
        
        CLLocationDistance distance = [newLocation distanceFromLocation:GVALUE.lastLocation];
        NSLog(@"==> Distance : %0.f", distance);
        
        //일반적인 이동일때는 거리차가 이전보다 1m 이상일 때 다시 geofence 측정
        if(fabs(distance) > 1.0) {
 
            GVALUE.lastLocation = GVALUE.currentLocation;
            GVALUE.currentLocation = newLocation;
            GVALUE.longitude = newLocation.coordinate.longitude;
            GVALUE.latitude = newLocation.coordinate.latitude;
            
            [DBKSERVICE checkGeoFence];

            NSString *event = [NSString stringWithFormat:@"checkGeoFence==L====== lat %+.6f / lon %+.6f / distance ; %0.f",
                               newLocation.coordinate.latitude, newLocation.coordinate.longitude, distance];
            [GVALUE addLog:event];
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"locationChanged", @"currentLocation":GVALUE.currentLocation}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"refreshMapList"}];
            
        }
        
        
        
        // 마지막으로 baskets.json 호출 할 때 거리의 1/2이 지났을 때 baskets.json 다시 호출 해서 바스켓 새로 고침.
        distance = [newLocation distanceFromLocation:GVALUE.lastAPICallLocation];
        if(fabs(distance) > GVALUE.findBasketsRange/2){
            GVALUE.lastLocation = GVALUE.currentLocation;
            GVALUE.currentLocation = newLocation;
            GVALUE.longitude = newLocation.coordinate.longitude;
            GVALUE.latitude = newLocation.coordinate.latitude;
            
            NSString *event = [NSString stringWithFormat:@"NEW API CALL ==F== lat %+.6f / lon %+.6f\n",
                               newLocation.coordinate.latitude, newLocation.coordinate.longitude];
            [GVALUE addLog:event];
            
            [DBKSERVICE checkGeoFence];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"locationServiceStarted", @"currentLocation":GVALUE.currentLocation}];
        }
        
        
        
        
        // }
        
        
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            //[self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
        //}
        
    }
    

}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    Docbasket *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = (IsEmpty(findBasket.title))?@"": findBasket.title;
    
    NSString *event = [NSString stringWithFormat:@"didEnterRegion :  %@ at %f / %f", title, findBasket.latitude, findBasket.longitude]; //[NSDate date]
    //[self updateWithEvent:event];
    
    [DBKSERVICE pushLocalNotification:event basket:findBasket];
    
    NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":[NSDate date], @"checkout_at":@""};
    [DocbaketAPIClient postRegionCheck:parameters withBasketID:[findBasket valueForKey:@"basketID"]];
    
    [GVALUE addLog:event];

}

// 37.56202672  126.98963106
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    Docbasket *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = (IsEmpty(findBasket.title))?@"": findBasket.title;

    
    NSString *event = [NSString stringWithFormat:@"didExitRegion :  %@ at %f / %f", title, findBasket.latitude, findBasket.longitude]; //[NSDate date]
    //[self updateWithEvent:event];
    [DBKSERVICE pushLocalNotification:event basket:findBasket];
    
    NSDictionary *parameters = @{@"trans_id": @"", @"user_id": @"bb5774c9-2c4e-41d0-b792-530e295e1ca6", @"checkin_at":@"", @"checkout_at":[NSDate date]};
    [DocbaketAPIClient postRegionCheck:parameters withBasketID:[findBasket valueForKey:@"basketID"]];
    
 
    [GVALUE addLog:event];
 }

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    Docbasket *findBasket = [GVALUE findBasketWithID:region.identifier];
    if(!IsEmpty(findBasket)){
        NSString *title = (IsEmpty(findBasket.title))?@"":findBasket.title;
 
        
        NSString *msg = [NSString stringWithFormat:@"Now monitoring for %@", title];
        [GVALUE addLog:msg];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"refreshGeoFencePins", @"basket":findBasket}];

    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    Docbasket *findBasket = [GVALUE findBasketWithID:region.identifier];
    NSString *title = (IsEmpty(findBasket.title))?@"":findBasket.title;
 
    NSString *msg = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", title, error];
    [GVALUE addLog:msg];

}




#pragma mark - Public Methods

- (void)startLocationManager
{
    if(nil == self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //10;//kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
 
    [self.locationManager startUpdatingLocation];
    
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(count) userInfo:nil repeats:YES];

    self.isLocationServiceStarted = NO;
}


- (void)stopLocationManager
{
    [self.timer invalidate];
    self.timer = nil;
    _isLocationServiceStarted = NO;
}

- (void)count
{
    GVALUE.longitude = GVALUE.currentLocation.coordinate.longitude;
    GVALUE.latitude = GVALUE.currentLocation.coordinate.latitude;

    CLLocationDistance distance = [GVALUE.currentLocation distanceFromLocation:_lastLocation];
    NSLog(@"================== distance = %f", distance);
    
    
    [DBKLocationManager reverseGeocodeLocation:GVALUE.currentLocation completionHandler:^(NSString *address) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"currentAddress", @"address":address}];
    }];

//    [SQLManager getRegionBasketsDistance:0.5 latitude:GVALUE.latitude longitude:GVALUE.longitude];
//
//    
//    if(fabs(distance) > 3.0 ){
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
//                                                            object:self
//                                                          userInfo:@{@"Msg":@"locationChanged", @"currentLocation":_currentLocation}];
//        
//        
//
//    }
    //_lastLocation
    
    
    NSLog(@"geoFenceBaskets count = %d", (int)[GVALUE.geoFenceBaskets count]);

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
        [_locationManager stopUpdatingLocation];
        [_locationManager startMonitoringSignificantLocationChanges];
        

        [GVALUE addLog:@"startMonitoringSignificantLocationChanges"];
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
        
        [GVALUE addLog:@"stopMonitoringSignificantLocationChanges"];

    }
    else {
        NSLog(@"Significant location change monitoring is not available.");
    }
    
}


- (void)makeNewRegionMonitoring:( CLLocationCoordinate2D) coord withID:(NSString*)identifier withMap:(MKMapView*)mapView
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {

        CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coord
                                                                      radius:20
                                                                  identifier:identifier];
        
        newRegion.notifyOnEntry = YES;
        newRegion.notifyOnExit = YES;
        
        if(!IsEmpty(mapView)){
            // Create an annotation to show where the region is located on the map.
            RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
            myRegionAnnotation.coordinate = newRegion.center;
            myRegionAnnotation.radius = newRegion.radius;
            [mapView addAnnotation:myRegionAnnotation];
        }

        
        //[self startMonitoringRegion:newRegion];
    }

}

- (CLCircularRegion *)makeNewCircularRegion:(CLLocationCoordinate2D) coord withID:(NSString*)identifier
{
    CLCircularRegion *newRegion = nil;
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        newRegion = [[CLCircularRegion alloc] initWithCenter:coord radius:20 identifier:identifier];
        
        newRegion.notifyOnEntry = YES;
        newRegion.notifyOnExit = NO;
    }
    return newRegion;
}

- (void)cleanAllGeoFence
{
    NSArray *regions = [[_locationManager monitoredRegions] allObjects];
    for(CLRegion *region in regions){
        [self stopMonitoringRegion:region];
    }
}

- (void)startMonitoringRegion:(CLCircularRegion *)region
{
    NSString *msg = [NSString stringWithFormat:@"startMonitoringRegion: %@", region];
    [GVALUE addLog:msg];
    
    [_locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringRegion:(CLRegion *)region
{

    NSString *msg = [NSString stringWithFormat:@"stopMonitoringRegion: %@", region];
    [GVALUE addLog:msg];
    
    [_locationManager stopMonitoringForRegion:region];
    
}




@end
