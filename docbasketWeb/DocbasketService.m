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

#pragma mark - Class LifeCycle

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

// 시나리오
// [0]  DB및 Location Mananger 구동
// [1]  처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 바스킷 DB에 저장한다. 기본 현재 위치기준 10000m 반경(10km)
// [2]  1단계가 끝나면 바스킷 DB에서 기본 10m반경에 있는 바스킷을 가지고와서 지오팬싱 모니터링 건 후에 맴 리프레쉬 해줌.
//      만약 이전에 검사했던 위치와 현재 위치 거리가 GVALUE.regionMonitoringDistance 보다 작으면 스킵
//      아니면 새로 모니터링할 지오팬싱 리스트를 가지고 온다.


#pragma mark - ServiceEventHandler
- (void)ServiceEventHandler:(NSNotification *)notification
{
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"locationServiceStarted"])
    {
        CLLocation *currentLocation = [[notification userInfo] objectForKey:@"currentLocation"];
        if(!IsEmpty(currentLocation)) {
            
            // [1] 처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 DB에 저장한다.
            // 앱이 구동되고 Location service가 스타트 되면 체크 함.
            [self checkNewBasket:currentLocation filter:@"public" completionHandler:^(BOOL success) {
                if(success){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        GVALUE.lastAPICallLocation = GVALUE.currentLocation;
                        
                        [self refreshGeoFenceMonitoring];
                        
                        double longitude = currentLocation.coordinate.longitude;
                        double latitude =  currentLocation.coordinate.latitude;
                        
                        [DocbaketAPIClient postUserTracking:@{@"longitude":@(longitude), @"latitude":@(latitude)}];
                    });
                } else {
                    
                }
                
                [self loadBasketsOnMap];
            }];
        }
    }
    
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"locationChanged"])
    {
        CLLocation *currentLocation = [[notification userInfo] objectForKey:@"currentLocation"];
        if(!IsEmpty(currentLocation)) {
 
            
            [self refreshGeoFenceMonitoring];
            
            double longitude = currentLocation.coordinate.longitude;
            double latitude =  currentLocation.coordinate.latitude;
            
            [DocbaketAPIClient postUserTracking:@{@"longitude":@(longitude), @"latitude":@(latitude)}];
        }

    }
}

#pragma mark - Class Public methods


- (void)startmanager
{
    [SQLManager initDataBase];
    
    [DBKLOCATION startLocationManager];
}


- (void)stopManager
{
    [DBKLOCATION stopLocationManager];
}

- (void)checkMessage:(void (^)(NSArray *messages))block
{
    [DocbaketAPIClient checkNewMessage:^(NSArray *messages) {
        if(!IsEmpty(messages)){
            block(messages);
        } else {
            block([NSArray array]);
        }
    }];
}

- (void)checkMyBasket:(NSString*)filter completionHandler:(void (^)(NSArray *baskets))block
{
    [DocbaketAPIClient checkNewDocBaskets:nil filter:filter completionHandler:^(NSArray *baskets)
     {
         if(!IsEmpty(baskets)){
             block(baskets);
         } else {
             block([NSArray array]);
         }
     }];
    
}




// [1] 처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 바스킷 DB에 저장한다. 기본 1000m반경
- (void)checkNewBasket:(CLLocation *)currentLocation filter:(NSString*)filter completionHandler:(void (^)(BOOL success))block
{
    [DocbaketAPIClient checkNewDocBaskets:(CLLocation *)currentLocation filter:filter completionHandler:^(NSArray *baskets)
     {
         if(!IsEmpty(baskets)){
             
             [GVALUE setBaskets:baskets];
             
             if(!IsEmpty(GVALUE.baskets)){
                 __block int count = (int)[GVALUE.baskets count];
                 for(Docbasket *basket in GVALUE.baskets) {
                     [SQLManager syncDocBasket2DB:basket completionHandler:^(BOOL success) {
                         
                         count--;
                         
                         if(count == 0){
                             block(success);
                         }
                         
                     }];
                 }
             }
             
             
         } else {
             
         }
         
         
     }];
    
}

// [2] 1단계가 끝나면 바스킷 DB에서 기본 100m반경에 있는 바스킷을 가지고와서 지오팬싱 모니터링 건 후에 맴 리프레쉬 해줌.
- (void)refreshGeoFenceMonitoring
{

    // 만약 이전에 검사했던 위치와 현재 위치 거리가 GVALUE.regionMonitoringDistance 보다 작으면 스킵
    if(!IsEmpty(GVALUE.currentLocation) &&  !IsEmpty(GVALUE.lastRegionDistanceLocation)) {
        double distance = (double)[GVALUE.currentLocation distanceFromLocation:GVALUE.lastRegionDistanceLocation];
        double monitoringDistance = (GVALUE.regionMonitoringDistance * 1000.0) / 4.0;
        
        if(fabs(distance) < monitoringDistance ) {
            return;
        }
    }

    double distance = GVALUE.regionMonitoringDistance; // 0.1km = 100m
    // 아니면 새로 모니터링할 지오팬싱 리스트를 가지고 온다.
    [SQLManager getRegionBasketsDistance:distance completionHandler:^(BOOL success) {
        if(success)
        {
            GVALUE.lastRegionDistanceLocation = GVALUE.currentLocation;
            
            
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [DBKLOCATION cleanAllGeoFence];
//                
//                int count = 0;
//                for(Docbasket *basket in GVALUE.geoFenceBaskets){
//                    if(!IsEmpty(basket)){
//                        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(basket.latitude, basket.longitude);
//                        CLCircularRegion *newRegion = [DBKLOCATION makeNewCircularRegion:coord withID:basket.basketID];
//                        
//                        [DBKLOCATION startMonitoringRegion:newRegion];
//                        count++;
//                        if(count > 19) break; //(19개까지만 하고 싶을때)
//                    }
//                }
//            });
        } else {
            // 이전 검색 위치랑 Distance가 가까워 따로 업데이트 안함.
        }
        
        
        
        NSString *msg = [NSString stringWithFormat:@"===> GEO fence baskets =  %d", (int)GVALUE.geoFenceBaskets.count];
        [GVALUE addLog:msg];
        for(Docbasket *basket in GVALUE.geoFenceBaskets){
            NSString *title = (!IsEmpty(basket.title))?basket.title:@"";
            msg = [NSString stringWithFormat:@"===> GEO fence baskets =  %@", title];
            [GVALUE addLog:msg];
        }
        
    }];
}





//CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
//double distance = [loc1 getDistanceFrom:position2];
//if(distance <= 10)

//- (void)loadBasketsFromDB
//{
//    NSArray *baskets = [SQLManager getDocBasketsForQuery:@"SELECT * FROM Docbasket;"];
//    if(!IsEmpty(baskets)){
//        [GVALUE setBaskets:baskets];
//        
//        [self loadBasketsOnMap];
//        
//        // DB에 있는 걸로 맵 다시 정의
//        // 만약 새로운 맵이 있다면
//        
//    } else {
//        [DocbaketAPIClient getZipBasket:^(id result) {
//            if(!IsEmpty(result)){
//                __block int count = (int)[result count];
//                for(NSDictionary *jsonData in result) {
//                    [SQLManager syncDocBaskets2DB:jsonData completionHandler:^(BOOL success) {
//                        if(success){
//                            count--;
//                            
//                            if(count == 0){
//                                [self loadBasketsOnMap];
//                            }
//                        } else {
//                            
//                        }
//                    }];
//                }
//            } else {
//                NSLog(@"Error ");
//            }
//        }];
//    }
//
//
//}



- (void)loadBasketsOnMap
{
    NSLog(@"Basket count = %d", (int)[GVALUE.baskets count]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"refreshMap"}];
}


- (void)pushLocalNotification:(NSString *)event basket:(Docbasket*)basket
{
    
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        noti.fireDate =  [NSDate dateWithTimeIntervalSinceNow:0.1];
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.alertBody = event;
        noti.alertAction = @"GOGO";
        noti.userInfo = @{@"baksetID":basket.basketID, @"title":basket.title };
        //noti.applicationIconBadgeNumber = GVALUE.badgeValue;
        [app presentLocalNotificationNow:noti];
    }
    
    // type = 0:remote / 1:local
    [SQLManager syncBasket2InvitedDB:basket type:0 completionHandler:^(BOOL success) {
        NSLog(@"Invited list = %@",[SQLManager getAllInvites]);
    }];

}






@end
