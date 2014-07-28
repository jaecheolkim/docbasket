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
@property (nonatomic, strong) NSTimer* locationUpdateTimer;
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
        
        NSTimeInterval time = 60.0;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(refreshLocation)
                                       userInfo:nil
                                        repeats:YES];

        
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
// [0]  DB및 Location Mananger 구동 및 위치가 잡히면 City Zip 데이터를 가져와 DB에 저장한다.
// [1]  처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 바스킷 DB에 저장한다. 기본 현재 위치기준 10000m 반경(10km)
// [2]  1단계가 끝나면 바스킷 DB에서 기본 10m반경에 있는 바스킷을 가지고와서 지오팬싱 모니터링 건 후에 맴 리프레쉬 해줌.
//      만약 이전에 검사했던 위치와 현재 위치 거리가 GVALUE.regionMonitoringDistance 보다 작으면 스킵
//      아니면 새로 모니터링할 지오팬싱 리스트를 가지고 온다.

- (void)refreshLocation
{
    [self checkNewBasket:GVALUE.currentLocation filter:nil completionHandler:^(BOOL success) {
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                GVALUE.lastAPICallLocation = GVALUE.currentLocation;
                
                [self getNewGeoFences];
                
                [self loadBasketsOnMap];
            });
        } else {
            
        }
     }];

}

#pragma mark - ServiceEventHandler



- (void)ServiceEventHandler:(NSNotification *)notification
{
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"locationServiceStarted"])
    {
        CLLocation *currentLocation = [[notification userInfo] objectForKey:@"currentLocation"];
        if(!IsEmpty(currentLocation))
        {

            // [1] 처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 DB에 저장한다.
            // 앱이 구동되고 Location service가 스타트 되면 체크 함.
            [self checkNewBasket:currentLocation filter:@"public" completionHandler:^(BOOL success) {
                if(success){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        GVALUE.lastAPICallLocation = GVALUE.currentLocation;
                        
                        [self refreshGeoFenceMonitoring];
                        
                        [self loadBasketsOnMap];
                        
                        double longitude = currentLocation.coordinate.longitude;
                        double latitude =  currentLocation.coordinate.latitude;
                        NSString *timestamp = GVALUE.timestamp;

                        NSDictionary *trackingInfo = @{@"longitude":@(longitude), @"latitude": @(latitude), @"tracked_at": timestamp};
                        [GVALUE.trackingArray addObject:trackingInfo];
                        //[DocbaketAPIClient postUserTracking:GVALUE.trackingArray];
                    });
                } else {
                    
                }
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
            NSString *timestamp = GVALUE.timestamp;
            
            NSDictionary *trackingInfo = @{@"longitude":@(longitude), @"latitude": @(latitude), @"tracked_at": timestamp};
            [GVALUE.trackingArray addObject:trackingInfo];

            
            //[DocbaketAPIClient postUserTracking:@{@"longitude":@(longitude), @"latitude":@(latitude)}];
        }

    }
}

#pragma mark - Class Public methods


- (void)startmanager
{
    [SQLManager initDataBase];
    
    [DBKLOCATION startLocationManager];
    
    // [0] 앱 구동 후 처음으로 위치가 파악되면 City Zip 데이터를 가져와 DB에 저장한다.
    [self loadBasketsFromDB];
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



// <+37.54224236,+126.96199378>
// [1] 처음에 네트웍에서 현재 위치 기준으로 바스킷 정보 가져오고 바스킷 DB에 저장한다. 기본 1000m반경
- (void)checkNewBasket:(CLLocation *)currentLocation filter:(NSString*)filter completionHandler:(void (^)(BOOL success))block
{
    [DocbaketAPIClient checkNewDocBaskets:(CLLocation *)currentLocation filter:filter completionHandler:^(NSArray *baskets)
     {
         if(!IsEmpty(baskets)){
             
             [GVALUE setBaskets:(NSMutableArray*)baskets];
             
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
//             NSArray *dbBaskets = [SQLManager getDocBasketsForQuery:@"SELECT * FROM Docbasket;"];
//             if(!IsEmpty(dbBaskets)){
//                 [GVALUE setBaskets:(NSMutableArray*)dbBaskets];
//             }

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

    // 아니면 새로 모니터링할 지오팬싱 리스트를 가지고 온다.
    [self getNewGeoFences];

}


- (void)getNewGeoFences
{
    double distance = GVALUE.regionMonitoringDistance; // 0.1km = 100m
    // 아니면 새로 모니터링할 지오팬싱 리스트를 가지고 온다.
    [SQLManager getRegionBasketsDistance:distance completionHandler:^(BOOL success) {
        if(success)
        {
            GVALUE.lastRegionDistanceLocation = GVALUE.currentLocation;
            
            
            NSString *msg = [NSString stringWithFormat:@"===> GEO fence baskets =  %d", (int)GVALUE.geoFenceBaskets.count];
            [GVALUE addLog:msg];
            for(Docbasket *basket in GVALUE.geoFenceBaskets){
                NSString *title = (!IsEmpty(basket.title))?basket.title:@"";
                msg = [NSString stringWithFormat:@"===> GEO fence baskets =  %@", title];
                [GVALUE addLog:msg];
            }
            
        } else {
                        // 이전 검색 위치랑 Distance가 가까워 따로 업데이트 안함.
        }
        
        NSLog(@"GEOFence counts = %d", (int)[GVALUE.geoFenceBaskets count]);
        
        [self checkGeoFence];

    }];

}

- (void)checkIn:(Docbasket*)basket
{

    NSString *title = (IsEmpty(basket.title))?@"":basket.title;
    NSString *msg = [NSString stringWithFormat:@" %@ : %@", title, @"Enter !"];
    NSLog(@"GEOFENCE :: %@", msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        //라스트 체크인 바스켓에 먼저 저장하고
        NSString *basketID = basket.basketID;
        [SQLManager saveLastCheckInTime:basketID];

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
    // 지오팬스 대상 바스켓을 모두 읽어 온다.
    for(Docbasket *basket in GVALUE.geoFenceBaskets)
    {
        //NSLog(@"check geofence = %@ ", basket.title);
        // 만약에 현재 위치의 지오펜스가 존재한다면
        if([basket.region containsCoordinate:GVALUE.currentLocation.coordinate])
        {

            NSString *basketID = basket.basketID;
            
            double timeDuration = [SQLManager checkLastCheckInTime:basketID];
            NSLog(@"================================== checked in geofence = %0.3f / %@  ", timeDuration, basket.title);
            
            // 체크인이 처음인지 혹은 체크인 한지 하루 이상 지난 지오펜스 인지 조사한다.
            if((timeDuration > GVALUE.checkInTimeFiler) || timeDuration < 0) {
                NSLog(@"==================================>>> checked in new  :  %@  ", basket.title);
                [self checkIn:basket];
            }
        }
    }
}


- (void)checkGeoFenceOLD
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



//- (void)checkGeoFence
//{
//    for(Docbasket *basket in GVALUE.geoFenceBaskets)
//    {
//        // 만약에 현재 위치의 지오펜스가 존재한다면
//        if([basket.region containsCoordinate:GVALUE.currentLocation.coordinate])
//        {
//            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basketID == %@", basket.basketID];
//            NSArray *filteredArray = [GVALUE.lastCheckInBaskets filteredArrayUsingPredicate:predicate];
//            NSLog(@"filteredArray = %@", filteredArray);
//            
//            if(!IsEmpty(filteredArray)){
//                for( Docbasket *tmpBasket in filteredArray){
//                    
//                }
//                double timeDuration = [lastCheckInBasket.checkInDate secondsAgo];
//                
//                if([basket.basketID isEqualToString:lastCheckInBasketID]){
//                    if(timeDuration > GVALUE.checkInTimeFiler) { // 만약 24시간이 지났다면..
//                        // 새롭게 해당 지오펜스 체크인 한다.
//                        [self checkIn:basket];
//                    }
//                }
//                
//            } else {
//                
//            }
//            
//            
//            
//            
//        }
//    }
//}
//
////            if(IsEmpty(GVALUE.lastCheckInBaskets)){
////                Docbasket *lastCheckInBasket = GVALUE.lastCheckInBasket;
////                if(!IsEmpty(lastCheckInBasket)) {
////                    NSString *lastCheckInBasketID = lastCheckInBasket.basketID;
//double timeDuration = [lastCheckInBasket.checkInDate secondsAgo];
////
////                    //만약 마지막 체크인 한 지오펜스와 같다면 시간을 검사한다.
////                    if([basket.basketID isEqualToString:lastCheckInBasketID]){
////                        if(timeDuration > GVALUE.checkInTimeFiler) { // 만약 24시간이 지났다면..
////                            // 새롭게 해당 지오펜스 체크인 한다.
////                            [self checkIn:basket];
////                        }
////                    }
////                    //만약 마지막 체크인 한 지오펜스와 다르다면
////                    else {
////                        // 새롭게 해당 지오펜스 체크인 한다.
////                        [self checkIn:basket];
////                    }
////
////                }
////                // 만약 새로 체크인 하는 지오펜스 일 경우는
////                else {
////                    // 새롭게 해당 지오펜스 체크인 한다.
////                    [self checkIn:basket];
////                }
////
////                //break; // 진행하던 루프를 종료한다.
////            } else {
////
//////                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basketID == %@", basket.basketID];
//////                NSArray *filteredArray = [GVALUE.lastCheckInBaskets filteredArrayUsingPredicate:predicate];
//////                if(!IsEmpty(filteredArray)){
//////
//////                    for(Docbasket *lastCheckInBasket in filteredArray){
//////
//////                        double timeDuration = [lastCheckInBasket.checkInDate secondsAgo];
//////                        if(timeDuration > GVALUE.checkInTimeFiler) { // 만약 24시간이 지났다면..
//////                            // 새롭게 해당 지오펜스 체크인 한다.
//////                            [self checkIn:basket];
//////                        }
//////
//////                    }
//////
//////                }
////
////                for(Docbasket *tmpBasket in GVALUE.lastCheckInBaskets){
////                    if([basket.basketID isEqualToString:tmpBasket.basketID]){
////                        double timeDuration = [tmpBasket.checkInDate secondsAgo];
////                        if(timeDuration > GVALUE.checkInTimeFiler) { // 만약 24시간이 지났다면..
////                            // 새롭게 해당 지오펜스 체크인 한다.
////                            [self checkIn:basket];
////                        }
////                    }
////                }
////             }
////            //break; // 진행하던 루프를 종료한다.
////
////        }
////    }
////}



/*
 처음 앱을 실행하면 City Zip  DB가 있는지 확인하고 있으면 GVALUE.baskets에 로드 한다. 
 처음 위치값이 들어오면 API의 checkNewBasket을 호출 하여 DB에 저장 후 
 
 저장 후 map pin 로드 한다.
 
 처음 Location 데이터가 들어오면 checkNewBasket
 

*/
//CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
//double distance = [loc1 getDistanceFrom:position2];
//if(distance <= 10)

- (void)loadBasketsFromDB
{
    [DocbaketAPIClient getZipBasket:^(id result) {
        if(!IsEmpty(result)){
            __block int count = (int)[result count];
            for(NSDictionary *jsonData in result) {
                [SQLManager syncDocBaskets2DB:jsonData completionHandler:^(BOOL success) {
                    if(success){
                        count--;
                        
                        if(count == 0){
                            //[self loadBasketsOnMap];
                        }
                    } else {
                        
                    }
                }];
            }
        } else {
            NSLog(@"Error ");
        }
    }];

    
    
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


}



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


- (void) createBasket
{
    UIImage *photo = [UIImage imageNamed:@"login.png"];
    //UIImage *smallerPhoto = [self rescaleImage:photo toSize:CGSizeMake(800, 600)];
    //    NSData *jpeg = UIImageJPEGRepresentation(smallerPhoto, 0.82);
    
    double latitude = GVALUE.screenCenterCoordinate2D.latitude;
    double longitude = GVALUE.screenCenterCoordinate2D.longitude;
    
    NSArray *arrayFilesData = @[photo,];
    
    NSDictionary *parameters = @{@"user_id": GVALUE.userID, @"basket[title]": @"테스트000", @"basket[longitude]": @(longitude), @"basket[latitude]": @(latitude), @"files" : arrayFilesData};
    
    [DocbaketAPIClient createBasket:parameters completionHandler:^(NSDictionary *result)
     {
         if(!IsEmpty(result)){
             NSLog(@"result = %@", result);
             
//             CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"latitude"] doubleValue], [result[@"longitude"] doubleValue]);
//             [DBKLOCATION makeNewRegionMonitoring:coord withID:result[@"id"] withMap:self.mapView];
             
         } else {
             NSLog(@"Error ...");
         }
     }];

}






@end
