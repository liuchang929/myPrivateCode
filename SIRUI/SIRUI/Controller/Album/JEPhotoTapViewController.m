//
//  JEPhotoTapViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/6/12.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEPhotoTapViewController.h"
#import "MotionOrientation.h"

@interface JEPhotoTapViewController () <UIScrollViewDelegate>

@end

@implementation JEPhotoTapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self screen:nil];
    
    //屏幕旋转的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screen:) name:@"MotionOrientationChangedNotification" object:nil];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    _scrollView.backgroundColor = [UIColor redColor];
    _scrollView.center = self.view.center;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 5.0;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    _scrollView.delegate = self;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _imageView.backgroundColor = [UIColor blueColor];
    _imageView.image = self.image;
    _imageView.center = self.scrollView.center;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [singleTap setNumberOfTapsRequired:1];
    [self.imageView addGestureRecognizer:singleTap];

    [self.scrollView addSubview:self.imageView];
    
    [self.view addSubview:_scrollView];
    
    
}

- (void)singleTap {
    NSLog(@"单击");
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    NSLog(@"缩放");
    return _imageView;
}

- (void)screen:(NSNotification *)notify {
    
    UIInterfaceOrientation orientation = [MotionOrientation sharedInstance].interfaceOrientation;
    
    CGFloat rotate = 0;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait: {
            //竖屏
            rotate = 0;
        }
            break;
            
        case UIInterfaceOrientationLandscapeLeft: {
            //向左横屏
            rotate = M_PI_2;
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight: {
            //向右横屏
            rotate = - M_PI_2;
        }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown: {
            //倒的竖屏
            rotate = 0;
        }
            break;
            
        default:
            break;
    }
    
    POPBasicAnimation *ani = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    ani.toValue = [NSNumber numberWithFloat:rotate];
    ani.duration = 0.5;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        for (UIView *subView in self.view.subviews) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                [subView.layer pop_addAnimation:ani forKey:@"rotation"];
            }
        }
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (rotate == 0) {
            _scrollView.frame = self.view.bounds;
            _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
            _imageView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else {
            _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
            _imageView.frame = CGRectMake(0, -20, _scrollView.frame.size.height, _scrollView.frame.size.width);
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    });
}

@end
