//
//  ViewController.m
//  Kingstagram
//
//  Created by Kemal Kocabiyik on 8/18/14.
//  Copyright (c) 2014 Ovidos Creative. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)loginClicked:(id)sender{
    
    
    [KIngstagram loginWithClientId:@"fa2ec5fef30f419dbc747f9f94e35910" redirectUri:@"http://ovidos.com/redirect" scope: @[@"relationships"]
                 completionHandler:^(NSURLRequest *url, id JSON) {
                     
                     [KIngstagram requestWithPath:@"users/self/feed" completionHandler:^(NSURLRequest *url, id JSON) {
                         
                         NSLog(@"%@" , JSON);
                         
                     } failureHandler:^(NSURLRequest *url, NSError *error) {
                         
                     }];
                     
                     
                 } failureHandler:^(NSURLRequest *url, NSError *error) {
                     
                 }];
    
    
}
@end
