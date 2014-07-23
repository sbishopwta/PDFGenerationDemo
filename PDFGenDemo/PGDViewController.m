//
//  PGDViewController.m
//  PDFGenDemo
//
//  Created by Steven Bishop on 6/30/14.
//  Copyright (c) 2014 WillowTree Apps. All rights reserved.
//

#import "PGDViewController.h"
#import <MessageUI/MessageUI.h>

@interface PGDViewController ()

@property CGPoint lastPoint;
@property CGPoint moveBackTo;
@property CGPoint currentPoint;
@property CGPoint location;
@property NSDate *lastClick;
@property BOOL mouseSwiped;
@property UIImageView *drawImage;
@property UIImageView *frontImage;
@property (strong, nonatomic) IBOutlet UIWebView *mainWebView;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (strong, nonatomic) IBOutlet UIButton *connectTheDots;
@property (strong, nonatomic) IBOutlet UIImageView *connectTheDotsImage;
@property (nonatomic, retain) IBOutlet UIButton *buttonEmail;

@end

@implementation PGDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *pathString = [[NSBundle mainBundle] pathForResource:@"demoPDF" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:pathString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.mainWebView loadRequest:request];
    
	self.drawImage = [[UIImageView alloc] initWithImage:nil];
    self.drawImage.frame = self.overlayView.frame;
	[self.view addSubview:self.drawImage];
}

- (IBAction)showConnectTheDots:(id)sender
{
    if ([self.connectTheDotsImage isHidden])
    {
        [self.connectTheDotsImage setHidden:NO];
    }
    else
    {
        [self.connectTheDotsImage setHidden:YES];
    }
}

- (void)generatePDF:(NSString *)filePath
{
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[[self view] layer] renderInContext:context];
    
    UIGraphicsEndPDFContext();
}

- (IBAction)email:(id)sender
{
    NSString *filename = @"testPDF.pdf";
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *pdfPathWithFileName = [documentDirectory stringByAppendingPathComponent:filename];
    
    [self generatePDF:pdfPathWithFileName];
    
    //    NSLog(@"path:%@", pdfPathWithFileName);
    
    if([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc]init];
        mail.mailComposeDelegate= (id)self;
        [mail setSubject:@"PDF Demo"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *file = [documentsDirectory stringByAppendingPathComponent:@"testPDF.pdf"];
        NSData *data = [NSData dataWithContentsOfFile:file];
        
        [mail addAttachmentData:data mimeType:@"application/pdf" fileName:@"testPDF.pdf"];
        [self presentViewController:mail animated:YES completion:^{NSLog (@"Action Completed");}];
    }
    else
    {
        NSLog(@"Message cannot be sent");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog (@"mail finished");
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	
	if ([touch tapCount] == 2)
    {
        self.drawImage.image = nil;
	}
    
	self.location = [touch locationInView:touch.view];
	self.lastClick = [NSDate date];
	
    self.lastPoint = [touch locationInView:self.view];
    _lastPoint.y -= 0;
	
	[super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];
	self.currentPoint = [touch locationInView:self.view];
	
    UIGraphicsBeginImageContext(CGSizeMake(320, 568));
    [self.drawImage.image drawInRect:CGRectMake(0, 0, 320, 568)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    [self.drawImage setFrame:CGRectMake(0, 0, 320, 568)];
    self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.lastPoint = self.currentPoint;
	
	[self.view addSubview:self.drawImage];
}

@end
