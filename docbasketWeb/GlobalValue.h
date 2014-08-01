//
//  GlobalValue.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/17/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "Docbasket.h"
#import "UIView+MGBadgeView.h"
#import "DateTools.h"
#import "DBUtil.h" 

//#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"\n===========================================================================\nObject : <%p %@:(%d)>\nMethod : %s\nLog    : %@\n===========================================================================\n\n", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
//#else
//#define NSLog( s, ... )
//#endif



#define RGB_COLOR(r, g, b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA_COLOR(r, g, b, a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#define GVALUE              [GlobalValue sharedInstance]

#define  KEY_USER_ID                    @"default_user_id"
#define  KEY_USER_NAME                  @"default_user_name"
#define  KEY_USER_IMAGE                 @"default_user_image"
#define  KEY_USER_TOKEN                 @"default_user_token"
#define  KEY_BADGE_VALUE                @"badge_value"
#define  KEY_PUSHNOTIFICATIONSETTING    @"pushNotificationSetting"
#define  KEY_NOTIFICATION_BASKETID      @"defaul_notification_baskeID"


#define MAINURL          @"http://doc:basket@docbasket.com/login"
#define LOGOUTURL          @"http://doc:basket@docbasket.com/logout?simple_login=true"
#define BASKETS          @"http://docbasket.com/baskets"  // ?filer = inbox / outbox / public

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline id ObjectOrNull(id object)
{
    return object ?: [NSNull null];
}

@interface GlobalValue : NSObject
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userImage;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *notiBasketID;

@property (nonatomic, assign) NSTimeInterval refreshIntervalTime;
@property (nonatomic, assign) double regionMonitoringDistance; // 현재 위치에서의 지오팬싱 모니터링 반경 : 1km = 1.0 단위임. default = 0.1 (100m)
@property (nonatomic, assign) double findBasketsRange; // baskets.json API 호출할 때 현재 위치 기준 쿼리할 반경  [단위 = 미터 : 디폴트 10000 (10km)]
@property (nonatomic, assign) double checkInTimeFiler;

@property (nonatomic, assign) double GEOFenceRadius;

@property (nonatomic, strong) NSMutableArray *lastCheckInBaskets;
@property (nonatomic, strong) Docbasket *lastCheckInBasket;

@property (nonatomic) BOOL START_LOGIN;
@property (nonatomic) BOOL FIND_USERID;


@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@property (nonatomic) int pushNotificationSetting;

@property (nonatomic, assign) CLLocationCoordinate2D screenCenterCoordinate2D;
@property (nonatomic, strong) CLLocation *screenCenterLocation;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;


@property (nonatomic, strong) NSMutableArray *messages; // 메시지 메뉴에서 사용할 basket 리스트 어레이 (checked in[local] & invited[remote] 이 합쳐지는 장소)
@property (nonatomic, strong) NSMutableArray *baskets; //지도에서 사용할 전체 docbasket 리스트 가지고 있는 어레이
@property (nonatomic, strong) NSMutableArray *geoFenceBaskets; // 지오팬스 docbasket 리스트
@property (nonatomic, strong) NSMutableArray *trackingArray; // tracking 정보
@property (nonatomic, strong) CLLocation *lastRegionDistanceLocation; //마지막으로 지오팬싱 (regionMonitoringDistance기준) 가져왔던 위치 값
@property (nonatomic, strong) CLLocation *currentLocation;  // LocationManager에서 갱신되는 최신 현재 위치 값
@property (nonatomic, strong) CLLocation *lastLocation;  // 바로 이전의 currentLocation 위치 값
@property (nonatomic, strong) CLLocation *lastAPICallLocation; // 최종 baskets.json API call location

@property (nonatomic, strong) NSArray *mapItemList;

@property (nonatomic, strong) NSMutableArray *LogList; // 디버깅용 로그 어레이

@property (nonatomic, assign) int badgeValue;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIBarButtonItem *navLeftButton;
@property (nonatomic, strong) UIImageView *messageIconView;



+(GlobalValue*)sharedInstance;

- (void)writeObjectToDefault:(id)idValue withKey:(NSString *)strKey;
- (id)readObjectFromDefault:(NSString *)strKey;

- (Docbasket*)findBasketWithID:(NSString *)str; // NSArray *baskets 에서 basketID로 Docbasket 객체 검색
- (Docbasket *)findGeoFenceBasketWithID:(NSString *)str; // NSArray *geoFenceBaskets 에서 basketID로 Docbasket 객체 검색

- (void)addLog:(NSString*)log;
- (NSString*)timestamp;
- (double)getSecond:(NSString*)time;


- (void)saveInfo;
- (void)loadInfo;

@end


