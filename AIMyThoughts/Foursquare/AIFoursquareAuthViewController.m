//
//  AIFoursquareAuthViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFoursquareAuthViewController.h"
#import "AIFoursquareAdapter.h"
#import "AIAppDelegate.h"

@interface AIFoursquareAuthViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView* webView;

@end

@implementation AIFoursquareAuthViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Log In", nil);
    
    [self removeCookiesPreviousAutorization];
    
    [self sendAutorizationRequestToFoursquare];
}

- (void) sendAutorizationRequestToFoursquare
{
    NSString* authorizationUrl = [[AIFoursquareAdapter sharedInstance] authorizationUrl];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: authorizationUrl]];
    [self.webView loadRequest: request];
}

#pragma mark - UIWebViewDelegate method

- (void) webViewDidFinishLoad: (UIWebView*) webView
{
    NSString* source = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByTagName('html')[0].outerHTML"];
    
    //    NSLog(@"========\n");
    //    NSLog(@"%@\n", source);
    //    NSLog(@"========\n");
    
    NSRange range = [source rangeOfString: @"id=\"loginToFoursquare\""];
    
    if (range.location != NSNotFound)
    {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByName('emailOrPhone')[0].value = '%@';", kDefaultFoursquareAccountUserName]];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByName('password')[0].value = '%@';", kDefaultFoursquareAccountPassword]];
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('loginToFoursquare').submit();"];
    }
}

- (BOOL) webView: (UIWebView*) webView shouldStartLoadWithRequest: (NSURLRequest*) request navigationType: (UIWebViewNavigationType) navigationType
{
    NSURL* requestURL = [request URL];
    
    NSString* urlString = [requestURL absoluteString];
    
    BOOL isWebLoginURL = [urlString rangeOfString:@"#access_token"].length;
    
    if (isWebLoginURL)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[AIFoursquareAdapter sharedInstance] handleURL: requestURL];
        });
        
        return NO;
    }
    
    if ([urlString rangeOfString: @"error"].length == 0 && [urlString rangeOfString: @"access_token"].length == 0)
    {
        return YES;
    }
    
    NSError* error;
    
    if ([urlString rangeOfString: @"error="].length != 0)
    {
        NSArray* array = [urlString componentsSeparatedByString: @"="];
        NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: array[1]};
        
        error = [NSError errorWithDomain: @"Foursquare"
                                    code: -1
                                userInfo: userInfo];
    }
    
    NSLog(@"Foursquare error: %@", [error localizedDescription]);
    
    return YES;
}

#pragma mark - Remove Cookies

- (void) removeCookiesPreviousAutorization
{
    NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        if ([[cookie domain] rangeOfString: @"foursquare.com"].length)
        {
            [storage deleteCookie: cookie];
        }
    }
}

@end
