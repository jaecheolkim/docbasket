/*
 Copyright 2013 Scott Logic Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#import "SCViewController.h"
@import AVFoundation;
#import "SCShapeView.h"

@interface SCViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *metadataOutput;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    BOOL running;
    
    SCShapeView *_boundingBox;
    NSTimer *_boxHideTimer;
    UILabel *_decodedMessage;
}
@end

@implementation SCViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"QRScanner";
    
    // Create a new AVCaptureSession
    captureSession = [[AVCaptureSession alloc] init];
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 
    // Want the normal device
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [captureSession addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return;
    }
    
    metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [captureSession addOutput:metadataOutput];
    // What different things can we register to recognise?
    NSLog(@"%@", [metadataOutput availableMetadataObjectTypes]);
    
//    NSArray *metadataObjectTypes = [metadataOutput availableMetadataObjectTypes];
//    [metadataOutput setMetadataObjectTypes:metadataObjectTypes];
    
//    NSArray *metadataObjectTypes = @[
//    AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code,
//    AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    // We're only interested in QR Codes
    //[output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];


    // This VC is the delegate. Please call us on the main queue
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Display on screen
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.view.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:_previewLayer];
    
    
    // Add the view to draw the bounding box for the UIView
    _boundingBox = [[SCShapeView alloc] initWithFrame:self.view.bounds];
    _boundingBox.backgroundColor = [UIColor clearColor];
    _boundingBox.hidden = YES;
    [self.view addSubview:_boundingBox];
    
    // Add a label to display the resultant message
    _decodedMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 75, CGRectGetWidth(self.view.bounds), 75)];
    _decodedMessage.numberOfLines = 0;
    _decodedMessage.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
    _decodedMessage.textColor = [UIColor darkGrayColor];
    _decodedMessage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_decodedMessage];
    
    // Start the AVSession running
//    [captureSession startRunning];
    
    //[self startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}



- (void)startRunning {
    if (running) return;
    [captureSession startRunning];
    metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes;
    running = YES;
}
- (void)stopRunning {
    if (!running) return;
    [captureSession stopRunning];
    running = NO;
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if(running){
        for (AVMetadataObject *metadata in metadataObjects) {
            //if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
            if([transformed respondsToSelector:@selector(corners)]) {
                // Update the frame on the _boundingBox view, and show it
                _boundingBox.frame = transformed.bounds;
                _boundingBox.hidden = NO;
                // Now convert the corners array into CGPoints in the coordinate system
                //  of the bounding box itself
                NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                          fromView:self.view
                                                            toView:_boundingBox];
                
                // Set the corners array
                _boundingBox.corners = translatedCorners;
                
                // Update the view with the decoded text
                _decodedMessage.text = [transformed stringValue];
                
                // Start the timer which will hide the overlay
                [self startOverlayHideTimer];
                //}
            }

        }
    }

}

#pragma mark - Utility Methods
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(_boxHideTimer) {
        [_boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    _boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    _boundingBox.hidden = YES;
    _decodedMessage.text = @"";
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];

    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}


@end
