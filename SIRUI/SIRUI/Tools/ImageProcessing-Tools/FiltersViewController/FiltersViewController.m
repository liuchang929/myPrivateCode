//
//  FiltersViewController.m
//  PhotpShow
//
//  Created by FLYang on 16/2/26.
//  Copyright © 2016年 Fynn. All rights reserved.
//
#import "FiltersViewController.h"
#import "FBFilters.h"
#import "JECameraManager.h"
#import <Photos/Photos.h>

@interface FiltersViewController () <FBFootViewDelegate>
{
    /*
     *  线程
     */
    dispatch_queue_t saveImageQueue;        //保存照片的线程
    
}

@end

@implementation FiltersViewController

- (void)viewWillAppear:(BOOL)animated{
    
     [super viewWillAppear:animated];
    
     [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    
     [super viewWillDisappear:animated];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int heightSpace = 20;
    if (ITS_X_SERIES) {
        heightSpace = 40;
    }
    
    self.nextBtn.frame = CGRectMake(kScreenWidth - 60, 0, 50, 50);
    self.navTitle.frame = CGRectMake(50, 0, (kScreenWidth - 100), 50);
    self.footView.frame = CGRectMake(0, kScreenHeight - 1, kScreenWidth, 1);
    self.filtersImageView.frame = CGRectMake(0, 50 + heightSpace, kScreenWidth, kScreenHeight-50-130);
    self.filtersView.frame = CGRectMake(0, kScreenHeight - 130, kScreenWidth, 130);
    self.filtersView.filtersCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 130);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setFiltersControllerUI];
    
    //线程的初始化
    saveImageQueue = dispatch_queue_create("com.sirui.saveImageSerial", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFilter:) name:@"fitlerName" object:nil];
    NSLog(@"滤镜页初始化完毕");
    
    //隐藏状态栏
//    [self preferredStatusBarStyle];
}

- (void)changeFilter:(NSNotification *)filterName {

    UIImage * showFilterImage = [[FBFilters alloc] initWithImage:self.filtersImg filterName:[filterName object]].filterImg;
    
    self.filtersImageView.image = showFilterImage;
}
#pragma mark - 设置顶部导航栏
- (void)setNavViewUI {
    [self addNavViewTitle:JELocalizedString(@"Image filters",nil)];
    [self addBackButton];
    [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addNextButton];
    [self.nextBtn setTitle:JELocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
}
#pragma mark 继续按钮的点击事件
- (void)nextBtnClick {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    UIImage *filterIamge = _filtersImageView.image;
    
    //保存到沙盒中
    //起异步线程
    dispatch_async(saveImageQueue, ^{
        @autoreleasepool {
            NSString *fileName = [JECameraManager shareCAMSingleton].getNowDate;
            BOOL re = [[JECameraManager shareCAMSingleton] saveImage:[UIImage imageWithData:UIImagePNGRepresentation(filterIamge)] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName] withOrientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (re) {
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    });
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 设置视图UI
- (void)setFiltersControllerUI {
    
    [self setNavViewUI];
    
    self.filtersImageView.image = self.filtersImg;
    
    [self.view addSubview:self.filtersImageView];
    
    [self.view addSubview:self.filtersView];

    [self.view addSubview:self.footView];
    
}
#pragma mark - 底部的工具栏
- (FBFootView *)footView {
    if (!_footView) {
        
        _footView = [[FBFootView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 1, kScreenWidth, 1)];
        NSArray * titleArr = [[NSArray alloc] initWithObjects:@"", nil];
        _footView.backgroundColor = [UIColor blackColor];
        _footView.titleArr = titleArr;
        [_footView addFootViewButton];
        _footView.delegate = self;
    }
    return _footView;
}
#pragma mark - 处理图片的视图
- (UIImageView *)filtersImageView {
    
    if (!_filtersImageView) {
        
        _filtersImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, kScreenHeight-50-130)];
        _filtersImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _filtersImageView;
}
#pragma mark - 滤镜视图
- (FiltersView *)filtersView {
    
    if (!_filtersView) {
        
        _filtersView = [[FiltersView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 130, kScreenWidth, 130)];
        
        _filtersView.filters = [NSArray arrayWithObjects:
                        @"CIColorCrossPolynomial",
                        @"CIPhotoEffectInstant",
                        @"CIPhotoEffectNoir",
                        @"CIPhotoEffectTransfer",
                        @"CIPhotoEffectFade",
                        @"CIPhotoEffectProcess",
                        @"CIPhotoEffectChrome",
                        @"CIPhotoEffectMono",
                        @"CIPhotoEffectTonal",
                                nil];
        
        _filtersView.filtersName = @[JELocalizedString(@"Origin",nil),JELocalizedString(@"Vintage",nil),JELocalizedString(@"Black&White",nil),JELocalizedString(@"Times",nil),JELocalizedString(@"Fade",nil),JELocalizedString(@"Developing",nil),JELocalizedString(@"Chrome Yellow",nil),JELocalizedString(@"Mono",nil),JELocalizedString(@"Tone",nil)];
        
        _filtersView.imageFilter = self.filtersImg;
    }
    return _filtersView;
}

//隐藏当前VC的状态栏
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

@end
