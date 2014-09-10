//
//  KIngstagram.m
//  KIngstagram
//
//  Created by Kemal Kocabiyik on 8/18/14.
//  Copyright (c) 2014 Ovidos Creative. All rights reserved.
//

#import "KIngstagram.h"

@implementation KIngstagram

static NSString *accessToken;

static NSString *_baseApiUrl = @"https://api.instagram.com/v1";
static NSString *_clientId;
static NSString *_redirectUri;

static UIViewController *_loginViewController;

static void (^loginCompletionBlock)(NSURLRequest *url, id JSON);
static void (^loginFailureBlock)(NSURLRequest *url, NSError *error);

NSString * const kInstagramAccessToken = @"accessToken";

+ (KIngstagram *)sharedClient {
    
    static KIngstagram *_sharedClient;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[KIngstagram alloc] init];
        
    });
    
    return _sharedClient;
}


+(BOOL) userSessionValid{
    
    
    if(accessToken != nil && ![accessToken isEqualToString:@""] ){
        
        return YES;
    };
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *str =
    [userDefaults valueForKey:kInstagramAccessToken];
    
    if(str != nil && ![str isEqualToString:@""]){
        
        accessToken = str;
        return YES;
    }
    
    
    return NO;
    
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



+(void) requestWithPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:kInstagramAccessToken];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?access_token=%@&%@" ,_baseApiUrl ,path ,accessToken , [KIngstagram dictionaryToQueryString:parameters]]]];
    
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


+(void) requestWithPath:(NSString *) path completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    [self requestWithPath:path parameters:nil completionHandler:block failureHandler:failureHandler];
    
}




+(void) postToPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
    failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:kInstagramAccessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?access_token=%@",_baseApiUrl, path, accessToken]]];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *data = [[self dictionaryToQueryString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
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



#pragma mark - Helpers

+(NSString *) dictionaryToQueryString:(NSDictionary *)dict{
    
    if(dict == nil){
        return @"";
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString *key in dict.allKeys) {
        NSString *value = [[dict valueForKey: key] isKindOfClass:[NSString class]] ? [dict valueForKey:key] : [[dict valueForKey:key] stringValue] ;
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
        
        NSRange acToken = [urlString rangeOfString: @"#access_token="];
        if (acToken.location != NSNotFound) {
            
            
            accessToken = [urlString substringFromIndex: NSMaxRange(acToken)];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults setValue:accessToken forKey:kInstagramAccessToken];
            
            [_loginViewController dismissViewControllerAnimated:NO completion:^{
                loginCompletionBlock(request, accessToken);
                loginCompletionBlock = nil;
                loginFailureBlock = nil;
                _loginViewController = nil;
            }];
            
            
            
        }
        
        return NO;
    }
    
    return YES;
}






@end
