//
//  ViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBMapViewController.h"
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import "UIButton+WebCache.h"
#import "CHPopUpMenu.h"

@interface DBMapViewController ()
{
    CLLocationCoordinate2D currentCoordinate;
    CGRect screenFrame;
    BOOL isChangingScreen;
    CHPopUpMenu *popUp;
}

@end

@implementation DBMapViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    isChangingScreen = YES;

    currentCoordinate = [DBKLOCATION getCurrentCoordinate];
 
    self.mapView.showsUserLocation=YES;
  
    self.basketPin.hidden = YES;
    
    [self fixScreenFrame];
    
    [self.view addSubview:({
        NSArray *icons = @[[UIImage imageNamed:@"files.png"],[UIImage imageNamed:@"photo.png"],[UIImage imageNamed:@"sound.png"],[UIImage imageNamed:@"time.png"],[UIImage imageNamed:@"Vault.png"]];
        
        popUp = [[CHPopUpMenu alloc]initWithFrame:CGRectMake(145, 420, 30, 30)
                                                     direction:M_PI/2
                                                     iconArray:icons];
        popUp;
    })];
    
    popUp.hidden = YES;

    NSLog(@"Navi frame = %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
    
    
    [self refreshMap];
    [self goCurrent];
    
    isChangingScreen = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MapViewEventHandler:)
                                                 name:@"MapViewEventHandler" object:nil];

    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapViewEventHandler" object:nil];

    
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
    
    

    [self fixScreenFrame];
    
    self.basketPin.hidden = ! self.basketPin.hidden;
    popUp.hidden =  ! popUp.hidden;
    
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
                
                
//                if (!_tableView.hidden) {
//                    [_tableView reloadData];
//                }
             });
 

        } else {
            NSLog(@"Load Baskets : FAIL");
        }
    }];

}

- (void)MapViewEventHandler:(NSNotification *)notification
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
    
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"didHideMenuViewController"]) {
        
        [self fixScreenFrame];
        
    }

}

@end
