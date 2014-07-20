//
//  DBCreatedBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBCreatedBasketViewController.h"
#import "UIImageView+addOn.h"

@interface DBCreatedBasketViewController ()

@end

@implementation DBCreatedBasketViewController

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
    self.title = @"Created";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //filter= created | invited | saved | public(default)
    [self checkMyBasket:@"created" completionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Docbasket *basket = [self.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = basket.title;
        
        NSString *image = basket.image;
        if(!IsEmpty(image)){
            
            NSString *fileName = [image lastPathComponent];//[[image lastPathComponent] stringByDeletingPathExtension];
            NSString *path = [image stringByDeletingLastPathComponent];
            NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"small_thumb", fileName ];
            
            __weak UIImageView *imgView = cell.imageView;
            
            [cell.imageView setImageWithURL:thumbPath
                           placeholderImage:[UIImage imageNamed:@"map.png"]
                                 completion:^(UIImage *image){
                                     
                                     if(!IsEmpty(image)){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             imgView.image = image;
                                         });
                                     }
                                     
                                 }];
            
//            [cell.imageView setImageWithURL:[NSURL URLWithString:thumbPath] placeholderImage:[UIImage imageNamed:@"map.png"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"map.png"]];
        }
        
        
        cell.textLabel.numberOfLines = 4;
    }
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
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
