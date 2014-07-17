//
//  DBMyDocBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBMyDocBasketViewController.h"
#import "RESideMenu.h"
#import "UIBarButtonItem+Badge.h"
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
    
    
    // Do any additional setup after loading the view.
    
    self.title = @"My Basket";
    
    // Build your regular UIBarButtonItem with Custom View
    UIImage *image = [UIImage imageNamed:@"list.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", GVALUE.badgeValue] ;
    self.navigationItem.leftBarButtonItem.badgeBGColor = self.navigationController.navigationBar.tintColor;
    
    NSLog(@"UTTabar = %@", self.tabBar.items);
    for(UITabBarItem *tabBarItem in self.tabBar.items) {
        NSLog(@"item name = %@", tabBarItem.title);
    }

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
