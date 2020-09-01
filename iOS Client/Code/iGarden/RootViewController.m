//
//  RootViewController.m
//  iGarden
//
//  Created by Ben Voß on 11/06/2014.
//  Copyright (c) 2014 Ben Voß. All rights reserved.
//

#import "RootViewController.h"
#import "SwitchesViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
    
    [self showActivityView];
    
	_ioQueue = [[NSOperationQueue alloc] init];
	[_ioQueue setMaxConcurrentOperationCount:1];
    
	[self downloadState];
}

#pragma mark - Navigation

-(void)showActivityView {
	if (_overlayViewController == nil) {
		_overlayViewController = [[ActivityOverlayViewController alloc] initWithFrame:self.view.bounds];
	}
    
	[self.view insertSubview:_overlayViewController.view aboveSubview:self.view];
}

-(void)hideActivityView {
	[_overlayViewController.view removeFromSuperview];
}



-(void)downloadState {
	// Be sure to properly escape your url string.
	NSURL* url = [NSURL URLWithString:@"http://192.168.1.250:2000/relays/all"];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"GET"];
    
	[NSURLConnection sendAsynchronousRequest:request queue:_ioQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             // Success we have data
             NSLog(@"Success");
             
             NSError *jsonParsingError = nil;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
             
             if (jsonParsingError == nil) {
                 [self performSelectorOnMainThread:@selector(setState:) withObject:jsonArray waitUntilDone:YES];
             } else {
                 // Something went wrong parsing the response
                 NSLog(@"%@", jsonParsingError.localizedDescription);
                 [self performSelectorOnMainThread:@selector(hideActivityView) withObject:nil waitUntilDone:YES];
             }
             
         } else if ([data length] == 0 && error == nil) {
             NSLog(@"Empty response");
             [self performSelectorOnMainThread:@selector(hideActivityView) withObject:nil waitUntilDone:YES];
         } else if (error != nil && error.code == NSURLErrorTimedOut) {
             NSLog(@"Timed out");
             [self performSelectorOnMainThread:@selector(hideActivityView) withObject:nil waitUntilDone:YES];
         } else if (error != nil) {
             NSLog(@"%@", error.localizedDescription);
             [self performSelectorOnMainThread:@selector(hideActivityView) withObject:nil waitUntilDone:YES];
         }
         
     }];
}

-(void)setState: (NSArray*) state {
    UINavigationController* nc = (UINavigationController*)[self.viewControllers objectAtIndex:0];
    
    SwitchesViewController* s = (SwitchesViewController*)[nc.viewControllers objectAtIndex:0];
    
    [s setState:state];
    
    [self hideActivityView];
}

-(void)saveState:(NSArray*) switchState {
	
	NSData* jsonData;
	if([NSJSONSerialization isValidJSONObject:switchState])
	{
		jsonData = [NSJSONSerialization dataWithJSONObject:switchState options:0 error:nil];
	}
    
	NSOperation* op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadStateOperation:) object:jsonData];
	
	[_ioQueue cancelAllOperations];
	[_ioQueue addOperation:op];
}

-(void)uploadStateOperation:(NSData*)jsonData {
    
	// Be sure to properly escape your url string.
	NSURL* url = [NSURL URLWithString:@"http://192.168.1.250:2000/relays/all"];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody: jsonData];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", (unsigned int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
	
	NSURLResponse* response;
	NSError *error;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	if (error == nil) {
		NSLog(@"Success");
	} else {
		NSLog(@"Error");
	}
    
	//[NSThread sleepForTimeInterval:500];
	
    /*	[NSURLConnection sendAsynchronousRequest:request queue:_ioQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	 {
     if (error == nil) {
     NSLog(@"Success");
     } else {
     NSLog(@"Error");
     }
	 }];*/
}


@end
