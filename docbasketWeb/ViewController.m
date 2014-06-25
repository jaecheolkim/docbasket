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
#import "UIButton+WebCache.h"
#import "CHPopUpMenu.h"

//#import "Docbasket.h"
//#import "AFHTTPRequestOperationManager.h"
//#import "UIRefreshControl+AFNetworking.h"
//#import "UIAlertView+AFNetworking.h"


@interface ViewController ()
{
    CLLocationCoordinate2D currentCoordinate;
    CGRect screenFrame;
    BOOL isChangingScreen;
    CHPopUpMenu *popUp;
}

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    isChangingScreen = YES;

    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    
    //self.strURL = MAINURL;
    
    _webView.delegate = self;

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MAINURL]]];
    
    _webView.hidden = YES;
    
    
    self.mapView.showsUserLocation=YES;
    //[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    
    self.basketPin.hidden = YES;
    
    [self fixScreenFrame];
    
    [self.view addSubview:({
        NSArray *icons = @[[UIImage imageNamed:@"files.png"],[UIImage imageNamed:@"photo.png"],[UIImage imageNamed:@"sound.png"],[UIImage imageNamed:@"time.png"],[UIImage imageNamed:@"Vault.png"]];
        
        popUp = [[CHPopUpMenu alloc]initWithFrame:CGRectMake(145, 420, 30, 30)
                                                     direction:M_PI/2
                                                     iconArray:icons];
        popUp;
    })];
    
    self.createHereButton.hidden = YES;
    popUp.hidden = YES;

    NSLog(@"Navi frame = %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationEventHandler:)
                                                 name:@"LocationEventHandler" object:nil];

    
    [self refreshMap];
    [self goCurrent];
    
    isChangingScreen = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationEventHandler" object:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation");
    isChangingScreen = YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
     NSLog(@"didRotateFromInterfaceOrientation");
    
    isChangingScreen = NO;
    
    [self fixScreenFrame];
}

- (void)fixScreenFrame
{
    UIInterfaceOrientation statusBarOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    screenFrame = [[UIScreen mainScreen] bounds];
    
    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        screenFrame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    }
    
    self.basketPin.center = CGPointMake(screenFrame.size.width/2, screenFrame.size.height/2);
    popUp.center =  CGPointMake(screenFrame.size.width/2,self.basketPin.center.y - 10);
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


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GVALUE.baskets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Docbasket *cellData = [GVALUE.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(cellData)){
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = cellData.title;
        cell.textLabel.numberOfLines = 4;
    }

	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}



#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated");
    
    if(isChangingScreen || self.basketPin.hidden) return;

    [self showNavigationBar:NO];
    
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(isChangingScreen || self.basketPin.hidden) return;
    
    NSLog(@"regionDidChangeAnimated");

    [self catchCurrentCenterAddress:^(bool find) {
        [self showNavigationBar:YES];
    }];

    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[RegionAnnotation class]]) {
        RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
        CLCircularRegion *region = currentAnnotation.region;
        
        NSDictionary *findBasket = [GVALUE findBasketWithID:region.identifier];
        NSString *title = [findBasket valueForKey:@"title"];
        
        NSString *image = [findBasket valueForKey:@"image"];
        NSString *ext = nil;
        UIImage *icon = [UIImage imageNamed:@"RemoveRegion"];
        NSString *MyURL = nil;
        
        if(!IsEmpty(image)){
            
            ext = [image pathExtension];
            if([ext isEqualToString:@"png"] || [ext isEqualToString:@"PNG"] ||
               [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"JPG"] ){
                
                MyURL = [NSString stringWithFormat:@"%@%@",@"http://docbasket.com",image];
//                icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];

            }
        }
        NSLog(@"%@ / %@ / ext = %@", title, image, ext);
        
        currentAnnotation.title = title;
        
        NSString *annotationIdentifier = region.identifier; //[currentAnnotation title];
        
        
        RegionAnnotationView *regionView = (RegionAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!regionView) {
            regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            regionView.map = _mapView;
            
            // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
            UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
            if(!IsEmpty(MyURL)){
                [removeRegionButton setImageWithURL:[NSURL URLWithString:MyURL] forState:UIControlStateNormal];
            } else {
                [removeRegionButton setImage:icon forState:UIControlStateNormal];
            }
            
            
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
        circleView.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
        circleView.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.1];
        
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
            
            
            [DBKLOCATION makeNewRegionMonitoring:regionAnnotation.coordinate withID:regionAnnotation.region.identifier withMap:self.mapView];
        }
    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    RegionAnnotationView *regionView = (RegionAnnotationView *)view;
    RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
    
    [self.mapView setRegion:MKCoordinateRegionMake(regionAnnotation.coordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:YES];
//
//    // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
//    [DBKLOCATION stopMonitoringRegion:regionAnnotation.region];
//    [regionView removeRadiusOverlay];
//    [_mapView removeAnnotation:regionAnnotation];
}


//- (void)fixBasketPinOrient
//{
//    UIInterfaceOrientation statusBarOrientation =  [UIApplication sharedApplication].statusBarOrientation;
//    CGRect  bounds = [[UIScreen mainScreen] bounds];
//    
//    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
//        bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
//    }
//    
//    self.basketPin.center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
//}

- (IBAction)refreshHandler:(id)sender
{
    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    [self refreshMap];
    [self goCurrent];
    
    [_webView reload];
    
    NSString *func = [NSString stringWithFormat:@"goCurrentPosition(%f,%f)",currentCoordinate.latitude, currentCoordinate.longitude];
    [self javaScriptFromString:func];
 }

- (IBAction)buttonHandler:(id)sender
{
    
//    $("#basket_longitude")[0].value
//    $("#basket_latitude")[0].value
    
//    NSLog(@"longitude : %@", [self javaScriptFromString:@"goCurrentPosition(%f,%f)",]);
   // NSLog(@"latitude : %@", [self javaScriptFromString:@"$(\"#basket_latitude\")[0].value"]);
   // NSLog(@"longitude : %@", [self javaScriptFromString:@"$(\"#basket_longitude\")[0].value"]);  
    
    //NSLog(@"User : %@", [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"]); // 로그인된 사용자 ID값 받아오기
   
//    [self saveUserID];
//    [DocbaketAPIClient Login];
   
//    [DocbaketAPIClient getBaskets];
    
    
    UIInterfaceOrientation statusBarOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    CGRect  bounds = [[UIScreen mainScreen] bounds];
    
    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
    }
    
    self.basketPin.center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    popUp.center =  CGPointMake(bounds.size.width/2,self.basketPin.center.y - 10);
    self.basketPin.hidden = ! self.basketPin.hidden;
    //self.createHereButton.hidden =  ! self.createHereButton.hidden;
    popUp.hidden =  ! popUp.hidden;
    
}

- (IBAction)tabHandler:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            _mapView.hidden = NO;
            _webView.hidden = YES;
            _tableView.hidden = YES;
            break;
        case 1:
            _mapView.hidden = YES;
            _webView.hidden = NO;
            _tableView.hidden = YES;
            break;
        case 2:
            _mapView.hidden = YES;
            _webView.hidden = YES;
            _tableView.hidden = NO;
            break;
        default:
            break;
    }
}


- (IBAction)refreshCurrentLocation:(id)sender
{
    [self goCurrent];
}


- (IBAction)createNewBasket:(id)sender
{
//    [self showNavigationBar:NO];
//    
//    UIToolbar *blurbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    blurbar.barStyle = UIBarStyleBlack;
//    [self.view addSubview:blurbar];

}

- (IBAction)createHereBasket:(id)sender
{
    
}



- (void)showNavigationBar:(BOOL)show
{
    if(!show){
        self.navigationItem.leftBarButtonItem.customView.alpha = 0;
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* obj, NSUInteger idx, BOOL *stop) {
            obj.customView.alpha = 0;
        }];
        self.navigationItem.rightBarButtonItem.customView.alpha = 0;
        self.navigationItem.titleView.alpha = 0;
        self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0];
        
        if(popUp._isMenuPresented) [popUp dismissSubMenu];
        
        //{{0, 20}, {320, 44}}
        [UIView animateWithDuration:0.7 animations:^{
            self.navigationController.navigationBar.frame = CGRectMake(0, 20, screenFrame.size.width, 0);
            
            popUp.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBar.frame = CGRectMake(0, 20, screenFrame.size.width, 44);
            popUp.alpha = 1;
        } completion:^(BOOL finished) {
            self.navigationItem.leftBarButtonItem.customView.alpha = 1;
            self.navigationItem.rightBarButtonItem.customView.alpha = 1;
            self.navigationItem.titleView.alpha = 1;
            self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:1];
        }];
    }
}

-(void)catchCurrentCenterAddress:(void (^)(bool find))block
{
    CGPoint interestPoint = CGPointMake(self.basketPin.center.x, self.basketPin.center.y + self.basketPin.frame.size.height /2) ;
    
    CLLocationCoordinate2D coord= [_mapView convertPoint:interestPoint toCoordinateFromView:_mapView];
    NSLog(@"screen Point : %@  / lat : %f / long : %f", NSStringFromCGPoint(interestPoint), coord.latitude, coord.longitude);
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    [DBKLocationManager reverseGeocodeLocation:location completionHandler:^(NSString *address) {
        
        [_addressInfo setTitle:address forState:UIControlStateNormal];
        
        block(YES);
        
    }];
}

- (NSString *)getUserID
{
    return [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"];
}

- (void)saveUserID
{
    id userID =  [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"];
    if ([userID isKindOfClass:[NSString class]]) {

        [[GlobalValue sharedInstance] setUserID:userID];
        
        NSLog(@"Saved UserID = %@",[[GlobalValue sharedInstance] userID]);
        
        
        [DocbaketAPIClient Login];
     }
}

- (NSString*)javaScriptFromString:(NSString*)str
{
    return [_webView stringByEvaluatingJavaScriptFromString:str];
}


- (void)goCurrent
{
    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    [self.mapView setRegion:MKCoordinateRegionMake(currentCoordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:YES];
}

- (void)refreshMap
{

    [_mapView removeAnnotations:_mapView.annotations];
    
    for (id overlay in [_mapView overlays]) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            [_mapView removeOverlay:overlay];
        }
    }
    
    NSArray *regions = [[[DBKLocationManager sharedInstance].locationManager monitoredRegions] allObjects];
    for(CLCircularRegion *oldregion in regions){
        [[DBKLocationManager sharedInstance] stopMonitoringRegion:oldregion];
    }

    [DocbaketAPIClient loadDocBaskets:^(BOOL success){
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^(void) {

                NSLog(@"Basket count = %d", (int)[GVALUE.baskets count]);
                
                for(Docbasket *basket in GVALUE.baskets){
                    if(!IsEmpty(basket)){
                        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(basket.latitude, basket.longitude);
                        [[DBKLocationManager sharedInstance] makeNewRegionMonitoring:coord withID:basket.basketID withMap:_mapView];
                    }
                }
                
                NSArray *regions = [[[DBKLocationManager sharedInstance].locationManager monitoredRegions] allObjects];

                NSLog(@"->Load %d regions : %@", (int)regions.count, regions );
                
                
                if (!_tableView.hidden) {
                    [_tableView reloadData];
                }
             });
 

        } else {
            NSLog(@"Load Baskets : FAIL");
        }
    }];

}

- (void)LocationEventHandler:(NSNotification *)notification
{

    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"monitoringDidFailForRegion"]) {
        
        id region = [[notification userInfo] objectForKey:@"region"];
        if(!IsEmpty(region) && [NSStringFromClass([region class]) isEqualToString:@"CLCircularRegion"]){
            NSLog(@"Msg : %@", [[notification userInfo] objectForKey:@"Msg"]);
            NSLog(@"region : %@", [[notification userInfo] objectForKey:@"region"]);

        }
    }
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"currentAddress"]) {
        
        id address = [[notification userInfo] objectForKey:@"address"];
        if(!IsEmpty(address)){
            [_addressInfo setTitle:address forState:UIControlStateNormal];
            
        }
    }

}


//[[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"MySavedCookies"];
//NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"MySavedCookies"];


@end
