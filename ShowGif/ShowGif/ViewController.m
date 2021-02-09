//
//  ViewController.m
//  ShowGif
//
//  Created by 郭朝顺 on 2021/1/14.
//

#import "ViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import <WebKit/WebKit.h>
#import "YYImage.h"
#import "UIImage+GIF.h"


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
//    [self testGifImage];
    // UIWebView展示,凑数的,不能上架了,CPU在9%, 30%两个值进行锯齿状波动, 内存占用较大40M
//    [self testGifImage2];
    // WKWebView, CPU占用极地1%-2%, 内存占用极地,15M,但是比较复杂,引入了一个HTML文件,而且H5改图片填充模式费事
//    [self testGifImage3];
    // YYImage完美解决方案, CPU占用极地0%, 内存占用极低,13.4M
    [self testGifImage4];
    // SDImage加载,cpu占用很低0%,内存占用较大72M
//    [self testGifImage5];


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
    wkWebView.scrollView.scrollEnabled = NO;
    wkWebView.scrollView.bouncesZoom = YES;
    [wkWebView loadHTMLString:htmlStr baseURL:nil];
    [self.view addSubview:wkWebView];

}
// 加载完毕
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}




#pragma mark YYImage加载
- (void)testGifImage4 {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path];

    YYAnimatedImageView *image = [[YYAnimatedImageView alloc] initWithFrame:self.view.frame];
    image.image = [YYImage imageWithData:data];
//    image.image = [YYImage imageNamed:@"直播间测试gif.gif"];
    [self.view addSubview:image];

}

#pragma mark SD加载image
- (void)testGifImage5 {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"直播间测试gif" ofType:@"gif"];
    NSData * data = [NSData dataWithContentsOfFile:path];

    UIImage *image = [UIImage sd_imageWithGIFData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = image;
    [self.view addSubview:imageView];

}

@end
