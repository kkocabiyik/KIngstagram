//
//  KIngstagram.m
//  InstaType
//
//  Created by Kemal Kocabiyik on 8/18/14.
//  Copyright (c) 2014 Ovidos Creative. All rights reserved.
//

#import "KIngstagram.h"

@implementation KIngstagram


static NSString *_clientId;
static NSString *_redirectUri;
static UIViewController *_loginViewController;

static void (^loginCompletionBlock)(NSURLRequest *url, id JSON);
static void (^loginFailureBlock)(NSURLRequest *url, NSError *error);


+ (KIngstagram *)sharedClient {
    
    static KIngstagram *_sharedClient;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[KIngstagram alloc] init];
        
    });
    
    return _sharedClient;
}


+(void) loginWithClientId:(NSString *) clientId redirectUri:(NSString *) redirectUri
                    scope:(NSArray *) scope
        completionHandler:(void(^)(NSURLRequest *url, id JSON))block
           failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    
    _clientId = clientId;
    _redirectUri = redirectUri;
    loginCompletionBlock = block;
    loginFailureBlock = failureHandler;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    
    _loginViewController = [[UIViewController alloc] init];
    
    
    _loginViewController.view = [[UIView alloc] initWithFrame:window.bounds];
    
    _loginViewController.view.backgroundColor = [UIColor redColor];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:_loginViewController.view.bounds];
    
    webView.delegate = [self sharedClient];
    
    [_loginViewController.view addSubview:webView];
    
    
    NSString *url;
    if(scope != nil && scope.count > 0){
        url = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=%@"
               , _clientId , _redirectUri , [scope componentsJoinedByString:@"+"]];
        
    }else{
        url = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token"
               , _clientId , _redirectUri];
        
    }
    
    NSURLRequest *urlRequest= [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [webView loadRequest:urlRequest];
    
    [window.rootViewController presentViewController:_loginViewController animated:YES completion:nil];
    
    
}


+(void) loginWithClientId:(NSString *) clientId redirectUri:(NSString *) redirectUri
        completionHandler:(void(^)(NSURLRequest *url, id JSON))block
           failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    [self loginWithClientId:clientId redirectUri:redirectUri scope:nil completionHandler:block failureHandler:failureHandler];
    
}


+(void) requestWithPath:(NSString *) path completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    [self requestWithPath:path parameters:nil completionHandler:block failureHandler:failureHandler];
    
}


+(void) requestWithPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/%@?access_token=%@&%@" , path, accessToken , [KIngstagram dictionaryToQueryString:parameters]]]];
    
    NSLog(@"Request:%@" , request.URL.absoluteString);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError == nil){
            
            id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            block(request ,JSON);
            
        }else{
            failureHandler(request, connectionError);
        }
        
    }];
    
}


+(void) postToPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
    failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/%@?access_token=%@" , path, accessToken]]];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *data = [[self dictionaryToQueryString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError == nil){
            
            id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            block(request ,JSON);
            
        }else{
            failureHandler(request, connectionError);
        }
        
    }];
    
}



#pragma mark - Helpers

+(NSString *) dictionaryToQueryString:(NSDictionary *)dict{
    
    if(dict == nil){
        return @"";
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString *key in dict.allKeys) {
        NSString *value = [dict valueForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@",[KIngstagram encodedString:key] , [KIngstagram encodedString:value]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
    
}

+(NSString *)encodedString:(NSString *) str {
    
    return [str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


#pragma mark - UIWebViewDelegate


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *urlString =request.URL.absoluteString;
    
    if([urlString rangeOfString:_redirectUri].location != NSNotFound && [urlString rangeOfString:@"https://instagram.com/oauth/authorize/"].location == NSNotFound){
        
        NSRange accessToken = [urlString rangeOfString: @"#access_token="];
        if (accessToken.location != NSNotFound) {
            
            
            NSString *accessTokenValue = [urlString substringFromIndex: NSMaxRange(accessToken)];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults setValue:accessTokenValue forKey:@"accessToken"];
            
            [_loginViewController dismissViewControllerAnimated:NO completion:nil];
            
            loginCompletionBlock(request, accessTokenValue);
            loginCompletionBlock = nil;
            loginFailureBlock = nil;
            _loginViewController = nil;
            
            
        }
        
        
        
        return NO;
    }
    
    return YES;
}






@end
