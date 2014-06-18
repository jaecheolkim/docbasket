//
//  ViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "ViewController.h"
#import "DBKLocationManager.h"
#import "docbasketURLInfo.h"
#import "GlobalValue.h"
#import "DocbaketAPIClient.h"
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import "Docbasket.h"

//#import "Docbasket.h"
//#import "AFHTTPRequestOperationManager.h"
//#import "UIRefreshControl+AFNetworking.h"
//#import "UIAlertView+AFNetworking.h"


@interface ViewController ()
{
    CLLocationCoordinate2D currentCoordinate;
    

}

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];

    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    
    self.strURL = MAINURL;
    
    _webView.delegate = self;

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MAINURL]]];
    
    _webView.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [DocbaketAPIClient loadDocBaskets:^(BOOL success){
        if(success){
            NSLog(@"Load Baskets : %@", GVALUE.baskets );
            for(Docbasket *basket in GVALUE.baskets){
                if(!IsEmpty(basket)){
                    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(basket.latitude, basket.longitude);
                    [[DBKLocationManager sharedInstance] makeNewRegionMonitoring:coord withID:basket.basketID];
                }
            }
            
            NSArray *regions = [[[DBKLocationManager sharedInstance].locationManager monitoredRegions] allObjects];
            // Iterate through the regions and add annotations to the map for each of them.
            for (int i = 0; i < [regions count]; i++) {
                CLRegion *region = [regions objectAtIndex:i];
                RegionAnnotation *annotation = [[RegionAnnotation alloc] initWithCLRegion:region];
                [_mapView addAnnotation:annotation];
            }

            NSLog(@"Load regions : %@", regions );
        } else {
            NSLog(@"Load Baskets : FAIL");
        }
    }];

    
    
//    // Get all regions being monitored for this application.
//    NSArray *regions = [[DBKLOCATION.locationManager monitoredRegions] allObjects];
//    
//    // Iterate through the regions and add annotations to the map for each of them.
//    for (int i = 0; i < [regions count]; i++) {
//        CLRegion *region = [regions objectAtIndex:i];
//        RegionAnnotation *annotation = [[RegionAnnotation alloc] initWithCLRegion:region];
//        [_mapView addAnnotation:annotation];
//    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)theRequest navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[theRequest URL] absoluteString];
    //NSString *keyURL = [[theRequest URL] host];
    NSString *path = [[theRequest URL] path];
    
    //NSArray *arr = [url componentsSeparatedByString:@"?"];
    NSLog(@"path : %@", path);
    NSLog(@"currentURL : %@", url);
    
    if([path isEqualToString:@"/auth/facebook"] ||
       [path isEqualToString:@"/auth/linkedin"] ) {
        
        GVALUE.START_LOGIN = YES;
        
    }
    
    if( GVALUE.START_LOGIN &&
       ([path isEqualToString:@"/auth/facebook/callback"] ||
        [path isEqualToString:@"/auth/linkedin/callback"] )) {
           
           GVALUE.FIND_USERID = YES;
           
       }
    
//
//    if(keyURL != nil && ![[arr objectAtIndex:0] isEqualToString:@"http://help.paran.com/faq/mobile/wk/mFaqView.jsp"]
//       && ![[arr objectAtIndex:0] isEqualToString:@"http://help.paran.com/faq/global/english/mFaqView.jsp"]
//       && ![[arr objectAtIndex:0] isEqualToString:@"http://help.paran.com/faq/mobile/wk/mRarView.jsp"]
//       && ![[arr objectAtIndex:0] isEqualToString:@"http://help.paran.com/faq/global/english/mRarView.jsp"]
//       )
//    {
//        [indicator startAnimating];
//        [indicatorBg setHidden:NO];
//    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [indicator startAnimating];
//    [indicatorBg setHidden:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if(GVALUE.START_LOGIN && GVALUE.FIND_USERID) {
        [self saveUserID];
        GVALUE.START_LOGIN = GVALUE.FIND_USERID = NO;
     }
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
//    NSString *errorMsg = nil;
//    
//    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
//        switch ([error code]) {
//            case NSURLErrorCannotFindHost:
//                errorMsg = NSLocalizedString(@"Can't find the specified server. Please re-type URL.", @"");
//                break;
//            case NSURLErrorCannotConnectToHost:
//                errorMsg = NSLocalizedString(@"Can't connect to the server. Please try it again.", @"");
//                break;
//            case NSURLErrorNotConnectedToInternet:
//                errorMsg = NSLocalizedString(@"Can't connect to the network. Please check your network.", @"");
//                
//                if(WIFIView == nil) {
//                    WIFIView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WIFI.png"]];
//                    [WIFIView setFrame:webview.frame];
//                    [WIFIView setBackgroundColor:[UIColor whiteColor]];
//                    [WIFIView setContentMode:UIViewContentModeScaleAspectFit];
//                    [self.view addSubview:WIFIView];
//                }
//                
//                if(WIFILabel == nil){
//                    WIFILabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 300.0f, 207.0f, 89.0)];
//                    WIFILabel.textColor = [UIColor whiteColor];
//                    WIFILabel.text = NSLocalizedString(@"You are not connected to the network. Please connect to Wi-Fi or check your network again.", @"");
//                    [WIFILabel setFont:BASIC_BOLD_FONT(12)];
//                    WIFILabel.backgroundColor = [UIColor clearColor ];
//                    [WIFILabel setTextColor:[UIColor blackColor]];
//                    WIFILabel.lineBreakMode = UILineBreakModeTailTruncation;
//                    WIFILabel.textAlignment = UITextAlignmentCenter;
//                    WIFILabel.numberOfLines = 3;
//                    [self.view  addSubview:WIFILabel];
//                }
//                
//                break;
//            default:
//                errorMsg = [error localizedDescription]; 
//                break;
//        }
//    } else {
//        errorMsg = [error localizedDescription];
//    }
//    
//    NSLog(@"didFailLoadWithError: %@", errorMsg);
//    
//    [indicator stopAnimating];
//    [indicatorBg setHidden:YES];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[RegionAnnotation class]]) {
        RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
        CLRegion *region = currentAnnotation.region;
        
        NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
        NSString *title = [findBasket valueForKey:@"title"];

        
        currentAnnotation.title = title;
        
        NSString *annotationIdentifier = region.identifier; //[currentAnnotation title];
        
        RegionAnnotationView *regionView = (RegionAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!regionView) {
            regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation];
            regionView.map = _mapView;
            
            // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
            UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
            [removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
            
            regionView.leftCalloutAccessoryView = removeRegionButton;
        } else {
            regionView.annotation = annotation;
            regionView.theAnnotation = annotation;
        }
        
        // Update or add the overlay displaying the radius of the region around the annotation.
        [regionView updateRadiusOverlay];
        
        return regionView;
    }
    
    return nil;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKCircle class]]) {
        // Create the view for the radius overlay.
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [UIColor grayColor];
        circleView.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.4];
        
        return circleView;
    }
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if([annotationView isKindOfClass:[RegionAnnotationView class]]) {
        RegionAnnotationView *regionView = (RegionAnnotationView *)annotationView;
        RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
        
        // If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
        if (newState == MKAnnotationViewDragStateStarting) {
            [regionView removeRadiusOverlay];
            
            [DBKLOCATION stopMonitoringRegion:regionAnnotation.region];
        }
        
        // Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
        if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
            [regionView updateRadiusOverlay];
            
            CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:regionAnnotation.coordinate radius:100 identifier:[NSString stringWithFormat:@"%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude]];
            regionAnnotation.region = newRegion;
            
            
            [DBKLOCATION startMonitoringRegion:regionAnnotation.region];
        }
    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    RegionAnnotationView *regionView = (RegionAnnotationView *)view;
    RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
    
    // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
    [DBKLOCATION stopMonitoringRegion:regionAnnotation.region];
    [regionView removeRadiusOverlay];
    [_mapView removeAnnotation:regionAnnotation];
}


- (IBAction)refreshHandler:(id)sender {
    [_webView reload];
    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    NSString *func = [NSString stringWithFormat:@"goCurrentPosition(%f,%f)",currentCoordinate.latitude, currentCoordinate.longitude];
    [self javaScriptFromString:func];
    
    [DocbaketAPIClient loadDocBaskets:^(BOOL success){
        if(success){
            NSLog(@"Load Baskets : %@", GVALUE.baskets );
            
            NSDictionary *findBasket = [GVALUE findBasketWithID:@"377b7268-a653-486e-9f37-390ecc51029b"];
            NSLog(@"find basket : %@", [findBasket valueForKey:@"title"]);
        } else {
            NSLog(@"Load Baskets : FAIL");
        }
    }];
    
}

- (IBAction)buttonHandler:(id)sender {
    
//    $("#basket_longitude")[0].value
//    $("#basket_latitude")[0].value
    
//    NSLog(@"longitude : %@", [self javaScriptFromString:@"goCurrentPosition(%f,%f)",]);
   // NSLog(@"latitude : %@", [self javaScriptFromString:@"$(\"#basket_latitude\")[0].value"]);
   // NSLog(@"longitude : %@", [self javaScriptFromString:@"$(\"#basket_longitude\")[0].value"]);  
    
    NSLog(@"User : %@", [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"]); // 로그인된 사용자 ID값 받아오기
   
    
}

- (IBAction)tabHandler:(id)sender {
    _mapView.hidden = !_mapView.hidden;
    _webView.hidden = !_webView.hidden;

}


//- (void)reload:(__unused id)sender {
//    //self.navigationItem.rightBarButtonItem.enabled = NO;
//    
//    NSURLSessionTask *task = [Docbasket getBasktesWithBlock:^(NSArray *basktes, NSError *error) {
//        if (!error) {
//
//            [GVALUE setBaskets:basktes];
//            
//            NSLog(@"Baskets : %@", GVALUE.baskets );
//        }
//    }];
//    
//    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
////    [self.refreshControl setRefreshingWithStateOfTask:task];
//    
//
//   // [self getJSONFromAFHTTP];
//}



- (void)saveUserID
{
    id userID =  [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"];
    if ([userID isKindOfClass:[NSString class]]) {

        [[GlobalValue sharedInstance] setUserID:userID];
        
        NSLog(@"Saved UserID = %@",[[GlobalValue sharedInstance] userID]);
        
        //[[GlobalValue sharedInstance] writeObjectToDefault:userID withKey:KEY_USER_ID];
        
    }
}

- (NSString*)javaScriptFromString:(NSString*)str
{
    return [_webView stringByEvaluatingJavaScriptFromString:str];
}




//[[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"MySavedCookies"];
//NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"MySavedCookies"];


@end
