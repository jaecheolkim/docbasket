//
//  ViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCommonViewController.h"

@interface ScannerViewController : DBCommonViewController <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray * allowedBarcodeTypes;

@end
