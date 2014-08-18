KIngstagram
===========

KIngstagram is an Instagram API wrapper for iOS. This is a lightweight Instagram API wrapper and it has 3 simple methods to make an api call to Instagram. 

#Installation

You only need to drag&drop  **KIngstagram.h** and **Kingstagram.m** file into your project folder. Kingstagram has no dependency on any other frameworks. 

#Instructions

##Logging In

The very first thing user should login to Instagram API via KIngstagram. What you need to have is to set and take `clientId` and `redirectUri` from http://instagram.com/developer/clients/manage . Once you register your client to Instagram, you may call authentication from Instagram.


```
[KIngstagram loginWithClientId:@"your_client_id" redirectUri:@"your_redirect_uri" scope: @[@"your" , @"permissions" , @"here"]
completionHandler:^(NSURLRequest *url, id response) {


} failureHandler:^(NSURLRequest *url, NSError *error) {

}];

```

After calling the method above, KIngstagram will present a new view controller prompting user to login to Instagram. When user enters his/her credentials correctly, login method enters to completion handler and returns access token as a response. 


##Making API Calls

There are 2 methods basically to make API Calls. The methods below are static methods for KIngstagram.

The method below will make GET queries to Instagram with specified parameters. For instance, if you want to make a user search you may use this method like below.

```
[KIngstagram requestWithPath:@"users/search" parameters:@{@"q" : @"kkocabiyik"} completionHandler:^(NSURLRequest *url, id JSON) {

} failureHandler:^(NSURLRequest *url, NSError *error) {

}];

```

Another method is posting to Instagram. For instance you may want to follow/unfollow/block/approve your friends. Keep in mind that, generally for posting methods you need to have scope permissions to make api calls.

```

[KIngstagram postToPath:@"users/1/relationship" parameters:@{@"action" : @"follow"} completionHandler:^(NSURLRequest *url, id JSON) {

} failureHandler:^(NSURLRequest *url, NSError *error) {

}];

```

#Known Issues

1. Assuming that the access token is valid forever. This might change in the future. 


