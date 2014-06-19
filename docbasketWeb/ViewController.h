//
//  ViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController  <UIWebViewDelegate, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *addressInfo;
@property (nonatomic, strong) NSString *strURL;

- (IBAction)refreshHandler:(id)sender;

- (IBAction)buttonHandler:(id)sender;

- (IBAction)tabHandler:(id)sender;

@end

