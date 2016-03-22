//
//  YYSessionVC.m
//  文件下载(可断点续传)
//
//  Created by yyMae on 16/1/21.
//  Copyright (c) 2016年 yyMae. All rights reserved.
//

#import "YYSessionVC.h"

@interface YYSessionVC ()<NSURLSessionDownloadDelegate>
//显示下载进度
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressL;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;//下载任务
@property (nonatomic, strong) NSData *resumeData;//记录下载位置
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) UIButton *button;
@end

@implementation YYSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"NSURLSession";
    [self addView];
    //NSLog(@"%@",NSHomeDirectory());
}


- (void)addView{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 200, 20);
    button.center = CGPointMake(self.view.frame.size.width * 0.5, 250);
    [button setTitle:@"download" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(download1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.button = button;
    UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    progressView.center = CGPointMake(self.view.frame.size.width * 0.5, 150);
    [self.view addSubview:progressView];
    self.progressView = progressView;
    UILabel *progressL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    progressL.center = CGPointMake(progressView.center.x, 190);
    progressL.text = @"下载进度:0.000000";
    [self.view addSubview:progressL];
    self.progressL = progressL;
}

/**
 *  session懒加载
 *
 *  @return session
 */
-(NSURLSession *)session{
    if (_session == nil) {
        //??????
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

//从0开始下载
- (void)start{
    
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    //创建下载任务
    self.downloadTask = [self.session downloadTaskWithURL:url];
    //开始任务
    [self.downloadTask resume];
}

//继续下载
- (void)resume{
    //传入上次暂停返回的数据
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    //开始任务
    [self.downloadTask resume];
    
    self.resumeData = nil;
}

//暂停下载
- (void)pause{
    __weak typeof(self) selfVC = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        selfVC.resumeData = resumeData;
        selfVC.downloadTask = nil;
    }];
}
- (void)download1:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    if (nil == self.downloadTask) {
        if (self.resumeData) {//继续下载
            [self.button setTitle:@"暂停" forState:UIControlStateNormal];
            [self resume];
        }else{//开始下载
            [self.button setTitle:@"暂停" forState:UIControlStateNormal];
            [self start];
        }
    }else{//暂停下载
        [self.button setTitle:@"继续" forState:UIControlStateNormal];
        [self pause];
    }
}

#pragma mark -- NSURLSessionDownloadDelegate
/**
 *  下载完成调用
 *
 *  @param session
 *  @param downloadTask
 *  @param location     文件临时地址
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //获取文件路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    //剪切文件到路径
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm moveItemAtPath:location.path toPath:filePath error:nil];
    //提示下载完成
    [[[UIAlertView alloc]initWithTitle:@"下载完成" message:downloadTask.response.suggestedFilename delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
}

/**
 *  每次写入沙盒完毕调用
 *
 *  @param session
 *  @param downloadTask
 *  @param bytesWritten              本次写入大小
 *  @param totalBytesWritten         已经写入大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //下载进度
    self.progressView.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
    NSString *str = [NSString stringWithFormat:@"下载进度:%f",(double)totalBytesWritten / totalBytesExpectedToWrite];
    self.progressL.text = str;
}


/**
 *  恢复下载时调用
 *
 *  @param session
 *  @param downloadTask
 *  @param fileOffset
 *  @param expectedTotalBytes
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


    

@end
