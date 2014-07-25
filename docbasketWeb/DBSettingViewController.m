//
//  DBSettingViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/10/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBSettingViewController.h"
#import "DBLoginViewController.h"
#import "DBLogViewController.h"
#import "UIImageView+addOn.h"
#import "DocbasketService.h"

#define LINE_COLOR RGBA_COLOR(76.0, 76.0, 76.0, 0.5)
#define TEXT_COLOR RGB_COLOR(54.0, 54.0, 54.0)

@interface DBSettingViewController ()
{
    UISwitch *PushNotiSwitch;
    DBControlTableViewCell *monitoringRangeCell;
    DBControlTableViewCell *findBasketRangeCell;
    DBControlTableViewCell *checkInFilterCell;
    UITableViewCell *applyCell;
    
}
- (IBAction)sliderChanged:(id)sender;

- (IBAction)apply:(id)sender;

@end

@implementation DBSettingViewController

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
    
    self.tableView.delegate = self;
	self.tableView.dataSource = self;
    

    monitoringRangeCell = (DBControlTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"controlCell0"];
    findBasketRangeCell = (DBControlTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"controlCell1"];
    checkInFilterCell = (DBControlTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"controlCell2"];
    
    applyCell = [self.tableView dequeueReusableCellWithIdentifier:@"applyCell"];
    
    monitoringRangeCell.controlSlider.value = GVALUE.regionMonitoringDistance;
    monitoringRangeCell.controlValue.text = [NSString stringWithFormat:@"%0.1f",GVALUE.regionMonitoringDistance];
    
    findBasketRangeCell.controlSlider.value = GVALUE.findBasketsRange;
    findBasketRangeCell.controlValue.text = [NSString stringWithFormat:@"%0.f",GVALUE.findBasketsRange];
    
    checkInFilterCell.controlSlider.value = GVALUE.checkInTimeFiler;
    checkInFilterCell.controlValue.text = [NSString stringWithFormat:@"%0.f",GVALUE.checkInTimeFiler];
    
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DebugLogEventHandler:)
//                                                 name:@"DebugLogEventHandler" object:nil];

    
    
    //self.title = @"Debug Log";
    
     [self setNaviBarTitle:@"Setting"];
    
    
    
    // App Version
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    NSLog(@" App build = %@ / bundleName = %@", build, bundleName);

    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 510, 200, 22)];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:9];
    versionLabel.numberOfLines = 2;
    versionLabel.textColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:205.0/255.0 alpha:1.0];
    versionLabel.text = [NSString stringWithFormat:@"Version %@ \n %@", build, GVALUE.userID];//@"Version 1.0";
    [self.view addSubview:versionLabel];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DebugLogEventHandler" object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [GVALUE.LogList removeAllObjects];
    
    // Dispose of any resources that can be recreated.
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation");
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation");
    [self.tableView reloadData];
   
}



#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 120;
    else if(indexPath.section == 2)
        return 70;
    else
        return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 2;
    else if (section == 1) return 2;
    else if (section == 2) return 4;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 10.0;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
////#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    if(section == 2){
//        return 3;
//    }
//    return 2;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor =  [UIColor colorWithWhite:1.f alpha:0.5f].CGColor;
            layer.strokeColor = RGBA_COLOR(76.0, 76.0, 76.0, 0.5).CGColor; //tableView.separatorColor.CGColor;//[UIColor lightGrayColor].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
                lineLayer.backgroundColor = RGBA_COLOR(76.0, 76.0, 76.0, 0.5).CGColor; //tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

- (UILabel*)getTitleLabel:(NSString*)title tag:(int)tag color:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(25.0, 2.0, 210.0, 46.0)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:color] ;//]TEXT_COLOR]; 76 114 205
    [label setTag:tag];
    [label setText:title];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static int LOGINNAME_TAG            = 1000;
    static int PROFILE_TAG              = 1111;
    static int LOGINOUT_TAG             = 1010;
    static int AUTOALBUMSCAN_TAG        = 1020;
    static int PUSHNOTI_TAG             = 1030;
    static int PIXBEEINTRO_TAG          = 1040;
    static int RATEPIXBEE_TAG           = 1050;
    static int TERMOFUSE_TAG            = 1060;
    static int PUSHNOTICONTROL_TAG      = 1070;
//    static int AUTOALBUMSCANCONTROL_TAG = 1080;
    
    static NSString *LoginNameCell = @"LoginNameCell";
    static NSString *LoginOutCell = @"LoginOutCell";
    static NSString *AutoAlbumScanCell = @"AutoAlbumScanCell";
    static NSString *PushNotiCell = @"PushNotiCell";
    static NSString *PixbeeIntroCell = @"PixbeeIntroCell";
    static NSString *RatePixbeeCell = @"RatePixbeeCell";
    static NSString *TermOfUseCell = @"TermOfUseCell";
    
    UITableViewCell *cell;
    
    if(indexPath.section == 0){
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginNameCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginNameCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            CGSize contentSize = cell.contentView.frame.size;
            CGRect nameLabelFrame = CGRectMake(0.0, 80, contentSize.width, 40.0);
            CGRect profileImageFrame = CGRectMake(contentSize.width/2 - 30, 10, 60, 60);
            
            NSString *title = [NSString stringWithFormat:@"%@", GVALUE.userName];
            if(IsEmpty(title)) title = @"Unknown user";
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:LOGINNAME_TAG];
            UIImageView *profileImage = (UIImageView *)[cell.contentView viewWithTag:PROFILE_TAG];
            NSURL *profileURL = [NSURL URLWithString:GVALUE.userImage];
            
            if(nameLabel) {
                [nameLabel setText:title];
                [nameLabel setFrame:nameLabelFrame];
                //[(UILabel *)[cell.contentView viewWithTag:LOGINNAME_TAG] setText:title];
            } else {
                UILabel *label = [[UILabel alloc] initWithFrame:nameLabelFrame];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
                [label setBackgroundColor:[UIColor clearColor]];
                [label setTextColor:RGB_COLOR(76.0, 114.0, 205.0)];
                [label setTag:LOGINNAME_TAG];
                [label setText:title];

                //UILabel *label = [self getTitleLabel:title tag:LOGINNAME_TAG color:RGB_COLOR(76.0, 114.0, 205.0)];
                [cell.contentView addSubview:label];
            }
            
            if(profileImage) {
                
                [profileImage setFrame:profileImageFrame];
                
            } else {
                profileImage = [[UIImageView alloc] initWithFrame:profileImageFrame];
                
                [profileImage setTag:PROFILE_TAG];
                [cell.contentView addSubview:profileImage];
            }
            
            [profileImage setImageWithURL:profileURL placeholderImage:[UIImage imageNamed:@"login.png"]];
            
            [profileImage setContentMode:UIViewContentModeScaleAspectFill];
            [profileImage setClipsToBounds:YES];
            [profileImage.layer setBorderColor:[UIColor whiteColor].CGColor];
            [profileImage.layer setBorderWidth:2.0];
            [profileImage.layer setCornerRadius:profileImage.frame.size.width/2.0];

            
            

        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginOutCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginOutCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSString *title;
            if (!IsEmpty(GVALUE.token)) {
                title = @"Log-out";
            }
            else {
                title = @"Log-in";
            }
            
            
            //NSString *title = [NSString stringWithFormat:@"%@", @"Log-out"];
            if((UILabel *)[cell.contentView viewWithTag:LOGINOUT_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:LOGINOUT_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:LOGINOUT_TAG color:TEXT_COLOR];
                [cell.contentView addSubview:label];
            }
        }
        
    }
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:PushNotiCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PushNotiCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSString *title = @"Push Notification";
            if((UILabel *)[cell.contentView viewWithTag:PUSHNOTI_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:PUSHNOTI_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:PUSHNOTI_TAG color:TEXT_COLOR];
                [cell.contentView addSubview:label];
            }
            
            if((UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG]) {
                if(GVALUE.pushNotificationSetting){
                    [(UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG] setOn:YES];
                }
                else {
                    [(UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG] setOn:NO];
                }
                
            }
            else {
                PushNotiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250.0, 7.0, 94.0, 27.0)];
                [PushNotiSwitch setTag:PUSHNOTICONTROL_TAG];
             
                if(GVALUE.pushNotificationSetting){
                    [PushNotiSwitch setOn:YES];
                }
                else {
                    [PushNotiSwitch setOn:NO];
                }
             
                [PushNotiSwitch addTarget:self action:@selector(PushNotiSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:PushNotiSwitch];
            }
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:AutoAlbumScanCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoAlbumScanCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSString *title = @"Debug";
            if((UILabel *)[cell.contentView viewWithTag:AUTOALBUMSCAN_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:AUTOALBUMSCAN_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:AUTOALBUMSCAN_TAG color:RGB_COLOR(54.0, 54.0, 54.0)];
                [cell.contentView addSubview:label];
            }
            
            
        }

    }
    else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            cell = monitoringRangeCell;//(DBControlTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"controlCell0"];
            if (cell == nil) {
//                cell = [[DBControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PixbeeIntroCell];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
//                cell = _controlCell;
            }
 
            
//            NSString *title = @"DocBasket Intro";
//            if((UILabel *)[cell.contentView viewWithTag:PIXBEEINTRO_TAG]) {
//                [(UILabel *)[cell.contentView viewWithTag:PIXBEEINTRO_TAG] setText:title];
//            } else {
//                UILabel *label = [self getTitleLabel:title tag:PIXBEEINTRO_TAG color:TEXT_COLOR];
//                [cell.contentView addSubview:label];
//            }
            
        }
        else if (indexPath.row == 1) {
//            cell = [tableView dequeueReusableCellWithIdentifier:RatePixbeeCell];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RatePixbeeCell];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            }
//            
//            NSString *title = @"Rate DocBasket";
//            if((UILabel *)[cell.contentView viewWithTag:RATEPIXBEE_TAG]) {
//                [(UILabel *)[cell.contentView viewWithTag:RATEPIXBEE_TAG] setText:title];
//            } else {
//                UILabel *label = [self getTitleLabel:title tag:RATEPIXBEE_TAG color:TEXT_COLOR];
//                [cell.contentView addSubview:label];
//            }
            cell = findBasketRangeCell;//(DBControlTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"controlCell1"];
        }
        
        else if (indexPath.row == 2) {
//            cell = [tableView dequeueReusableCellWithIdentifier:TermOfUseCell];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TermOfUseCell];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            }
//            
//            
//            NSString *title = @"Term Of Use";
//            if((UILabel *)[cell.contentView viewWithTag:TERMOFUSE_TAG]) {
//                [(UILabel *)[cell.contentView viewWithTag:TERMOFUSE_TAG] setText:title];
//            } else {
//                UILabel *label = [self getTitleLabel:title tag:TERMOFUSE_TAG color:TEXT_COLOR];
//                [cell.contentView addSubview:label];
//            }
            cell = checkInFilterCell;//(DBControlTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"controlCell2"];
        }
        else if(indexPath.row == 3) {
            cell = applyCell;
        }
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1) // 로그인 / 로그아웃
        {
            NSLog(@"Login/Out");
            DBLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBLoginViewController"];
            
            [self.navigationController pushViewController:loginViewController animated:YES];
        }
    }
    
    if (indexPath.section == 1)
    {
        if (indexPath.row == 1) // Debug Log view
        {
            DBLogViewController *logViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DBLogViewController"];
            
            [self.navigationController pushViewController:logViewController animated:YES];
        }
    }


}




//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (indexPath.section == 0)
//    {
//        if (indexPath.row == 1) // 로그인 / 로그아웃
//        {
//            NSLog(@"Login/Out");
//            [self logoutButtonClickHandler:nil];
//        }
//    }
//
//    else if (indexPath.section == 2)
//    {
//        if (indexPath.row == 0) // Pixbee Intro
//        {
//            NSLog(@"Pixbee Intro");
//            IntroViewController *controller = [[IntroViewController alloc] init];
//            controller.callerID = @"SettingViewController";
//            
//            [self.navigationController pushViewController:controller animated:YES];
//            
//        }
//        else if (indexPath.row == 1) // Rate Pixbee
//        {
//            NSLog(@"Rate Pixbee");
//            [RFRateMe showRateAlert];
//        }
//        else if (indexPath.row == 2) // Term Of Use
//        {
//            NSLog(@"Term Of Use"); //@"SettingToFaceList"
//            [self performSegueWithIdentifier:@"SettingToFaceList" sender:self];
//        }
//    }
//}


- (void)PushNotiSwitchValueChanged : (id)sender
{
    if([(UISwitch *)sender isOn]) {
        GVALUE.pushNotificationSetting = 1;
    }
    else {
        GVALUE.pushNotificationSetting = 0;
    }
}

- (IBAction)sliderChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    switch (slider.tag) {
        case 0:
            NSLog(@"Monitoring range  = %f", slider.value);
            monitoringRangeCell.controlValue.text = [NSString stringWithFormat:@"%0.1f", slider.value];
            GVALUE.regionMonitoringDistance = slider.value;
            break;
        case 1:
            NSLog(@"Find basket range = %f", slider.value);
            findBasketRangeCell.controlValue.text = [NSString stringWithFormat:@"%0.f", slider.value];
            GVALUE.findBasketsRange = slider.value;
            break;
        case 2:
            NSLog(@"Check-in filter = %f", slider.value);
            checkInFilterCell.controlValue.text = [NSString stringWithFormat:@"%0.f", slider.value];
            GVALUE.checkInTimeFiler = slider.value;
            break;
        default:
            break;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (IBAction)apply:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ServiceEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"locationServiceStarted", @"currentLocation":GVALUE.currentLocation}];
    
    [DBKSERVICE getNewGeoFences];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"refreshMap"}];
}

//- (void)refresh
//{
//    [self.tableView reloadData];
//    
//    if (GVALUE.LogList.count > 0)
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:GVALUE.LogList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//
//}
//
//
//#pragma mark - Application's Cookie Handler
//- (void)DebugLogEventHandler:(NSNotification *)notification
//{
//    
//    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"logAdded"])
//    {
//        [self refresh];
//    }
//}
//
//#pragma mark - UITableViewDelegate
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [GVALUE.LogList count];
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *cellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    cell.textLabel.numberOfLines = 2;
//    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
//    
//    cell.textLabel.text = [GVALUE.LogList objectAtIndex:indexPath.row];
//
//
//
//    return cell;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 40.0;
//}
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    
//}



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
