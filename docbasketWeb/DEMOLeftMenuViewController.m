//
//  DEMOLeftMenuViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "DEMOLeftMenuViewController.h"
#import "DBMapViewController.h"
#import "DBLoginViewController.h"
#import "DBMessageViewController.h"
#import "DBMyDocBasketViewController.h"
#import "ScannerViewController.h"
#import "DBSettingViewController.h"
#import "UIViewController+RESideMenu.h"

#import "GlobalValue.h"

@interface DEMOLeftMenuViewController ()

@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray *menuImages;
@property (strong, nonatomic) NSArray *viewContorllers;

@property (strong, readwrite, nonatomic) UITableView *tableView;

@property (nonatomic, strong) DBMapViewController *mapViewController;
@property (nonatomic, strong) DBMessageViewController *messageViewController;
@property (nonatomic, strong) DBMyDocBasketViewController *myBasketListViewController;
@property (nonatomic, strong) ScannerViewController *QRScannerViewController;
@property (nonatomic, strong) DBSettingViewController *settingViewController;
@property (nonatomic, strong) DBLoginViewController *loginViewController;
@end

@implementation DEMOLeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];

    _menuTitles = @[@"Map",  @"Message", @"My basket", @"QRCode", @"Setting"];
    _menuImages = @[@"map.png", @"message.png", @"mybasket.png", @"qrCamera.png", @"setting.png"];
 
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBMapViewController"];
    self.messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    self.myBasketListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBMyDocBasketViewController"];
    self.QRScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    self.settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBSettingViewController"];
    
//    _viewContorllers = @[ [[UINavigationController alloc] initWithRootViewController:self.mapViewController],
//                         [[UINavigationController alloc] initWithRootViewController:self.messageViewController],
//                         [[UINavigationController alloc] initWithRootViewController:self.myBasketListViewController],
//                         [[UINavigationController alloc] initWithRootViewController:self.QRScannerViewController],
//                         [[UINavigationController alloc] initWithRootViewController:self.settingViewController] ];
    
    
    if(IsEmpty(GVALUE.menuButton)) {
        GVALUE.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"list.png"];
        GVALUE.menuButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
        [GVALUE.menuButton setBackgroundImage:image forState:UIControlStateNormal];
        
        GVALUE.navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:GVALUE.menuButton];
        
    }
    
    [GVALUE.menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchDown];
    [GVALUE.menuButton.badgeView setPosition:MGBadgePositionTopRight];
    [GVALUE.menuButton.badgeView setBadgeColor:[UIColor redColor]];


    
}

- (void)moveToMessage
{
//    [self.sideMenuViewController setContentViewController:_viewContorllers[1] animated:YES];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.messageViewController]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self.sideMenuViewController setContentViewController:_viewContorllers[indexPath.row] animated:YES];
//    [self.sideMenuViewController hideMenuViewController];

    
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.mapViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.messageViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.myBasketListViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.QRScannerViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.settingViewController]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
//        case 5:
//            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.loginViewController]
//                                                         animated:YES];
//            [self.sideMenuViewController hideMenuViewController];
//            break;
        default:
            break;
    }
    
    
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        

    }
    
    cell.textLabel.text = _menuTitles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_menuImages[indexPath.row]];
    

    
    if(indexPath.row == 1){
        if(IsEmpty(GVALUE.messageIconView)){
            CGRect frame = CGRectMake(0, 0, 50, 60);
            GVALUE.messageIconView = [[UIImageView alloc] initWithFrame:frame];
            [GVALUE.messageIconView.badgeView setPosition:MGBadgePositionTopRight];
            [GVALUE.messageIconView.badgeView setBadgeColor:[UIColor redColor]];
            
            [cell.contentView addSubview:GVALUE.messageIconView];
        }
    }

    return cell;
}

@end
