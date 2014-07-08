//
//  DocbasketService.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/3/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DocbasketService.h"

@interface DocbasketService ()
{
    
}
@end

@implementation DocbasketService

+(DocbasketService*)sharedInstance
{
    static DocbasketService* serviceMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceMgr = [[DocbasketService alloc] init];
    });
    return serviceMgr;
}

-(id)init
{
    self = [super init];
    if (self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ServiceEventHandler:)
                                                     name:@"ServiceEventHandler" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ServiceEventHandler" object:nil];
}


- (void)startmanager
{
    [SQLManager initDataBase];
    
    [DBKLOCATION startLocationManager];

    [self checkNewBasket:nil];
    
    [self loadBasketsFromDB];
    

//    [DocbaketAPIClient getZipBasket:^(id result) {
//        if(!IsEmpty(result)){
//            for(NSDictionary *jsonData in result) {
//                [SQLManager syncDocBaskets2DB:jsonData];
//            }
//        } else {
//            NSLog(@"Error ");
//        }
//    }];
}


- (void)stopManager
{
    [DBKLOCATION stopLocationManager];
}

#pragma mark - Application's Cookie Handler
- (void)ServiceEventHandler:(NSNotification *)notification
{
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"locationChanged"])
    {
        CLLocation *currentLocation = [[notification userInfo] objectForKey:@"currentLocation"];
        if(!IsEmpty(currentLocation)) {

            double longitude = currentLocation.coordinate.longitude;
            double latitude =  currentLocation.coordinate.latitude;

        
            
            [DocbaketAPIClient postUserTracking:@{@"longitude":@(longitude), @"latitude":@(latitude)}];

            

        }
    }
    


    
    
}

//CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
//double distance = [loc1 getDistanceFrom:position2];
//if(distance <= 10)

- (void)loadBasketsFromDB
{
    NSArray *baskets = [SQLManager getDocBasketsForQuery:@"SELECT * FROM Docbasket;"];
    if(!IsEmpty(baskets)){
        [GVALUE setBaskets:baskets];
        
        //[self loadBasketsOnMap];
        
        // DB에 있는 걸로 맵 다시 정의
        // 만약 새로운 맵이 있다면
        
    } else {
        [DocbaketAPIClient getZipBasket:^(id result) {
            if(!IsEmpty(result)){
                for(NSDictionary *jsonData in result) {
                    [SQLManager syncDocBaskets2DB:jsonData completionHandler:^(BOOL success) {
                        if(success){
                            
                                //[self loadBasketsOnMap];
                            
                        } else {
                            
                        }
                    }];
                }
            } else {
                NSLog(@"Error ");
            }
        }];
    }

}


- (void)checkNewBasket:(CLLocation *)currentLocation
{
    [DocbaketAPIClient checkNewDocBaskets:(CLLocation *)currentLocation completionHandler:^(BOOL success)
    {
        if(success)
        {
            //[self loadBasketsOnMap];
            
        } else {
            NSLog(@"Load Baskets : FAIL");
        }
    }];
    
}

- (void)loadBasketsOnMap
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Basket count = %d", (int)[GVALUE.baskets count]);
        
//        [DBKLOCATION cleanAllMonitoringRegions];
        
//        for(Docbasket *basket in GVALUE.baskets){
//            if(!IsEmpty(basket)){
//                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(basket.latitude, basket.longitude);
//                [[DBKLocationManager sharedInstance] makeNewRegionMonitoring:coord withID:basket.basketID withMap:nil];
//            }
//        }
//        
//        NSArray *regions = [[[DBKLocationManager sharedInstance].locationManager monitoredRegions] allObjects];
//        NSLog(@"->Load %d regions : %@", (int)regions.count, regions );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"refreshMap"}];
    });
}


- (void)pushLocalNotification:(NSString *)event
{
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        noti.fireDate =  [NSDate dateWithTimeIntervalSinceNow:0.1];
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.alertBody = event;
        noti.alertAction = @"GOGO";
        noti.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [app presentLocalNotificationNow:noti];
    }
    
    NSLog(@"Done.");
}




@end
