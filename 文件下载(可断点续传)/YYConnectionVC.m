//
//  YYConnectionVC.m
//  文件下载(可断点续传)
//
//  Created by yyMae on 16/1/21.
//  Copyright (c) 2016年 yyMae. All rights reserved.
//

#import "YYConnectionVC.h"

@interface YYConnectionVC ()<NSURLConnectionDataDelegate>

/**
 *  用来写数据的文件句柄对象
 */
@property (nonatomic, strong) NSFileHandle *writeHandle;

/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;
/**
 *  当前已经写入的总大小
 */
@property (nonatomic, assign) long long  currentLength;
/**
 *  连接对象
 */
@property (nonatomic, strong) NSURLConnection *connection;

//显示下载进度
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressL;
@property (nonatomic, strong) UIButton *button;
@end

@implementation YYConnectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"NSURLConnection";
    [self addView];
}

- (void)addView{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 200, 20);
    button.center = CGPointMake(self.view.frame.size.width * 0.5, 250);
    [button setTitle:@"download" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)download:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    //断点下载(中心思想是请求头里面包含下载进度)
    if (sender.selected) {//开始下载或者继续下载
        [self.button setTitle:@"暂停" forState:UIControlStateNormal];
        //1.url
        //NSURL *url = [NSURL URLWithString:@"https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=1650&sharp=30"];
        NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
        //2.请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //设置请求投
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        //3.下载
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
    }else{//暂停下载
        [self.button setTitle:@"继续" forState:UIControlStateNormal];
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark - NSURLConnectionDataDelegate代理方法

/**
 *  请求失败时候调用(请求超时,网络异常等)
 *
 *  @param connection 连接对象
 *  @param error      错误信息
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}

/**
 *  接收到服务器响应时调用
 *
 *  @param connection 连接对象
 *  @param response   响应
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //如果文件已经存在,不执行
    if (self.currentLength) {
        return;
    }
    //文件路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:response.suggestedFilename];
    //创建一个空文件到沙盒
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filePath contents:nil attributes:nil];
    //创建一个用来写数据的文件句柄对象
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //获得文件的总大小
    self.totalLength = response.expectedContentLength;
    
}

/**
 *  接收到服务器返回的实体数据时调用(可能会调用多次)
 *
 *  @param connection 连接对象
 *  @param data       这次返回的数据
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //移动文件到最后面
    [self.writeHandle seekToEndOfFile];
    //将文件写入沙盒
    [self.writeHandle writeData:data];
    //累计写入文件的长度
    self.currentLength = self.currentLength + data.length;
    //获取下载进度
    self.progressView.progress = (double)self.currentLength / self.totalLength;
    NSString *str = [NSString stringWithFormat:@"下载进度:%f",(double)self.currentLength / self.totalLength];
    self.progressL.text = str;
}

/**
 *  加载完成时调用(服务器数据已经完全返回)
 *
 *  @param connection 连接对象
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[[UIAlertView alloc]initWithTitle:@"提示" message:@"下载完成" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
    self.currentLength = 0;
    self.totalLength = 0;
    [self.writeHandle closeFile];
    self.writeHandle = nil;
}

@end
