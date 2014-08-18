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
    
    
    [KIngstagram loginWithClientId:@"client_id" redirectUri:@"http://ovidos.com/redirect" scope: @[@"relationships"]
                 completionHandler:^(NSURLRequest *url, id JSON) {
                     
                     [KIngstagram requestWithPath:@"media/search" parameters:@{ @"lat" : @"41.057266"  , @"lng" : @"29.010238" } completionHandler:^(NSURLRequest *url, id JSON) {
                         
                         NSLog(@"%@" , JSON);
                         
                     } failureHandler:^(NSURLRequest *url, NSError *error) {
                         
                     }];
                     
                     
                 } failureHandler:^(NSURLRequest *url, NSError *error) {
                     
                 }];
    
    
}
@end
