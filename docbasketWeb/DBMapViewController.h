//
//  ViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DBCommonViewController.h"

@interface DBMapViewController : DBCommonViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *addressInfo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBasketButton;
@property (weak, nonatomic) IBOutlet UIButton *basketPin;

- (IBAction)buttonHandler:(id)sender;
- (IBAction)refreshCurrentLocation:(id)sender;
- (IBAction)createNewBasket:(id)sender;

@end

