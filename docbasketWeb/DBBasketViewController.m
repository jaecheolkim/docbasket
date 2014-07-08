//
//  DBBasketViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/3/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBBasketViewController.h"
#import "UIImage+QRCode.h"
#import "DocbaketAPIClient.h"
#import "GlobalValue.h"
#import "MEExpandableHeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "Docbasket.h"

@interface DBBasketViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *basketID;
    NSDictionary *basketInfo;

    UIImage *qrCodeImage;
    
}
@property (nonatomic,strong) NSArray *documents;

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) MEExpandableHeaderView *headerView;

@end

@implementation DBBasketViewController

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
    
    self.title = self.basket.title;
    basketID = self.basket.basketID;
    
    [self setupHeaderView];
    
    //qrCodeImage = [UIImage drawQRCode:basketID];
    
    [DocbaketAPIClient getBasketInfo:basketID completionHandler:^(NSDictionary *result)
    {
        basketInfo = result;
        
        self.documents = result[@"documents"];
        
        NSString *imageURL = result[@"image_thumb"];
        
        if(!IsEmpty(imageURL)) {
            [_headerView.backgroundImageView setImageWithURL:[NSURL URLWithString:imageURL] ];
        }
        
        //[headerView.backgroundImageView setImageWithURL:[NSURL URLWithString:result[@"image_thumb"]] ];

//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
//        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//        
//        //[headerView.backgroundImageView setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
//
//        
//        [headerView.backgroundImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            headerView.backgroundImageView.image = image;
//            headerView.originalImage = image;
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            
//        }];
        
        
        [self.tableView reloadData];
        
        if(!IsEmpty(self.documents)){
            int counter = 0;
            for(NSDictionary *doc in self.documents) {
                NSLog(@"result[%d] = %@", counter, doc);
                counter++;
            }
        }
        
    }];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    

}

- (void)refreshView
{
    
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupHeaderView
{
    CGSize headerViewSize = CGSizeMake(320, 200);
    UIImage *backgroundImage = [UIImage imageNamed:@"beach"];
    NSArray *pages = @[[self createPageViewWithText:@"First page"],
                       [self createPageViewWithText:@"Second page"],
                       [self createPageViewWithText:@"Third page"],
                       [self createPageViewWithText:@"Fourth page"]];
    
    self.headerView = [[MEExpandableHeaderView alloc] initWithSize:headerViewSize
                                                                      backgroundImage:backgroundImage
                                                                         contentPages:pages];
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Content

- (UIView*)createPageViewWithText:(NSString*)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    
    label.font = [UIFont boldSystemFontOfSize:27.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = text;
    
    return label;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[self.documents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"TableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *docbasket = [self.documents objectAtIndex:indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:docbasket[@"image_small_thumb"]]];
    cell.textLabel.text = docbasket[@"image_small_thumb"];

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView == self.tableView)
	{
        [self.headerView offsetDidUpdate:scrollView.contentOffset];
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
