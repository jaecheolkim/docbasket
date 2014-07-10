//
//  DBListViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/27/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBListViewController.h"
//#import "SCQRGeneratorViewController.h"
#import "DBBasketViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DBListViewController ()

@end

@implementation DBListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    self.title = @"My DocBasket";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
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
    return [GVALUE.baskets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Docbasket *basket = [GVALUE.baskets objectAtIndex:indexPath.row];
    if(!IsEmpty(basket)){
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.textLabel.text = basket.title;
        
        NSString *image = basket.image;
        if(!IsEmpty(image)){
            NSString *MyURL = [NSString stringWithFormat:@"%@%@",@"http://docbasket.com",image];
            if(!IsEmpty(MyURL)){
               
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView setImageWithURL:[NSURL URLWithString:MyURL] placeholderImage:nil];
                //cell.imageView = imgView ;
            }
            
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
    
    Docbasket *basket = [GVALUE.baskets objectAtIndex:indexPath.row];
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
