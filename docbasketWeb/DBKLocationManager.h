//
//  DBKLocationManager.h
//  Docbasket
//
//  Created by jaecheol kim on 5/22/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define DBKLOCATION [DBKLocationManager sharedInstance]

@interface DBKLocationManager : NSObject <CLLocationManagerDelegate>

+(DBKLocationManager*)sharedInstance;

// physical location
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (nonatomic, assign) BOOL isLocationServiceStarted;
//
//// maps location
//@property (nonatomic, assign) CLLocationCoordinate2D mapCenterCoordinate2D;
//@property (nonatomic, retain) CLLocation *mapCenterLocation;



- (void)startLocationManager;
- (void)stopLocationManager;

- (void)startMonitoringSignificantLocationChanges;

- (void)stopMonitoringSignificantLocationChanges;

- (CLLocationCoordinate2D)getCurrentCoordinate;

- (void)makeNewRegionMonitoring:( CLLocationCoordinate2D) coord withID:(NSString*)identifier withMap:(MKMapView*)mapView;
- (CLCircularRegion *)makeNewCircularRegion:(CLLocationCoordinate2D) coord withID:(NSString*)identifier;

- (void)startMonitoringRegion:(CLCircularRegion *)region;
- (void)stopMonitoringRegion:(CLRegion *)region;
- (void)cleanAllGeoFence;

+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(void (^)(NSString *address))block;

@end


