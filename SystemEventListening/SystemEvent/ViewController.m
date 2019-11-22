//
//  ViewController.m
//  SystemEvent
//
//  Created by yanyw on 2019/11/12.
//  Copyright © 2019 闫跃文. All rights reserved.
//

#import "ViewController.h"
#import "SystemEvent-Swift.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface ViewController () <MFMessageComposeViewControllerDelegate>

/** 呼叫中心*/
@property (nonatomic, strong) CTCallCenter *callCenter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    [self monitorTelephoneCall];
 
    [self monitorScreenRecord];
}

#pragma mark - 监听电话相关

- (void)monitorTelephoneCall {

    // MsgAppStarting
    // MsgAppReactivate
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall * call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {// Call has been disconnected
            NSLog(@"电话 --- 断开连接");
        }
        else if ([call.callState isEqualToString:CTCallStateConnected]) {// Call has just been connected
            NSLog(@"电话 --- 接通");
            // 通知 H5 当前截屏操作
            dispatch_async(dispatch_get_main_queue(), ^{
                // do somethings
            });
        }
        else if ([call.callState isEqualToString:CTCallStateIncoming]) {// Call is incoming
            NSLog(@"电话 --- 待接通");
        }
        else if ([call.callState isEqualToString:CTCallStateDialing]) {// Call is Dialing
            NSLog(@"电话 --- 拨号中");

            dispatch_async(dispatch_get_main_queue(), ^{
                // do somethings
            });
        }
        else {// Nothing is done"
            NSLog(@"电话 --- 无操作");
        }
    };
}

#pragma mark - 截屏监听

- (void)monitorScreenShotS {
    
    // 截屏监听
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSLog(@"监听到截屏，正在处理");
    }];
}

// 获取相册最新照片
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[PhotoLibraryTool shareTool] screenShotRecentlyAddedWithResultHandler:^(UIImage * _Nullable image) {
       
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 300)];
        
        imageView.backgroundColor = [UIColor orangeColor];
        
        imageView.image = image;
        
        [self.view addSubview:imageView];
    }];
}

/**
 截屏响应
 */
- (void)userDidTakeScreenshot {
    
    NSLog(@"检测到截屏");
    
    //人为操作,获取截屏图片数据
    
    NSData * imageData = [self dataWithScreenshotInPNGFormat];
    UIImage * image = [UIImage imageWithData:imageData];
    
    // 此处 image 资源可根据实际需求进行操作,展示当前截屏图片或者替换成一张固定的图片方式等等等!
    UIImageView * imageScreenshot = [[UIImageView alloc] initWithImage:image];
    
    imageScreenshot.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2, UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2);
    [self.view addSubview:imageScreenshot];     // 展示在当前 View 层级
}

/**
 获取当前屏幕
 @return 获取当前屏幕
 */
- (NSData *)dataWithScreenshotInPNGFormat {
    // Source (Under MIT License):
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (@available(iOS 13.0, *)) {
        UIWindowScene * windowScene = UIApplication.sharedApplication.windows.firstObject.windowScene;
        orientation = windowScene.interfaceOrientation;
    }
    else {
        orientation = UIApplication.sharedApplication.statusBarOrientation;
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = UIScreen.mainScreen.bounds.size;
    }
    else {
        imageSize = CGSizeMake(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [UIApplication.sharedApplication windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        // Correct for the screen orientation
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        }
        else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else {
            [window.layer renderInContext:context];
        }
        
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}
 
#pragma mark - 监听录屏

- (void)monitorScreenRecord {
    
    // 录屏事件监听
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenCapturedDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
             
            NSLog(@"屏幕录制 ...");
        }];
    } else {
        // Fallback on earlier versions
    }
}


@end
