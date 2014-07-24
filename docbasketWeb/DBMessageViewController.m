//
//  DBInvitedBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBMessageViewController.h"
#import "DBBasketViewController.h"
#import "DocbasketService.h"
#import "Message.h"
#import "UIImageView+addOn.h"
#import "SWTableViewCell.h"

@interface DBMessageViewController () <SWTableViewCellDelegate>
@property (nonatomic,strong) NSArray *messages;

@end

@implementation DBMessageViewController

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

    [self setNaviBarTitle:@"Message"];
   

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [DBKSERVICE checkMessage:^(NSArray *messages) {
        NSLog(@"Messages = %@", messages);
        [self setMessages:messages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self checkNotiBasket];
        });
    }];
    
    [GVALUE setBadgeValue:0];
    
    //filter= created | invited | saved | public(default)
//    [DBKSERVICE checkMyBasket:@"invited" completionHandler:^(NSArray *baskets)
//    {
//        self.baskets = baskets;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//            
//            [self checkNotiBasket];
//        });
//
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkNotiBasket
{
    NSString *notiBaskeID = GVALUE.notiBasketID;
    
    if(!IsEmpty(notiBaskeID)){
        for(Message *message in self.messages)
        {
            Docbasket *basket = message.basket;
            
            if([basket.basketID isEqualToString:notiBaskeID])
            {
                [GVALUE setNotiBasketID:@""];
                
//                UIApplicationState state = [[UIApplication sharedApplication ]applicationState];
//                if ( state == UIApplicationStateActive ) {
                    DBBasketViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DBBasketViewController"];
                    viewcontroller.basket = basket;
                    [self.navigationController pushViewController:viewcontroller animated:YES];
//                }
                
                break;

            }
            
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    Docbasket *basket = message.basket;
    
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                    title:@"Delete"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                    title:@"Save"];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:self.tableView // Used for row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
        [cell setCellHeight:60];
        
        [cell.imageView setFrame:CGRectMake(0, 0, 60, 60)];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView setClipsToBounds:YES];
        [cell.imageView.layer setCornerRadius:8];
    }

    

    
    if(!IsEmpty(basket)){
        
        CLLocation *cLocation = [[CLLocation alloc] initWithLatitude:basket.latitude longitude:basket.longitude];
        CLLocationDistance distance = [GVALUE.currentLocation distanceFromLocation:cLocation];
        
        NSString *image = basket.image;
        NSString *fileName = @"no file";
        
        [cell.imageView setImage:[UIImage imageNamed:@"map.png"]];
        
        if(!IsEmpty(image)){
            
            fileName = [image lastPathComponent];
            NSString *path = [image stringByDeletingLastPathComponent];
            NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"small_thumb", fileName ];
            
            __weak UITableViewCell *weakCell = cell;
            //            __weak UIImageView *imgView = cell.imageView;
            
            [cell.imageView setImageWithURL:thumbPath
                           placeholderImage:[UIImage imageNamed:@"map.png"]
                                 completion:^(UIImage *image){
                                     
                                     if(!IsEmpty(image)){
                                         UIImage *iconImage = image;
                                         if (image.size.width != 48 || image.size.height != 48)
                                         {
                                             CGSize itemSize = CGSizeMake(48, 48);
                                             UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                                             CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                             [image drawInRect:imageRect];
                                             iconImage = UIGraphicsGetImageFromCurrentImageContext();
                                             UIGraphicsEndImageContext();
                                         }
                                         
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             //
                                             
                                             weakCell.imageView.image = iconImage;
                                             [weakCell setNeedsLayout];
                                         });
                                     }
                                     
                                 }];
            
        }
        
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", message.title, basket.title];
    cell.detailTextLabel.text = message.created_at;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    Docbasket *basket = message.basket;
    
    if(!IsEmpty(basket)){
        
        //        SCQRGeneratorViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"SCQRGeneratorViewController"];
        //        viewcontroller.basketID = basket.basketID;
        //        viewcontroller.basket = basket;
        
        DBBasketViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DBBasketViewController"];
        viewcontroller.basket = basket;
        
        
        [self.navigationController pushViewController:viewcontroller animated:YES];
        
    }
    
}


#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            //            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            //
            //            [_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
            //            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
            
        }
        case 1:
        {
            //            NSLog(@"More button was pressed");
            //            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            //            [alertTest show];
            //
            //            NSInteger row = [indexPath row];
            
            [cell hideUtilityButtonsAnimated:YES];
            
            //            self.selectedUser = [self.Users objectAtIndex:index];
            //
            //            [self performSegueWithIdentifier:@"CaptureImages" sender:self];
            
            
            
            break;
            
        }
        default:
            break;
    }
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
