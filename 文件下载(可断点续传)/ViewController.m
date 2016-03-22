//
//  ViewController.m
//  文件下载(可断点续传)
//
//  Created by yyMae on 16/1/21.
//  Copyright (c) 2016年 yyMae. All rights reserved.
//

#import "ViewController.h"
#import "YYSessionVC.h"
#import "YYConnectionVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"下载方式";
    NSLog(@"沙盒路径=====%@",NSHomeDirectory());
    //下载图片展示到控件上
    [self imageDownload1];
    [self imageDownload2];
}

//dataWithContentsOfURL下载
- (void)imageDownload1{
    //添加要显示的控件
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    imgView.center = CGPointMake(self.view.frame.size.width * 0.5, 180);
    imgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:imgView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"NSURLConnection下载" forState:UIControlStateNormal];
    button.frame = CGRectMake(imgView.frame.origin.x, CGRectGetMaxY(imgView.frame) +10, imgView.frame.size.width, 20);
    [button addTarget:self action:@selector(connectionAction1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    //下载图片,显示到控件上
    NSURL *url = [NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/1122063-518845ccdb05b187.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            imgView.image = [UIImage imageWithData:data];
        });
    });
}

//控制器跳转
- (void)connectionAction1{
    YYConnectionVC *CVC = [[YYConnectionVC alloc]init];
    [self.navigationController pushViewController:CVC animated:YES];
}

//NSURLConnection下载
- (void)imageDownload2{
    //添加要显示的控件
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    imgView.center = CGPointMake(self.view.frame.size.width * 0.5, 420);
    imgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:imgView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"NSURLSession下载" forState:UIControlStateNormal];
    button.frame = CGRectMake(imgView.frame.origin.x, CGRectGetMaxY(imgView.frame) + 10, imgView.frame.size.width, 20);
    [button addTarget:self action:@selector(connectionAction2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    //下载图片,显示到控件上
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://upload-images.jianshu.io/upload_images/1122063-2a27429745a8dbdc.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        imgView.image = [UIImage imageWithData:data];
    }];
}

//控制器跳转
- (void)connectionAction2{
    YYSessionVC *SVC = [[YYSessionVC alloc]init];
    [self.navigationController pushViewController:SVC animated:YES];
}



@end
