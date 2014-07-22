//
//  DBLoginViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/27/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBLoginViewController.h"
#import <Parse/Parse.h>
#import "GlobalValue.h"
#import "DocbaketAPIClient.h"

@interface DBLoginViewController ()

@end

@implementation DBLoginViewController

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
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkLogin];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkLogin
{
    NSString *userID = GVALUE.userID;
    NSString *token = GVALUE.token;
    
    if(!IsEmpty(userID) && !IsEmpty(token) ) {
        self.title = @"Log out";
        _webView.hidden = YES;
        
        _hiLabel.hidden = NO;
        _nameLabel.hidden = NO;
        _logoutButton.hidden = NO;
        
        _nameLabel.text = GVALUE.userName;
        
        
    } else {
        self.title = @"Log in";
        _hiLabel.hidden = YES;
        _nameLabel.hidden = YES;
        _logoutButton.hidden = YES;
        
        _webView.hidden = NO;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MAINURL]]];
        
    }

}

- (void)logOut
{
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LOGOUTURL]]];
    
    //[GVALUE setUserID:@""];
    [GVALUE setUserName:@""];
    [GVALUE setToken:@""];
    [GVALUE setUserImage:@""];
    [self popVC];
    //[self checkLogin];
}

- (void) popVC{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)logoutButtonHandler:(id)sender
{
    [self logOut];
}

- (void)saveUserID
{
    id userID =  [self javaScriptFromString:@" $('*[data-user-id]').data('user-id')"];
    id userName = [self javaScriptFromString:@" $('*[data-user-name]').data('user-name')"];
    id userImage = [self javaScriptFromString:@" $('*[data-user-image]').data('user-image')"];
    if ([userID isKindOfClass:[NSString class]] && [userName isKindOfClass:[NSString class]])
    {
        
        [GVALUE setUserID:userID];
        [GVALUE setUserName:userName];
        if(!IsEmpty(userImage) && [userImage isKindOfClass:[NSString class]] ) [GVALUE setUserImage:userImage];
        
        NSLog(@"Saved UserID = %@", GVALUE.userID);
        NSLog(@"Saved userName = %@", GVALUE.userName);
        NSLog(@"Saved userImage = %@", GVALUE.userImage);
        
        [DocbaketAPIClient Login:^(BOOL success) {
            if(success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkLogin];
                    [self popVC];
                });
            }
        }];
    }
}

- (NSString*)javaScriptFromString:(NSString*)str
{
    return [_webView stringByEvaluatingJavaScriptFromString:str];
}


#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)theRequest navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[theRequest URL] absoluteString];
    NSString *path = [[theRequest URL] path];
    
    NSLog(@"path : %@", path);
    NSLog(@"currentURL : %@", url);
    
    if([path isEqualToString:@"/auth/facebook"] ||
       [path isEqualToString:@"/auth/linkedin"] ) {
        
        GVALUE.START_LOGIN = YES;
        
    }
    
    if( GVALUE.START_LOGIN &&
       ([path isEqualToString:@"/auth/facebook/callback"] ||
        [path isEqualToString:@"/auth/linkedin/callback"] )) {
           
           GVALUE.FIND_USERID = YES;
           
       }
    
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //    [indicator startAnimating];
    //    [indicatorBg setHidden:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if(GVALUE.START_LOGIN && GVALUE.FIND_USERID) {
        [self saveUserID];
        GVALUE.START_LOGIN = GVALUE.FIND_USERID = NO;
    }
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    //    NSString *errorMsg = nil;
    //
    //    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
    //        switch ([error code]) {
    //            case NSURLErrorCannotFindHost:
    //                errorMsg = NSLocalizedString(@"Can't find the specified server. Please re-type URL.", @"");
    //                break;
    //            case NSURLErrorCannotConnectToHost:
    //                errorMsg = NSLocalizedString(@"Can't connect to the server. Please try it again.", @"");
    //                break;
    //            case NSURLErrorNotConnectedToInternet:
    //                errorMsg = NSLocalizedString(@"Can't connect to the network. Please check your network.", @"");
    //
    //                if(WIFIView == nil) {
    //                    WIFIView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WIFI.png"]];
    //                    [WIFIView setFrame:webview.frame];
    //                    [WIFIView setBackgroundColor:[UIColor whiteColor]];
    //                    [WIFIView setContentMode:UIViewContentModeScaleAspectFit];
    //                    [self.view addSubview:WIFIView];
    //                }
    //
    //                if(WIFILabel == nil){
    //                    WIFILabel = [[UILabel alloc] initWithFrame:CGRectMake(57.0f, 300.0f, 207.0f, 89.0)];
    //                    WIFILabel.textColor = [UIColor whiteColor];
    //                    WIFILabel.text = NSLocalizedString(@"You are not connected to the network. Please connect to Wi-Fi or check your network again.", @"");
    //                    [WIFILabel setFont:BASIC_BOLD_FONT(12)];
    //                    WIFILabel.backgroundColor = [UIColor clearColor ];
    //                    [WIFILabel setTextColor:[UIColor blackColor]];
    //                    WIFILabel.lineBreakMode = UILineBreakModeTailTruncation;
    //                    WIFILabel.textAlignment = UITextAlignmentCenter;
    //                    WIFILabel.numberOfLines = 3;
    //                    [self.view  addSubview:WIFILabel];
    //                }
    //
    //                break;
    //            default:
    //                errorMsg = [error localizedDescription];
    //                break;
    //        }
    //    } else {
    //        errorMsg = [error localizedDescription];
    //    }
    //    
    //    NSLog(@"didFailLoadWithError: %@", errorMsg);
    //    
    //    [indicator stopAnimating];
    //    [indicatorBg setHidden:YES];
}

@end
