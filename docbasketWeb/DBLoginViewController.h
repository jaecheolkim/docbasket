//
//  DBLoginViewController.h
//  docbasketWeb
//
//  Created by jaecheol kim on 6/27/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DBCommonViewController.h"

@interface DBLoginViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UILabel *hiLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;

- (IBAction)logoutButtonHandler:(id)sender;

@end
