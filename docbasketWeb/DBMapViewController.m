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
#import "PlaceAnnotation.h"
#import "UIButton+WebCache.h"
#import "CHPopUpMenu.h"
#import "DocbasketService.h"
#import "DBBasketViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+addOn.h"
#import "SWTableViewCell.h"
#import "DBSearchPOIViewController.h"

@interface DBMapViewController () <SWTableViewCellDelegate>
{
    CGRect screenFrame;
    BOOL isChangingScreen;
    CHPopUpMenu *popUp;
}

@end

@implementation DBMapViewController

#pragma mark - ViewController

- (void)awakeFromNib
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UISearchBar *searchBar = [UISearchBar new];
//    searchBar.showsCancelButton = YES;
//    [searchBar sizeToFit];
//    UIView *barWrapper = [[UIView alloc]initWithFrame:searchBar.bounds];
//    [barWrapper addSubview:searchBar];
//    self.navigationItem.titleView = barWrapper;
    
    isChangingScreen = YES;

 
    self.basketPin.hidden = YES;
    
    [self fixScreenFrame];
    
    if(IsEmpty(popUp)){
        [self.view addSubview:({
            NSArray *icons = @[[UIImage imageNamed:@"files.png"],[UIImage imageNamed:@"photo.png"],[UIImage imageNamed:@"sound.png"],[UIImage imageNamed:@"time.png"],[UIImage imageNamed:@"Vault.png"]];
            
            popUp = [[CHPopUpMenu alloc]initWithFrame:CGRectMake(145, 420, 30, 30)
                                            direction:M_PI/2
                                            iconArray:icons];
            popUp;
        })];
    }
    

    
    popUp.hidden = YES;

    NSLog(@"Navi frame = %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
    

    
    
    
    isChangingScreen = NO;
    
    self.tableView.hidden = YES;
    
    [self refreshMap];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self goCurrent];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MapViewEventHandler:)
                                                 name:@"MapViewEventHandler" object:nil];
    
    if (GVALUE.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [GVALUE.mapItemList objectAtIndex:0];
        
//        self.title = mapItem.name;
        
        // add the single annotation to our map
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        
        [self.mapView addAnnotation:annotation];
        
        // we have only one annotation, select it's callout
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
        self.mapView.centerCoordinate = mapItem.placemark.coordinate;
    }
    else
    {
//        self.title = @"All Places";
        
        // add all the found annotations to the map
        for (MKMapItem *item in GVALUE.mapItemList)
        {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.url = item.url;
            
            [self.mapView addAnnotation:annotation];
        }
    }

    [GVALUE setMapItemList:nil];

    

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






#pragma mark - IBOutlet

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
    
    
//////////////////////////////////////////////////////////

//    [self fixScreenFrame];
//    
//    self.basketPin.hidden = ! self.basketPin.hidden;
//    popUp.hidden =  ! popUp.hidden;
//    
//    
//    [self handleTakePhotoButtonPressed:nil];
    
    self.mapView.hidden = !self.mapView.hidden;
    self.tableView.hidden = !self.tableView.hidden;
    
    if(!self.tableView.hidden) {
        self.addressInfo.hidden = YES;
        self.currentButton.hidden = YES;
        
        //self.addBasketButton.title = @"Map";
        self.addBasketButton.image = [UIImage imageNamed:@"map_icon.png"];
    } else {
        self.addressInfo.hidden = NO;
        self.currentButton.hidden = NO;
        
        //self.addBasketButton.title = @"List";
        self.addBasketButton.image = [UIImage imageNamed:@"List_Icon.png"];
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

- (IBAction)searchButtonHadler:(id)sender
{

    DBSearchPOIViewController *searchMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchMapViewController"];
    [self.navigationController pushViewController:searchMapViewController animated:YES];
}



#pragma mark - Methods

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
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.frame = CGRectMake(0, 20, screenFrame.size.width, 0);
            //[self hideAllAnnotations];
            popUp.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBar.frame = CGRectMake(0, 20, screenFrame.size.width, 44);
            popUp.alpha = 1;
            //[self showAllAnnotations];
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
    
    GVALUE.screenCenterCoordinate2D = [_mapView convertPoint:interestPoint toCoordinateFromView:_mapView];
    NSLog(@"screen Point : %@  / lat : %f / long : %f", NSStringFromCGPoint(interestPoint), GVALUE.screenCenterCoordinate2D.latitude, GVALUE.screenCenterCoordinate2D.longitude);
    
    GVALUE.screenCenterLocation = [[CLLocation alloc] initWithLatitude:GVALUE.screenCenterCoordinate2D.latitude longitude:GVALUE.screenCenterCoordinate2D.longitude];
    
    [DBKLocationManager reverseGeocodeLocation:GVALUE.screenCenterLocation completionHandler:^(NSString *address) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_addressInfo setTitle:address forState:UIControlStateNormal];
        });
        
        
        block(YES);
        
    }];
}


- (void)goCurrent
{
    GVALUE.currentCoordinate = [DBKLOCATION getCurrentCoordinate];
    GVALUE.screenCenterCoordinate2D = GVALUE.currentCoordinate;

    [self.mapView setRegion:MKCoordinateRegionMake(GVALUE.currentCoordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:NO];
}


- (void)removeAllAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    
    for (id overlay in [_mapView overlays]) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            [_mapView removeOverlay:overlay];
        }
    }

}

- (void)refreshMap
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self goCurrent];
        
        [self removeAllAnnotations];
        
        
        for(Docbasket *basket in GVALUE.baskets){
            if(!IsEmpty(basket)){

                CLCircularRegion * newRegion = [basket region];
                [self addPin:newRegion];

            }
        }
        
        [self refreshTableView];
    });

}

- (NSArray *)sortedBaskets
{
    NSArray *sortedBasket;
    sortedBasket = [GVALUE.baskets sortedArrayUsingComparator:^(Docbasket *firstBasket, Docbasket *secondBasket) {
        
        CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstBasket.latitude longitude:firstBasket.longitude];
        CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondBasket.latitude longitude:secondBasket.longitude];
        CLLocationDistance firstDistance = [GVALUE.currentLocation distanceFromLocation:firstLocation];
        CLLocationDistance secondDistance = [GVALUE.currentLocation distanceFromLocation:secondLocation];

        if (firstDistance < secondDistance)
            return (NSComparisonResult)NSOrderedAscending;
        else if (firstDistance > secondDistance)
            return (NSComparisonResult)NSOrderedDescending;
        else
            return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedBasket;

}

- (void)refreshTableView
{
    NSArray *sortedArray = [self sortedBaskets];
    [GVALUE setBaskets:sortedArray];
    
    [self.tableView reloadData];

    
}

- (void)addPin:(CLCircularRegion *)newRegion
{
    RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
    myRegionAnnotation.coordinate = newRegion.center;
    myRegionAnnotation.radius = newRegion.radius;
    [_mapView addAnnotation:myRegionAnnotation];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *photo = info[UIImagePickerControllerOriginalImage];
    UIImage *smallerPhoto = [self rescaleImage:photo toSize:CGSizeMake(800, 600)];
//    NSData *jpeg = UIImageJPEGRepresentation(smallerPhoto, 0.82);
    
    double latitude = GVALUE.screenCenterCoordinate2D.latitude;
    double longitude = GVALUE.screenCenterCoordinate2D.longitude;
    
    NSArray *arrayFilesData = @[smallerPhoto,];
    NSString *userID = GVALUE.userID;
    
    NSDictionary *parameters = @{@"user_id": userID, @"basket[title]": @"울사무실", @"basket[longitude]": @(longitude), @"basket[latitude]": @(latitude), @"files" : arrayFilesData};

    [self dismissViewControllerAnimated:YES completion:^{
        
        [DocbaketAPIClient createBasket:parameters completionHandler:^(NSDictionary *result)
        {
            if(!IsEmpty(result)){
                NSLog(@"result = %@", result);
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"latitude"] doubleValue], [result[@"longitude"] doubleValue]);
                [DBKLOCATION makeNewRegionMonitoring:coord withID:result[@"id"] withMap:self.mapView];

            } else {
                NSLog(@"Error ...");
            }
        }];
        
        //[DocbaketAPIClient createBasket:parameters];
        //        NSError *error = nil;
        //        [_session sendData:jpeg toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    }];
}

#pragma mark - MapViewEventHandler
- (void)MapViewEventHandler:(NSNotification *)notification
{
    

    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"currentAddress"]) {
        
        id address = [[notification userInfo] objectForKey:@"address"];
        if(!IsEmpty(address)){
            [_addressInfo setTitle:address forState:UIControlStateNormal];
            
        }
    }
    
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"didHideMenuViewController"]) {
        
        [self fixScreenFrame];
        
    }
    
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"refreshMap"]) {
        
        [self refreshMap];
        
    }
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"refreshGeoFencePins"]) {

        Docbasket *basket = [[notification userInfo] objectForKey:@"basket"];
        if(!IsEmpty(basket))
        {
            CLCircularRegion * newRegion = [basket region];
            [self addPin:newRegion];

        }

    }
    
    
    
    
    
    //    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"PopMenuPressed"]) {
    //
    //        CGPoint point = [[[notification userInfo] objectForKey:@"touchPoint"] CGPointValue];
    //
    //        NSLog(@"%@", NSStringFromCGPoint(point));
    //        
    //    }
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated");
    
    if(isChangingScreen || self.basketPin.hidden) return;
    //if(isChangingScreen) return;
    
    [self showNavigationBar:NO];
    
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(isChangingScreen || self.basketPin.hidden) return;
    //if(isChangingScreen) return;
    
    NSLog(@"regionDidChangeAnimated");
    
    [self showNavigationBar:YES];
    
    [self catchCurrentCenterAddress:^(bool find) {
        
    }];
    
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[RegionAnnotation class]]) {
        RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
        CLCircularRegion *region = currentAnnotation.region;
        
        Docbasket *findBasket = [GVALUE findBasketWithID:region.identifier];

        NSString *title = (IsEmpty(findBasket.title))?@"":findBasket.title;
        
        NSString *image = findBasket.image;
        NSString *ext = nil;
        UIImage *icon = [UIImage imageNamed:@"map.png"];//[UIImage imageNamed:@"RemoveRegion"];
        NSString *MyURL = nil;
        
        if(!IsEmpty(image)){
            
            ext = [image pathExtension];
            if([ext isEqualToString:@"png"] || [ext isEqualToString:@"PNG"] ||
               [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"JPG"] ){
                
                MyURL = image;
            }
        }

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
                [removeRegionButton setImageWithURL:[NSURL URLWithString:MyURL] forState:UIControlStateNormal placeholderImage:icon];
            } else {
                [removeRegionButton setImage:icon forState:UIControlStateNormal];
            }
            
            
            regionView.leftCalloutAccessoryView = removeRegionButton;
        } else {
            regionView.annotation = annotation;
            regionView.theAnnotation = annotation;
        }
        
        
// 핀 색 정의 시작
// Red    : private = userID가 내가 아니고 & is_public = NO
// Green  : public  = userID가 내가 아니고 & is_public = YES
// Purple : created = userID가 나일때.
        
        MKPinAnnotationColor pinColor;
        
        NSString *ownerID = findBasket.ownerID;
        int isPublic = (int)findBasket.is_public;
        if([GVALUE.userID isEqualToString:ownerID]) {
            pinColor = MKPinAnnotationColorPurple;
        } else {
            if(isPublic)
                pinColor = MKPinAnnotationColorGreen;
            else
                pinColor = MKPinAnnotationColorRed;
        }
        // 핀 색 정의
        regionView.pinColor = pinColor;
        
        // 혹시 핀을 이미지로 정의의 할 경우.
        //regionView.image = [UIImage new];
        
// 핀 색 정의 끝.
        
        
        
        

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
//    if([annotationView isKindOfClass:[RegionAnnotationView class]]) {
//        RegionAnnotationView *regionView = (RegionAnnotationView *)annotationView;
//        RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
//        
//        // If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
//        if (newState == MKAnnotationViewDragStateStarting) {
//            [regionView removeRadiusOverlay];
//            
//            [DBKLOCATION stopMonitoringRegion:regionAnnotation.region];
//        }
//        
//        // Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
//        if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
//            [regionView updateRadiusOverlay];
//            
//            
//            [DBKLOCATION makeNewRegionMonitoring:regionAnnotation.coordinate withID:regionAnnotation.region.identifier withMap:self.mapView];
//        }
//    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    RegionAnnotationView *regionView = (RegionAnnotationView *)view;
    RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
    NSString *basketID = regionAnnotation.region.identifier;
    NSLog(@"basketID = %@", basketID);
    
    NSArray *array = [SQLManager getDocBasketsForQuery:[NSString stringWithFormat:@"SELECT * FROM Docbasket WHERE id = '%@';", basketID]];
    if(!IsEmpty(array)) {
        Docbasket *basket = array[0];
        
        DBBasketViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DBBasketViewController"];
        viewcontroller.basket = basket;
        
        
        [self.navigationController pushViewController:viewcontroller animated:YES];
        
    }
//    [self.mapView setRegion:MKCoordinateRegionMake(regionAnnotation.coordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GVALUE.baskets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        //        [leftUtilityButtons sw_addUtilityButtonWithColor:
        //         [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
        //                                                    icon:[UIImage imageNamed:@"check.png"]];
        //        [leftUtilityButtons sw_addUtilityButtonWithColor:
        //         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
        //                                                    icon:[UIImage imageNamed:@"clock.png"]];
        //        [leftUtilityButtons sw_addUtilityButtonWithColor:
        //         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
        //                                                    icon:[UIImage imageNamed:@"cross.png"]];
        //        [leftUtilityButtons sw_addUtilityButtonWithColor:
        //         [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
        //                                                    icon:[UIImage imageNamed:@"list.png"]];
        //
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                    title:@"Delete"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                    title:@"Save"];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:self.tableView // Used for row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
        [cell setCellHeight:60];

        [cell.imageView setFrame:CGRectMake(0, 0, 60, 60)];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView setClipsToBounds:YES];
        [cell.imageView.layer setCornerRadius:8];
    }
    
    Docbasket *basket = [GVALUE.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
        
        CLLocation *cLocation = [[CLLocation alloc] initWithLatitude:basket.latitude longitude:basket.longitude];
        CLLocationDistance distance = [GVALUE.currentLocation distanceFromLocation:cLocation];
        
        NSString *image = basket.image;
        NSString *fileName = @"no file";

        [cell.imageView setImage:[UIImage imageNamed:@"map.png"]];
        
        if(!IsEmpty(image)){
            
            fileName = [image lastPathComponent]; 
            NSString *path = [image stringByDeletingLastPathComponent];
            NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"small_thumb", fileName ];
            
            __weak UITableViewCell *weakCell = cell;
//            __weak UIImageView *imgView = cell.imageView;
            
            [cell.imageView setImageWithURL:thumbPath
                           placeholderImage:[UIImage imageNamed:@"map.png"]
                                 completion:^(UIImage *image){
                                     
                                     if(!IsEmpty(image)){
                                         UIImage *iconImage = image;
                                         if (image.size.width != 48 || image.size.height != 48)
                                         {
                                             CGSize itemSize = CGSizeMake(48, 48);
                                             UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                                             CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                             [image drawInRect:imageRect];
                                             iconImage = UIGraphicsGetImageFromCurrentImageContext();
                                             UIGraphicsEndImageContext();
                                         }

                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
//
                                             
                                             weakCell.imageView.image = iconImage;
                                             [weakCell setNeedsLayout];
                                         });
                                     }
                                     
                                 }];

        }
        
        //cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", basket.title ];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%dm", (int)distance ];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //cell.textLabel.numberOfLines = 4;
    }
    
    
    return cell;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 60.0;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Docbasket *basket = [GVALUE.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
        
        //        SCQRGeneratorViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"SCQRGeneratorViewController"];
        //        viewcontroller.basketID = basket.basketID;
        //        viewcontroller.basket = basket;
        
        DBBasketViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DBBasketViewController"];
        viewcontroller.basket = basket;
        
        
        [self.navigationController pushViewController:viewcontroller animated:YES];
        
    }
    
}

#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            //            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            //
            //            [_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
            //            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
            
        }
        case 1:
        {
            //            NSLog(@"More button was pressed");
            //            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            //            [alertTest show];
            //
            //            NSInteger row = [indexPath row];
            
            [cell hideUtilityButtonsAnimated:YES];
            
//            self.selectedUser = [self.Users objectAtIndex:index];
//            
//            [self performSegueWithIdentifier:@"CaptureImages" sender:self];
            
            
            
            break;
            
        }
        default:
            break;
    }
}


@end
