//
//  DBMyDocBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBMyDocBasketViewController.h"
#import "RESideMenu.h"
//#import "UIBarButtonItem+Badge.h"
#import "GlobalValue.h"

@interface DBMyDocBasketViewController ()
<UITabBarControllerDelegate>
@end

@implementation DBMyDocBasketViewController

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
    
    self.delegate = self;

    self.title = @"My Basket";

//    if(IsEmpty(GVALUE.menuButton)) {
//        GVALUE.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *image = [UIImage imageNamed:@"list.png"];
//        GVALUE.menuButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
//        [GVALUE.menuButton setBackgroundImage:image forState:UIControlStateNormal];
//        
//        GVALUE.navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:GVALUE.menuButton];
//        
//    }
//    
//    [GVALUE.menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchDown];
//    [GVALUE.menuButton.badgeView setPosition:MGBadgePositionTopRight];
//    [GVALUE.menuButton.badgeView setBadgeColor:[UIColor redColor]];
//    self.navigationItem.leftBarButtonItem = GVALUE.navLeftButton;

    
    NSLog(@"UTTabar = %@", self.tabBar.items);
    for(UITabBarItem *tabBarItem in self.tabBar.items) {
        NSLog(@"item name = %@", tabBarItem.title);
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftBarButton = GVALUE.navLeftButton;
    self.navigationItem.leftBarButtonItem = leftBarButton;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
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
