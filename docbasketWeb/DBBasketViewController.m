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


#import "DBComment.h"
#import "DBPhoto.h"
#import "DBTag.h"
#import <QuartzCore/QuartzCore.h>
#import "EBPhotoPagesController.h"
#import "EBPhotoPagesFactory.h"
#import "EBTagPopover.h"
#import "SDWebImageManager.h"

#import "UIAlertView+Blocks.h"

@interface DBBasketViewController () <UITableViewDataSource, UITableViewDelegate>
{
     UIImage *qrCodeImage;
    
}
@property (nonatomic,strong) NSDictionary *basketInfo;
@property (nonatomic,strong) NSString *basketID;
@property (nonatomic,strong) NSString *documentID;
@property (nonatomic,strong) NSArray *documents;
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic,strong) NSArray *comments;

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
    self.basketID = self.basket.basketID;
    
    [self setupHeaderView];
    
    //qrCodeImage = [UIImage drawQRCode:basketID];
    
    [self refreshView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0, 40, 20);
    [button addTarget:self action:@selector(saveBasket:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = navButton;

}

- (void)saveBasket:(id)sender
{
    [DocbaketAPIClient saveDocBasket:self.basketID completionHandler:^(BOOL success) {
        NSString *msg = @"Success";
        if(!success)
            msg = @"Fail";
        
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"save to my basket"
                           cancelButtonItem:[RIButtonItem itemWithLabel:@"OK" action:^
        {
            

        }]
                           otherButtonItems:nil, nil] show];
    }];
}


//2014-07-15 18:35:23.136 docbasketWeb[16788:60b] JSON: {
//    "begin_at" = "<null>";
//    comments =     (
//    );
//    "created_at" = "2014-07-10T14:11:44.778Z";
//    description = "\Ubb38\Uc11c \Ud14c\Uc2a4\Ud2b8\Uc6a9";
//    documents =     (
//                     {
//                         id = "64ae39ca-48f2-40b3-885e-6d895d183895";
//                         image = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//                         title = "<null>";
//                         "total_pages" = 21;
//                         "trans_done" = 1;
//                         url = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b/HandoffProgrammingGuide.pdf";
//                     }
//                     );
//    "end_at" = "<null>";
//    id = "b5cc97fe-e568-4fd9-b3d4-bcf5b31c513b";
//    image = "http://0c86568b33ba49994159-f6bbd63f18dffb4beb7359283894d4fe.r82.cf6.rackcdn.com/Adobe-PDF-Document-icon.png";
//    "is_public" = 1;
//    latitude = "37.5618353639392";
//    longitude = "126.989598870277";
//    permission =     (
//    );
//    "poi_id" = "<null>";
//    "poi_title" = "<null>";
//    range = "<null>";
//    tags =     (
//    );
//    title = "\Ubb38\Uc11c \Uc0d8\Ud50c";
//    "updated_at" = "2014-07-10T14:11:44.778Z";
//    "user_id" = "bb5774c9-2c4e-41d0-b792-530e295e1ca6";
//}

- (void)refreshView
{
    [DocbaketAPIClient getBasketInfo:self.basketID completionHandler:^(NSDictionary *result)
     {
         if(!IsEmpty(result)){
             
             self.basketInfo = result;
             
             self.tags = self.basketInfo[@"tags"];
             self.comments = self.basketInfo[@"comments"];
             self.documents = self.basketInfo[@"documents"];
             
             NSString *imagePath = self.basketInfo[@"image"];

             NSString *fileName = [imagePath lastPathComponent];
             NSString *path = [imagePath stringByDeletingLastPathComponent];
             NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"thumb", fileName ];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(!IsEmpty(thumbPath)) {
                     [_headerView.backgroundImageView setImageWithURL:[NSURL URLWithString:thumbPath] ];
                 }
                 
                 [self.tableView reloadData];
                 
             });
             
         } else {
             
             [[[UIAlertView alloc] initWithTitle:@"Need refresh."
                                         message:@"refresh again"
                                cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes"
                                                                      action:^{
                                                                          
                                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                                          
                                                                      }]
                                otherButtonItems:nil, nil] show];
             
         }
         
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation");
    
    [self setupHeaderView];
}


//- (void)fixScreenFrame
//{
//    UIInterfaceOrientation statusBarOrientation =  [UIApplication sharedApplication].statusBarOrientation;
//    CGRect screenFrame = [[UIScreen mainScreen] bounds];
//    
//    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
//        screenFrame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
//    }
//    
// }


#pragma mark - Setup

- (void)setupHeaderView
{
    UIInterfaceOrientation statusBarOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        screenFrame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    }
    
    CGSize headerViewSize = CGSizeMake(screenFrame.size.width, 200);
    UIImage *backgroundImage = [UIImage imageNamed:@"beach"];
    NSArray *pages = @[[self createPageViewWithText:@"First page"],
                       [self createPageViewWithText:@"Second page"],
                       [self createPageViewWithText:@"Third page"],
                       [self createPageViewWithText:@"Fourth page"]];
    
    
    if(self.headerView){
        [self setHeaderView:nil];
    }
    
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
    
    NSString *imagePath = docbasket[@"image"];
    NSString *fileName = [imagePath lastPathComponent];//[[image lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [imagePath stringByDeletingLastPathComponent];
    NSString *thumbPath = [NSString stringWithFormat:@"%@/%@_%@",path, @"small_thumb", fileName ];

    
    [cell.imageView setImageWithURL:[NSURL URLWithString:thumbPath]];
    cell.textLabel.text = fileName;

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectDocument:indexPath.row];
    
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
- (NSArray*)getComments:(NSArray*)arrays
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSMutableArray *commentArray = [NSMutableArray array];
    for(NSDictionary *data in arrays){
        

        NSDate *date = [dateFormatter dateFromString:data[@"created_at"]];
        
        NSDictionary *commentData = @{
                                  @"commentText"    : data[@"description"],
                                  @"commentDate"    : [NSDate dateWithTimeInterval:-252750 sinceDate:date],
                                  @"authorImage"    : [UIImage imageNamed:@"login"],
                                  @"authorName"     : @"test user",
                                  @"basket_id"      : data[@"basket_id"],
                                  @"document_id"    : data[@"document_id"],
                                  @"comment_id"     : data[@"id"],
                                  @"user_id"        : data[@"user_id"]
                                  };

        [commentArray addObject:[DBComment commentWithProperties:commentData]];
    }
    
    return commentArray;
}

- (NSArray*)getTags:(NSArray*)arrays
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSMutableArray *tagArray = [NSMutableArray array];
    for(NSDictionary *data in arrays){
        
        //NSDate *date = [dateFormatter dateFromString:data[@"created_at"]];
        double position_x = [data[@"cord_x"] doubleValue];
        double position_y = [data[@"cord_y"] doubleValue];
        
        CGPoint position = CGPointMake(position_x, position_y);
        NSDictionary *tagData = @{
                                      @"tagText"        : data[@"description"],
                                      @"tagPosition"    : [NSValue valueWithCGPoint:position],
                                      @"basket_id"      : data[@"basket_id"],
                                      @"document_id"    : data[@"document_id"],
                                      @"tag_id"     : data[@"id"],
                                      @"user_id"        : data[@"user_id"]
                                      };

        [tagArray addObject:[DBTag tagWithProperties:tagData]];
    }
    
    return tagArray;
}

- (void)selectDocument:(NSUInteger)index
{
    NSDictionary *document = [self.documents objectAtIndex:index];
    [self initDocument:document];
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self];
    [self presentViewController:photoPagesController animated:YES completion:nil];

}

- (void)initDocument:(NSDictionary *)document
{
//    2014-07-15 14:17:11.435 docbasketWeb[16430:60b] basket = {
//        id = "410d1e2c-f6f4-4ba8-971e-2f58689bce70";
//        image = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/f54669cc-40d4-4092-b2ad-f2d8e44eebcf/hogwarts_maknaes.jpg";
//        title = "<null>";
//        "total_pages" = "<null>";
//        "trans_done" = "<null>";
//        url = "http://784ef83b7b46bb15457a-04b6f40c42df035229c196abf487bf09.r25.cf6.rackcdn.com/f54669cc-40d4-4092-b2ad-f2d8e44eebcf/hogwarts_maknaes.jpg";
//    }

    NSLog(@"document = %@", document);
   
    int trans_done = (int)(IsEmpty(document[@"trans_done"])? 0 : [document[@"trans_done"] integerValue]);

    if(TRUE) {
        
        self.documentID = document[@"id"];
        
        int totalPages = (int)(IsEmpty(document[@"total_pages"])? 0 : [document[@"total_pages"] integerValue]);
        


        
        NSArray *photo1Comments = @[
                                    [DBComment commentWithProperties:@{@"commentText": @"This is a comment!",
                                                                         @"commentDate": [NSDate dateWithTimeInterval:-252750 sinceDate:[NSDate date]],
                                                                         @"authorImage": [UIImage imageNamed:@"login"],
                                                                         @"authorName" : @"user1"}]
                                    ];
        
        NSArray *photo1Tags = @[
                                [DBTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.565, 0.74)],
                                                             @"tagText" : @"tag test"}],
                                ];
        

        
        NSString *baseURL = document[@"url"];
        
        NSMutableArray *photos = [NSMutableArray array];
        
        
        for(int i = 1 ; i <= totalPages; i++)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"page", i-1];
            NSArray *filteredCommentArray = [document[@"commets"] filteredArrayUsingPredicate:predicate];
            NSArray *filteredTagArray = [document[@"tags"] filteredArrayUsingPredicate:predicate];
            NSLog(@"filteredCommentArray = %@", filteredCommentArray);
            
            NSArray *commentArray = [self getComments:filteredCommentArray];
            NSArray *tagArray = [self getTags:filteredTagArray];
            NSLog(@"comment array = %@", commentArray);

            
            
            DBPhoto *photo = [DBPhoto photoWithProperties:
                                @{@"imageURL" : [NSString stringWithFormat:@"%@/page%d.png",baseURL,i],
                                  @"imageFile": @"photo1.jpg",
                                  @"attributedCaption" : [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Documents page %d .",i]],
                                  @"tags": tagArray,
                                  @"comments" : commentArray,
                                  }];
            
            //[photo setDisabledDelete:YES];
            
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
        DBPhoto *photo = self.photos[index];

        NSLog(@"URL = %@", photo.imageURL);
        
        NSURL *imgURL = photo.imageURL;
        
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
        DBPhoto *photo = self.photos[index];
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
        DBPhoto *photo = self.photos[index];
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
        DBPhoto *photo = self.photos[index];
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
        DBPhoto *photo = self.photos[index];
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
        DBPhoto *photo = self.photos[index];
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
    DBPhoto *photo = self.photos[index];
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
    DBPhoto *photo = self.photos[index];
    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    [remainingComments removeObject:deletedComment];
    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    DBPhoto *photo = self.photos[index];
    NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:photo.tags];
    id<EBPhotoTagProtocol> tagData = [tagPopover dataSource];
    [remainingTags removeObject:tagData];
    [photo setTags:[NSArray arrayWithArray:remainingTags]];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    NSLog(@"Delete photo at index %li", (long)index);
    DBPhoto *deletedPhoto = self.photos[index];
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
    
    DBPhoto *photo = self.photos[index];
    
    DBTag *newTag = [DBTag tagWithProperties:@{
                                                   @"tagPosition" : [NSValue valueWithCGPoint:tagLocation],
                                                   @"tagText" : tagText}];
    
    NSMutableArray *mutableTags = [NSMutableArray arrayWithArray:photo.tags];
    [mutableTags addObject:newTag];
    
    [photo setTags:[NSArray arrayWithArray:mutableTags]];
    
    ///api/tags      POST  (header: token), basket_id, document_id, page, description, cord_x, cord_y
    NSDictionary *param = @{@"basket_id":self.basketID,@"document_id":self.documentID, @"page":@(index), @"description":tagText, @"cord_x":@(tagLocation.x), @"cord_y":@(tagLocation.y) };
    [DocbaketAPIClient postTag:param completionHandler:^(NSDictionary *result) {
        
    }];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index
{
    NSString *userName = (!IsEmpty(GVALUE.userName))?GVALUE.userName:@"Guest user";
    
    DBComment *newComment = [DBComment commentWithProperties:@{@"commentText": comment,
                                                                   @"commentDate": [NSDate date],
                                                                   @"authorImage": [UIImage imageNamed:@"login.png"],
                                                                   @"authorName" : userName } ];
    [newComment setUserCreated:YES];
    
    DBPhoto *photo = self.photos[index];
    [photo addComment:newComment];
    
    [controller setComments:photo.comments forPhotoAtIndex:index];
    
//    /api/comments      POST  (header: token), basket_id, document_id, page, description
    
    NSDictionary *param = @{@"basket_id":self.basketID,@"document_id":self.documentID, @"page":@(index), @"description":comment};
    [DocbaketAPIClient postComment:param completionHandler:^(NSDictionary *result)
    {
        
    }];
 }



#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
    DBComment *demoComment = (DBComment *)comment;
    
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
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
    
    DBPhoto *photo = (DBPhoto *)self.photos[index];
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
