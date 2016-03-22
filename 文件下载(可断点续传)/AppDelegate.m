//
//  AppDelegate.m
//  文件下载(可断点续传)
//
//  Created by yyMae on 16/1/21.
//  Copyright (c) 2016年 yyMae. All rights reserved.
//  两种下载方法:NSURLConnection和NSURLSession

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ViewController *VC = [[ViewController alloc]init];
    UINavigationController *NVC = [[UINavigationController alloc]initWithRootViewController:VC];
    self.window.rootViewController = NVC;
    return YES;
}



@end
