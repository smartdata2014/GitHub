
//
//  WebserviceCall.m
//  Active Life
//
//  Created by sdnmacmini10 on 13/02/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import "WebserviceCall.h"
#import "AppDelegate.h"
//#import "LocalDataManager.h"
#import "LogInViewController.h"

static WebserviceCall *sharedInstance = nil;
UIActivityIndicatorView *activityIndicator;

@implementation WebserviceCall
@synthesize delegate;
@synthesize tag;
AppDelegate *appdelegate;
NSMutableData *globalData;
NSURLResponse *getResponse;
NSDictionary *getResponseDict;

//BOOL WSCalled=0;

//#define BASE_URL @"http://172.10.1.4:8613/fitness/webservices/"

//#define BASE_URL @"http://192.155.246.146:9052/fitness/webservices/"
//#define BASE_URL @"http://108.168.203.226:9194/fitness/webservices/"

#define BASE_URL @"http://192.155.246.146:9099/webservices/"

+ (id)sharedInstance
{
    static dispatch_once_t once;
    //static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)callWebserviceWithIdentifier:(NSString *)identifier andArguments :(NSDictionary *)arguments{
//    [self showActivityIndicator];

    NSLog(@"name..%@",identifier);
    NSLog(@"arguments..%@",arguments);
    
    appdelegate  = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate addChargementLoader];
    
//  ###################### Preparing Webservice URLs ###################    //
    
     NSString *finalUrlString = [BASE_URL stringByAppendingString:identifier];

    NSLog(@"finalUrlString..%@",finalUrlString);
    
//    ###################### Calling Webservice ###################    //
 
    BOOL isnetwork = [self connectedToInternet];
    
    /* Checking for Internet Connection Availability */
    
    if(isnetwork == NO)
    {
        UIAlertView *charAlert = [[UIAlertView alloc]
								  initWithTitle:@"No Internet Connection"
								  message:@"This application requires the use of the internet for getting data. Please close the application, check internet settings, and try again."
								  delegate:nil
								  cancelButtonTitle:@"Close"
								  otherButtonTitles:nil];
        
		[charAlert performSelectorOnMainThread:@selector(show)
                                    withObject:nil
                                 waitUntilDone:YES];
        [appdelegate removeChargementLoader];

    }
    else {
   /* Requesting webservice Call */
    NSError * writeError = nil;
  
    NSMutableURLRequest *mutableUrlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:finalUrlString]];
    [mutableUrlRequest setHTTPMethod:@"POST"];
    [mutableUrlRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [mutableUrlRequest setTimeoutInterval:150];
        
        if (arguments!=nil) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arguments options:NSJSONWritingPrettyPrinted error:&writeError];
            NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonData..%@",jsonRequest);
            NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
            [mutableUrlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [mutableUrlRequest setHTTPBody: requestData];
        }
        // Create url connection and fire request
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:mutableUrlRequest delegate:self];
            [conn start];
  }
}

- (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return ([response statusCode]==200)?YES:NO;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    globalData = [[NSMutableData alloc] init];
    getResponse = [[NSURLResponse alloc] init];
    getResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [globalData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError * error = nil;
    getResponseDict = [[NSMutableDictionary alloc] init];
    id jsonResponse = nil;
    NSString *success = nil;
    
    if (getResponse == nil) {
        // Check for problems
        if (error != nil) {
            //
            NSLog(@"curr_lat:%@",[error localizedDescription]);
            [self performSelectorOnMainThread:@selector(showAlert:)
                                   withObject:[error localizedDescription]
                                waitUntilDone:YES];
            
        }
    }
    else {
        // Data was received.. continue processing
        jsonResponse = [NSJSONSerialization JSONObjectWithData:globalData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"jsonResponse:%@",jsonResponse);
        if ([jsonResponse isKindOfClass:[NSDictionary class]]) {
            getResponseDict = (NSDictionary *)jsonResponse;
            success = [getResponseDict objectForKey:@"status"];
            
            if ([success isEqualToString:@"0"]) {
                if ([getResponseDict valueForKey:@"message"]) {
                    [self performSelectorOnMainThread:@selector(showAlert:)
                                           withObject:[getResponseDict valueForKey:@"message"]
                                        waitUntilDone:YES];
                }
            }

            NSLog(@"responseDict..%@",getResponseDict);
            if([[self delegate] respondsToSelector:@selector(webRequestFinished:forTag:)]) {
                [[self delegate] webRequestFinished:getResponseDict forTag:tag];
            }
        }
    }
    [appdelegate removeChargementLoader];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    NSLog(@"localizedDescription%@", [error localizedDescription]);
    if([[self delegate] respondsToSelector:@selector(webRequestFailed:)]) {
        [[self delegate] webRequestFailed:[error localizedDescription]];
    }
    [appdelegate removeChargementLoader];
}

#pragma mark - Show Alert

-(void)showAlert:(id)message{
    [AlertView showAlertwithTitle:@"Active Life App" message:message];
}

#pragma mark - Show Activity Indicators

-(void)showActivityIndicator{
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(137, 137, 60, 60)];
    activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.50];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.layer.borderWidth = 2.0;
    activityIndicator.layer.borderColor = [UIColor blueColor].CGColor;
    activityIndicator.layer.cornerRadius = 8.0f;
    [activityIndicator startAnimating];
     [[[[UIApplication sharedApplication] delegate] window] addSubview:activityIndicator];
}

-(void)hideActivityIndicator{
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}

#pragma mark - Texfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
