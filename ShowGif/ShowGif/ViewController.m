//
//  ViewController.m
//  ShowGif
//
//  Created by 郭朝顺 on 2021/1/14.
//

#import "ViewController.h"
#import "FLAnimatedImage.h"
#import <WebKit/WebKit.h>
#import "YYImage.h"
#import "UIImage+GIF.h"
#import "UIImageView+WebCache.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

// 线上测试GIF下载地址 http://res.hongrenshuo.com.cn/66532a15-c726-4edf-bb4f-0b8897753f31.gif?t=1606124887942

    // 换成小图之后确实加载很快,而且不占用内存,但是不现实,很模糊
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif_small" ofType:@"gif"];

    // 测试设备,iPhone 6s,iOS12.1,模拟器测试不准,YYImage在模拟器上0%,但是在真机上是30%左右

    // FLAnimatedImageView展示,CADisplayLink展示帧图,CPU30%,内存17M
    [self testGifImage];
    // UIWebView展示,凑数的,不能上架了,CPU在9%, 30%两个值进行锯齿状波动, 内存占用较大40M
//    [self testGifImage2];
    // WKWebView, CPU占用极地1%-2%, 内存占用极地,15M,但是比较复杂,引入了一个HTML文件,而且H5改图片填充模式费事
//    [self testGifImage3];
    // YYImage完美解决方案, CPU占用极地0%, 内存占用极低,13.4M
//    [self testGifImage4];
    // SDImage加载,cpu占用很低0%,内存占用较大72M
//    [self testGifImage5];

    // 系统[UIImage animatedImageWithImages:]加载
//    [self testGifImage6];

}

#pragma mark FLAnimatedImage加载image
- (void)testGifImage {

    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path];

    // cpu 30%左右, 内存17M
    FLAnimatedImage * image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.animatedImage = image;
    [self.view addSubview:imageView];
    //    设置FLAnimatedImageView中的CADisplayLink效果不明显
    //        self.displayLink.preferredFramesPerSecond = 1;
    // 设置小于5帧的情况下CPU下降明显,但是卡顿也明显
    //        self.displayLink.preferredFramesPerSecond = 15; // 60,30,20,15帧CPU下降不明显,
    NSLog(@"FLAnimatedImageView加载image");

}

#pragma mark UIWebView加载image
- (void)testGifImage2 {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path];

    // 使用UIWebView播放, CPU在9%, 30%两个值进行锯齿状波动, 内存占用较大40M,UIWebView已无法提交审核了
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.userInteractionEnabled = NO;//用户不可交互
    [webView loadData:data MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:webView];
    NSLog(@"UIWebView加载image");

}

#pragma mark WKWebView加载image
- (void)testGifImage3 {

    // 系统解决方案, CPU占用极地1%-2%, 内存占用极地,15M
    CGFloat heightView = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat bottomHeightView = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeightView = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    }
    // webView顶部会莫名多出来一个一个状态栏的高度
    WKWebView * wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, -heightView, kScreenWidth, kScreenHeight+heightView+bottomHeightView)];

    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"loadGif" ofType:@"html"];
    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    wkWebView.UIDelegate = self;
    wkWebView.navigationDelegate = self;
    // 禁止上下滚动
    wkWebView.scrollView.scrollEnabled = NO;
    // 禁止双指放大缩小
    wkWebView.scrollView.userInteractionEnabled = NO;
    wkWebView.scrollView.bouncesZoom = YES;
    [wkWebView loadHTMLString:htmlStr baseURL:nil];
    [self.view addSubview:wkWebView];
    NSLog(@"wkWebView加载image");

}




#pragma mark YYImage加载
- (void)testGifImage4 {

    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:self.view.frame];

    // 网络图
    NSURL *url = [NSURL URLWithString:@"http://res.hongrenshuo.com.cn/66532a15-c726-4edf-bb4f-0b8897753f31.gif?t=1606124887942"];
    [imageView sd_setImageWithURL:url];

    // 本地图
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
//    NSData * data = [NSData dataWithContentsOfFile:path];
//    imageView.image = [YYImage imageWithData:data];

    // 本地图名字
//    imageView.image = [YYImage imageNamed:@"直播间测试gif.gif"];
    [self.view addSubview:imageView];
    NSLog(@"YYImage加载");

}

#pragma mark SD加载image
- (void)testGifImage5 {

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];

    // 网络图
    NSURL *url = [NSURL URLWithString:@"http://res.hongrenshuo.com.cn/66532a15-c726-4edf-bb4f-0b8897753f31.gif?t=1606124887942"];
    [imageView sd_setImageWithURL:url];

    [UIImage animatedImageNamed:@"" duration:1];

    // 本地图
        NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
        NSData * data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage sd_imageWithGIFData:data];
//    imageView.image = image;
    [self.view addSubview:imageView];
    NSLog(@"SD加载image");

}

#pragma mark UIImage加载image
- (void)testGifImage6 {

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:imageView];

    // 只能处理单个图片,而且单图1.2M,整个下载下来需要1.2*50=60M, 而生成的gif才2.1M
    // 所以这种写法也就看看就行了
    // CPU:0%, 内存:60M
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i<=50; i++) {
        NSString *imageName = [NSString stringWithFormat:@"直播间测试gif-%@.tiff",@(i)];
        UIImage *image = [UIImage imageNamed:imageName];
        [array addObject:image];
    }
    // 方式1
//    imageView.animationImages = array;
//    imageView.animationDuration = 3;
//    [imageView startAnimating];

    // 方式2
    imageView.image = [UIImage animatedImageWithImages:array duration:3];
    NSLog(@"UIImage animatedImageWithImages动画加载");

}

@end
