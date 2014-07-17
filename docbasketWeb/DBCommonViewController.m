//
//  DBCommonViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/26/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBCommonViewController.h"
#import "UIBarButtonItem+Badge.h"

@interface DBCommonViewController ()
< UIImagePickerControllerDelegate, UINavigationControllerDelegate >

@end

@implementation DBCommonViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DBCommonViewControllerEventHandler" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage* logoImage = [UIImage imageNamed:@"docbasketLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DBCommonViewControllerEventHandler:)
                                                 name:@"DBCommonViewControllerEventHandler" object:nil];

    
    // Do any additional setup after loading the view.
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor grayColor];// [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 0);
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],
//                                                           NSForegroundColorAttributeName,
//                                                           shadow, NSShadowAttributeName,
//                                                           [UIFont fontWithName:@"GillSans-Medium" size:21.0], NSFontAttributeName, nil]];
    
    //- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:self
//                                                                            action:@selector(presentLeftMenuViewController:)];
    

    
    
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)badgeNumber:(int)badgeValue
{
    if(badgeValue) {
        self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", badgeValue];
    } else {
        self.navigationItem.leftBarButtonItem.badgeValue = nil;
    }
}


- (void)DBCommonViewControllerEventHandler:(NSNotification *)notification
{
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"updateBadge"]) {
        
        if([self respondsToSelector:@selector(badgeNumber:)]){
            int badgeValue = (int)[[[notification userInfo] objectForKey:@"badgeValue"] integerValue];
            [self badgeNumber:badgeValue];
            
        }
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

//- (void)badgeNumber:(int)badgeValue
//{
//    if(badgeValue) {
//        GVALUE.badgeValue = badgeValue;
//        self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", badgeValue];
//    } else {
//        self.navigationItem.leftBarButtonItem.badgeValue = nil;
//    }
//}

- (void)handleTakePhotoButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *photo = info[UIImagePickerControllerOriginalImage];
//    UIImage *smallerPhoto = [self rescaleImage:photo toSize:CGSizeMake(800, 600)];
//    NSData *jpeg = UIImageJPEGRepresentation(smallerPhoto, 0.82);
//    [self dismissViewControllerAnimated:YES completion:^{
////        NSError *error = nil;
////        [_session sendData:jpeg toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
//    }];
}



#pragma mark - utility methods
- (UIImage*)rescaleImage:(UIImage*)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
