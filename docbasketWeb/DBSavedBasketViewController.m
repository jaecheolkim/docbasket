//
//  DBSavedBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBSavedBasketViewController.h"
#import "DBBasketViewController.h"
#import "DocbasketService.h"
#import "UIImageView+addOn.h"
@interface DBSavedBasketViewController ()
@property (nonatomic,strong) NSArray *baskets;
@end

@implementation DBSavedBasketViewController

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
    
    self.title = @"Saved";
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //filter= created | invited | saved | public(default)
    [DBKSERVICE checkMyBasket:@"saved" completionHandler:^(NSArray *baskets) {
        self.baskets = baskets;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
//    //filter= created | invited | saved | public(default)
//    [self checkMyBasket:@"saved" completionHandler:^(BOOL success) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    }];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.baskets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell.imageView setFrame:CGRectMake(0, 0, 60, 60)];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView setClipsToBounds:YES];
        [cell.imageView.layer setCornerRadius:8];

        
    }
    
    Docbasket *basket = [self.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
 
        NSString *image = basket.image;

        if(!IsEmpty(image)){
            
            NSString *fileName = [image lastPathComponent];
            NSString *path = [image stringByDeletingLastPathComponent];
            NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"small_thumb", fileName ];

            __weak UITableViewCell *weakCell = cell;
            
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
        else {
            [cell.imageView setImage:[UIImage imageNamed:@"map.png"]];
        }

        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = basket.title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    return cell;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Docbasket *basket = [self.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
        
        //        SCQRGeneratorViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"SCQRGeneratorViewController"];
        //        viewcontroller.basketID = basket.basketID;
        //        viewcontroller.basket = basket;
        
        DBBasketViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DBBasketViewController"];
        viewcontroller.basket = basket;
        
        
        [self.navigationController pushViewController:viewcontroller animated:YES];
        
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
