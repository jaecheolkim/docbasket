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

- (void)checkIn:(Docbasket*)basket
{
    //라스트 체크인 바스켓에 먼저 저장하고
    [GVALUE setLastCheckInBasket:basket];
    GVALUE.lastCheckInBasket.checkInDate = [NSDate date];
    
    NSString *title = (IsEmpty(basket.title))?@"":basket.title;
    NSString *msg = [NSString stringWithFormat:@" %@ : %@", title, @"Enter !"];
    NSLog(@"GEOFENCE :: %@", msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 로컬 노티피케이션에 체크인 등록.
        [DBKSERVICE pushLocalNotification:msg basket:basket];
        
        // 서버에 체크인 정보 보내기.
        if(GVALUE.userID) {
            [DocbaketAPIClient postRegionCheck:nil withBasketID:[basket valueForKey:@"basketID"]];
        }
        
        
    });

}

- (void)checkGeoFence
{
    for(Docbasket *basket in GVALUE.geoFenceBaskets)
    {
        // 만약에 현재 위치의 지오펜스가 존재한다면
        if([basket.region containsCoordinate:GVALUE.currentLocation.coordinate])
        {
            //마지막 체크인 지오펜스가 있는지 검사한다.
            Docbasket *lastCheckInBasket = GVALUE.lastCheckInBasket;
            if(!IsEmpty(lastCheckInBasket)) {
                NSString *lastCheckInBasketID = lastCheckInBasket.basketID;
                double timeDuration = [lastCheckInBasket.checkInDate secondsAgo];
                
                //만약 마지막 체크인 한 지오펜스와 같다면 시간을 검사한다.
                if([basket.basketID isEqualToString:lastCheckInBasketID]){
                    if(timeDuration > GVALUE.checkInTimeFiler) { // 만약 24시간이 지났다면..
                      // 새롭게 해당 지오펜스 체크인 한다.
                        [self checkIn:basket];
                    }
                }
                //만약 마지막 체크인 한 지오펜스와 다르다면
                else {
                    // 새롭게 해당 지오펜스 체크인 한다.
                    [self checkIn:basket];
                }

            }
            // 만약 새로 체크인 하는 지오펜스 일 경우는
            else {
                // 새롭게 해당 지오펜스 체크인 한다.
                [self checkIn:basket];
            }
            
            break; // 진행하던 루프를 종료한다.
        }
    }
}

//위치 정보 모니터링
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    if(!_isLocationServiceStarted){
        
        GVALUE.currentLocation = location;
        GVALUE.longitude = location.coordinate.longitude;
        GVALUE.latitude = location.coordinate.latitude;
        GVALUE.lastRegionDistanceLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        GVALUE.lastAPICallLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        
        _isLocationServiceStarted = YES;

        NSString *event = [NSString stringWithFormat:@"checkGeoFence==F====== latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude];
        [GVALUE addLog:event];
        
        [self checkGeoFence];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"locationServiceStarted", @"currentLocation":GVALUE.currentLocation}];
        
        
    } else {
        // test the age of the location measurement to determine if the measurement is cached
        // in most cases you will not want to rely on cached measurements
        CLLocation* newLocation = [locations lastObject];
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        if (locationAge > 15.0) return;
        
        // test that the horizontal accuracy does not indicate an invalid measurement
        if (newLocation.horizontalAccuracy < 0) return;
        
        // test the measurement to see if it is more accurate than the previous measurement
        //if (GVALUE.currentLocation == nil || GVALUE.currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        
        NSDate* eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (abs(howRecent) < 30.0) {
            CLLocation *oldLocation = GVALUE.currentLocation;
            CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
            
            NSString *event = [NSString stringWithFormat:@"================== distance = %f", distance];
            [GVALUE addLog:event];
            
            
            //일반적인 이동일때는 거리차가 이전보다 1m 이상일 때 다시 geofence 측정
            if(fabs(distance) > 1.0) {
                GVALUE.lastLocation = GVALUE.currentLocation;
                GVALUE.currentLocation = newLocation;
                GVALUE.longitude = newLocation.coordinate.longitude;
                GVALUE.latitude = newLocation.coordinate.latitude;
                // If the event is recent, do something with it.
                
                NSString *event = [NSString stringWithFormat:@"checkGeoFence==L====== latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
                [GVALUE addLog:event];
                
                [self checkGeoFence];
                
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
                GVALUE.longitude = GVALUE.currentLocation.coordinate.longitude;
                GVALUE.latitude = GVALUE.currentLocation.coordinate.latitude;
                
                NSString *event = [NSString stringWithFormat:@"NEW API CALL ==F== latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
                [GVALUE addLog:event];
                
                [self checkGeoFence];
                
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
        }

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
    self.locationManager.distanceFilter = 10;//kCLDistanceFilterNone;
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
