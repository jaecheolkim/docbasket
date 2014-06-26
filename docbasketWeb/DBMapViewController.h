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
//<UIWebViewDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>



//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *addressInfo;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBasketButton;

@property (weak, nonatomic) IBOutlet UIButton *basketPin;
//@property (weak, nonatomic) IBOutlet UIButton *createHereButton;

//@property (nonatomic, strong) NSString *strURL;

//- (IBAction)refreshHandler:(id)sender;

- (IBAction)buttonHandler:(id)sender;

//- (IBAction)tabHandler:(id)sender;

- (IBAction)refreshCurrentLocation:(id)sender;

- (IBAction)createNewBasket:(id)sender;

//- (IBAction)createHereBasket:(id)sender;


@end

