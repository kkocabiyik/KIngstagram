//
//  KIngstagram.h
//  KIngstagram
//
//  Created by Kemal Kocabiyik on 8/18/14.
//  Copyright (c) 2014 Ovidos Creative. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface KIngstagram : NSObject <UIWebViewDelegate>



+(void) loginWithClientId:(NSString *) clientId redirectUri:(NSString *) redirectUri
                    scope:(NSArray *) scope
        completionHandler:(void(^)(NSURLRequest *url, id JSON))block
           failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler;


+(void) loginWithClientId:(NSString *) clientId redirectUri:(NSString *) redirectUri completionHandler:(void(^)(NSURLRequest *url, id JSON))block
           failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler;


+(void) requestWithPath:(NSString *) path completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler;

+(void) requestWithPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
         failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler;


+(void) postToPath:(NSString *) path parameters:(NSDictionary *) parameters completionHandler:(void(^)(NSURLRequest *url, id JSON))block
    failureHandler:(void(^)(NSURLRequest *url, NSError *error)) failureHandler;

@end
