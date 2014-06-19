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

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void)startLocationManager;

- (void)startMonitoringSignificantLocationChanges;

- (void)stopMonitoringSignificantLocationChanges;

- (CLLocationCoordinate2D)getCurrentCoordinate;

- (void)makeNewRegionMonitoring:( CLLocationCoordinate2D) coord withID:(NSString*)identifier withMap:(MKMapView*)mapView;

- (void)startMonitoringRegion:(CLRegion *)region;
- (void)stopMonitoringRegion:(CLRegion *)region;

@end


