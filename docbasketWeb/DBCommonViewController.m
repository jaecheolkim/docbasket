//
//  DBCommonViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/26/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBCommonViewController.h"
//#import "UIBarButtonItem+Badge.h"


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

    
    
    if(IsEmpty(GVALUE.menuButton)) {
        GVALUE.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"list.png"];
        GVALUE.menuButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
        [GVALUE.menuButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [GVALUE.menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchDown];
    [GVALUE.menuButton.badgeView setPosition:MGBadgePositionTopRight];
    [GVALUE.menuButton.badgeView setBadgeColor:[UIColor redColor]];

    GVALUE.navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:GVALUE.menuButton];

    self.navigationItem.leftBarButtonItem = GVALUE.navLeftButton;

}

- (void)setNaviBarTitle:(NSString *)title
{
    if(!IsEmpty(title)){
        self.navigationItem.titleView = nil;
        self.title = title;
    } else {
        UIImage* logoImage = [UIImage imageNamed:@"docbasketLogo.png"];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)badgeNumber:(int)badgeValue
//{
//    [GVALUE setBadgeValue:badgeValue];
//}


- (void)DBCommonViewControllerEventHandler:(NSNotification *)notification
{
    
//    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"updateBadge"]) {
//        
//        if([self respondsToSelector:@selector(badgeNumber:)]){
//            int badgeValue = (int)[[[notification userInfo] objectForKey:@"badgeValue"] integerValue];
//            [self badgeNumber:badgeValue];
//            
//        }
//    }
    
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
