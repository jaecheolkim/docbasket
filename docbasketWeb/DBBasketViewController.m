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


#import "DEMOComment.h"
#import "DEMOPhoto.h"
#import "DEMOTag.h"
#import <QuartzCore/QuartzCore.h>
#import "EBPhotoPagesController.h"
#import "EBPhotoPagesFactory.h"
#import "EBTagPopover.h"
#import "SDWebImageManager.h"


@interface DBBasketViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *basketID;
    NSDictionary *basketInfo;

    UIImage *qrCodeImage;
    
}
@property (nonatomic,strong) NSArray *documents;

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) MEExpandableHeaderView *headerView;

@property (strong) NSArray *photos;
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
    NSDictionary *docbasket = [self.documents objectAtIndex:indexPath.row];
    [self initPhotos:docbasket];
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self];
    [self presentViewController:photoPagesController animated:YES completion:nil];
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



#pragma mark - EPPhotoPagesController

- (void)initPhotos:(NSDictionary *)docbasket
{
//    2014-07-11 00:06:59.756 docbasketWeb[12135:60b] result[0] = {
//        id = "64ae39ca-48f2-40b3-885e-6d895d183895";
//        image = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//        "image_small_thumb" = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/small_thumb_HandoffProgrammingGuide.pdf";
//        "image_thumb" = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/thumb_HandoffProgrammingGuide.pdf";
//        title = "<null>";
//        "total_pages" = 21;
//        "trans_done" = 1;
//        url = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//    }

    NSLog(@"basket = %@", docbasket);
   
    int trans_done = (int)(IsEmpty(docbasket[@"trans_done"])? 0 : [docbasket[@"trans_done"] integerValue]);

    if(trans_done) {
        
        NSArray *photo1Comments = @[
                                    [DEMOComment commentWithProperties:@{@"commentText": @"This is a comment!",
                                                                         @"commentDate": [NSDate dateWithTimeInterval:-252750 sinceDate:[NSDate date]],
                                                                         @"authorImage": [UIImage imageNamed:@"login"],
                                                                         @"authorName" : @"Aaron Alfred"}]
                                    ];
        
//        NSArray *photo5Comments = @[
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Looks fun, and greasy!",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-232500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"vladarbatov.jpg"],
//                                                                         @"authorName" : @"VLADARBATOV"}]
//                                    ];
//        
        NSArray *photo1Tags = @[
                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.565, 0.74)],
                                                             @"tagText" : @"Eddy Borja"}],
                                ];
//
//        NSArray *photo13Tags = @[
//                                 [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.74)],
//                                                              @"tagText" : @"Eddy Borja (爱迪)"}],
//                                 ];
//        
//        NSArray *photo0Tags = @[
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.53)],
//                                                             @"tagText" : @"Karla"}],
//                                ];
//        
//        
//        
//        NSArray *photo2Comments = @[
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"What is this?",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2341500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"iqonicd.jpg"],
//                                                                         @"authorName" : @"IqonICD"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"It's a Lego minifig.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2262500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"billskenney.jpg"],
//                                                                         @"authorName" : @"Bill S. Kenney"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Pretty cool.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-212500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"liang.jpg"],
//                                                                         @"authorName" : @"liang"}],
//                                    ];
//        
//        NSArray *photo2Tags = @[
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.11, 0.6)],
//                                                             @"tagText" : @"Sword"}],
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.60, 0.37)],
//                                                             @"tagText" : @"minifig"}],
//                                ];
//        
//        NSArray *photo8Tags = @[
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.65)],
//                                                             @"tagText" : @"guts!"}],
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6, 0.3)],
//                                                             @"tagText" : @"ZOmBiE!!"}],
//                                ];
//        
//        NSArray *photo8Comments = @[
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"GDC?",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2741500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"kaelifa.jpg"],
//                                                                         @"authorName" : @"Kaelifa"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Yup.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2499500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
//                                                                         @"authorName" : @"Eddy Borja"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"I want a 3D Printer...",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2299500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"tjrus.jpg"],
//                                                                         @"authorName" : @"TJRus"}],
//                                    ];
//        
//        NSArray *photo3Comments = @[
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Super hot peppers.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2991500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"g3d.jpg"],
//                                                                         @"authorName" : @"g3d"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Wow, that's a lot of peppers.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2881500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"amandabuzard.jpg"],
//                                                                         @"authorName" : @"AmandaBuzard"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"I don't know what this means....",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-27700 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"ateneupopular.jpg"],
//                                                                         @"authorName" : @"ateneupopular"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"How much did these cost?",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-26000 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"theaccordance.jpg"],
//                                                                         @"authorName" : @"The Accordance"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Pretty cheap, got the seeds from Australia.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-21500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
//                                                                         @"authorName" : @"Eddy Borja"}],
//                                    ];
//        
//        NSArray *photo3Tags = @[
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.42, 0.12)],
//                                                             @"tagText" : @"Damn"}],
//                                ];
//        
//        NSArray *photo11Tags = @[
//                                 [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.55)],
//                                                              @"tagText" : @"Team GoThriftGo"}],
//                                 ];
//        
//        NSArray *photo11Comments = @[
//                                     
//                                     [DEMOComment commentWithProperties:@{@"commentText": @"Congrats!",
//                                                                          @"commentDate": [NSDate dateWithTimeInterval:-2446500 sinceDate:[NSDate date]],
//                                                                          @"authorImage": [UIImage imageNamed:@"adellecharles.jpg"],
//                                                                          @"authorName" : @"Adelle Charles"}],
//                                     [DEMOComment commentWithProperties:@{@"commentText": @"follow up Series A round $2.2 million USD!",
//                                                                          @"commentDate": [NSDate dateWithTimeInterval:-2346500 sinceDate:[NSDate date]],
//                                                                          @"authorImage": [UIImage imageNamed:@"billskenney.jpg"],
//                                                                          @"authorName" : @"Bill S. Kenney"}],
//                                     
//                                     ];
//        
//        NSArray *photo13Comments = @[
//                                     
//                                     [DEMOComment commentWithProperties:@{@"commentText": @"走在街上",
//                                                                          @"commentDate": [NSDate dateWithTimeInterval:-4446500 sinceDate:[NSDate date]],
//                                                                          @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
//                                                                          @"authorName" : @"Eddy Borja"}],
//                                     
//                                     ];
//        
//        NSArray *photo0Comments = @[
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Great photo!",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-241500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"megdraws.jpg"],
//                                                                         @"authorName" : @"Meg Draws"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Pretty.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-21800 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"iqonicd.jpg"],
//                                                                         @"authorName" : @"IqonICD"}],
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"Wow!",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2600 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"karsh.jpg"],
//                                                                         @"authorName" : @"karsh"}],
//                                    ];
//        
//        NSArray *photo6Tags = @[
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0, 0)],
//                                                             @"tagText" : @"0,0"}],
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)],
//                                                             @"tagText" : @"Center"}],
//                                [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(1, 1)],
//                                                             @"tagText" : @"1,1"}],
//                                ];
//        
//        NSArray *photo6Comments = @[
//                                    
//                                    [DEMOComment commentWithProperties:@{@"commentText": @"That's a cool feature, it's always annoying when small images get blown up and pixelated.",
//                                                                         @"commentDate": [NSDate dateWithTimeInterval:-2221500 sinceDate:[NSDate date]],
//                                                                         @"authorImage": [UIImage imageNamed:@"kerem.jpg"],
//                                                                         @"authorName" : @"Kerem"}],
//                                    ];

        
        
        int totalPages = (int)(IsEmpty(docbasket[@"total_pages"])? 0 : [docbasket[@"total_pages"] integerValue]);
        
        NSString *baseURL = docbasket[@"url"];
        
        NSMutableArray *photos = [NSMutableArray array];
        
        for(int i = 1 ; i <= totalPages; i++)
        {
            
            DEMOPhoto *photo = [DEMOPhoto photoWithProperties:
                                @{@"imageURL" : [NSString stringWithFormat:@"%@/page%d.png",baseURL,i],
                                  @"imageFile": @"photo1.jpg",
                                  @"attributedCaption" : [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Documents page %d .",i]],
                                  @"tags": photo1Tags,
                                  @"comments" : photo1Comments,
                                  }];
            
            [photo setDisabledDelete:YES];
            
            [photos addObject:photo];
            
        }
        
        [self setPhotos:photos];

    }
    

}


#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < self.photos.count){
        return YES;
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];

        NSLog(@"URL = %@", photo.imageURL);
        
        NSURL *imgURL = photo.imageURL; //[NSURL URLWithString:@"https://www.apple.com/kr/home/images/og.jpg"]; //photo.imageURL;
        
//        NSData *imageData = [NSData dataWithContentsOfURL:imgURL];
//        UIImage* image = [[UIImage alloc] initWithData:imageData];
//        if (image) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                handler(image);
//            });
//        }
    
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:imgURL
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 // do something with image
                 
//                 handler(photo.image);
                 handler(image);
             }
             
         }];

//        sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        handler(photo.image);
     });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
attributedCaptionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSAttributedString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
//        if(self.simulateLatency){
//            sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        }
        
        handler(photo.attributedCaption);
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
      captionForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
//        if(self.simulateLatency){
//            sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        }
        
        handler(photo.caption);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
//        if(self.simulateLatency){
//            sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        }
        
        handler(photo.metaData);
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
//        if(self.simulateLatency){
//            sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        }
        
        handler(photo.tags);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
//        if(self.simulateLatency){
//            sleep(arc4random_uniform(2)+arc4random_uniform(2));
//        }
        
        handler(photo.comments);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
numberOfcommentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSInteger))handler
{
    DEMOPhoto *photo = self.photos[index];
//    if(self.simulateLatency){
//        sleep(arc4random_uniform(2)+arc4random_uniform(2));
//    }
    
    handler(photo.comments.count);
}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index
{
    DEMOPhoto *photo = self.photos[index];
    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    [remainingComments removeObject:deletedComment];
    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    DEMOPhoto *photo = self.photos[index];
    NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:photo.tags];
    id<EBPhotoTagProtocol> tagData = [tagPopover dataSource];
    [remainingTags removeObject:tagData];
    [photo setTags:[NSArray arrayWithArray:remainingTags]];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    NSLog(@"Delete photo at index %li", (long)index);
    DEMOPhoto *deletedPhoto = self.photos[index];
    NSMutableArray *remainingPhotos = [NSMutableArray arrayWithArray:self.photos];
    [remainingPhotos removeObject:deletedPhoto];
    [self setPhotos:remainingPhotos];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo
{
    NSLog(@"add new tag %@", tagText);
    
    DEMOPhoto *photo = self.photos[index];
    
    DEMOTag *newTag = [DEMOTag tagWithProperties:@{
                                                   @"tagPosition" : [NSValue valueWithCGPoint:tagLocation],
                                                   @"tagText" : tagText}];
    
    NSMutableArray *mutableTags = [NSMutableArray arrayWithArray:photo.tags];
    [mutableTags addObject:newTag];
    
    [photo setTags:[NSArray arrayWithArray:mutableTags]];
    
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index
{
    DEMOComment *newComment = [DEMOComment
                               commentWithProperties:@{@"commentText": comment,
                                                       @"commentDate": [NSDate date],
                                                       @"authorImage": [UIImage imageNamed:@"guestAv.png"],
                                                       @"authorName" : @"Guest User"}];
    [newComment setUserCreated:YES];
    
    DEMOPhoto *photo = self.photos[index];
    [photo addComment:newComment];
    
    [controller setComments:photo.comments forPhotoAtIndex:index];
}



#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledTagging){
        return NO;
    }
    
    return YES;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
 shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    //We assume all comment objects used in the demo are of type DEMOComment
    DEMOComment *demoComment = (DEMOComment *)comment;
    
    if(demoComment.isUserCreated){
        //Demo user can only delete his or her own comments.
        return YES;
    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledCommenting){
        return NO;
    } else {
        return YES;
    }
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledActivities){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledMiscActions){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledDelete){
        return NO;
    } else {
        return YES;
    }
}





- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledDeleteForTags){
        return NO;
    }
    
    return YES;
}




- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    if(index > 0){
        return YES;
    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return YES;
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
}

@end
