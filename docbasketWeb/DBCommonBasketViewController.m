//
//  DBCommonBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBCommonBasketViewController.h"
#import "DocbasketService.h"
@interface DBCommonBasketViewController ()

@end

@implementation DBCommonBasketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkMyBasket:(NSString*)filter completionHandler:(void (^)(BOOL success))block
//- (void)checkMyBasket:(NSString*)filter
{
    [DBKSERVICE checkMyBasket:filter completionHandler:^(NSArray *baskets) {
        if(!IsEmpty(baskets)){
            [self setBaskets:baskets];
            block(YES);
        } else {
            [self setBaskets:nil];
            block(NO);
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
