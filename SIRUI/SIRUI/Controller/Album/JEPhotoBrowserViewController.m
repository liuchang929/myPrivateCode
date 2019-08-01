//
//  JEPhotoBrowserViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/6.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEPhotoBrowserViewController.h"
#import "JECameraManager.h"
#import "TOCropViewController.h"
#import "FiltersViewController.h"
#import "PHPhotoLibrary+CustomPhotoAlbum.h"
#import "JEPhotoTapViewController.h"
#import "ViewController.h"

@interface JEPhotoBrowserViewController () <UIScrollViewDelegate>
{
    /*
     *  线程
     */
    dispatch_queue_t saveImageQueue;        //保存照片的线程
    
}

@property (nonatomic, strong) IBOutlet UIView   *topView;       //顶部 view
@property (nonatomic, strong) IBOutlet UIView   *bottomView;    //底部 view
@property (nonatomic, strong) IBOutlet UILabel  *titleLabel;    //标题 label
@property (nonatomic, strong) IBOutlet UIButton *backButton;    //返回按钮
@property (nonatomic, strong) IBOutlet UIButton *editButton;    //编辑按钮
@property (nonatomic, strong) IBOutlet UIButton *delectButton;  //删除按钮
@property (nonatomic, strong) IBOutlet UIButton *downButton;    //下载按钮
@property (nonatomic, strong) IBOutlet UIButton *shareButton;   //分享按钮
@property (nonatomic, strong) IBOutlet UIScrollView *photoBrowserScrollView;    //图片浏览器

@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@end

@implementation JEPhotoBrowserViewController

- (AVPlayerViewController *)playerViewController{
    
    if (!_playerViewController) {
        
        _playerViewController = [[AVPlayerViewController alloc]init];
    }
    return _playerViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
}

- (void)setupUI {
    _photoBrowserScrollView.frame = CGRectMake(0, _topView.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height - _topView.frame.size.height - _bottomView.frame.size.height);
    _photoBrowserScrollView.pagingEnabled = YES;
    _photoBrowserScrollView.showsHorizontalScrollIndicator = NO;
    _photoBrowserScrollView.showsVerticalScrollIndicator = NO;
    _photoBrowserScrollView.bounces = YES;
    _photoBrowserScrollView.minimumZoomScale = 1.0;
    _photoBrowserScrollView.maximumZoomScale = 1.0;
    _photoBrowserScrollView.contentSize = CGSizeMake([[_photoBrowserDic objectForKey:@"Array"] count] * _photoBrowserScrollView.frame.size.width, 0);
    _photoBrowserScrollView.delegate = self;
    
    [_photoBrowserScrollView setContentOffset:CGPointMake(_indexPath.row * _photoBrowserScrollView.frame.size.width, 0)];
    
    //标题栏
    NSMutableString *muString = [NSMutableString stringWithFormat:@"%@  %ld/%lu", [_photoBrowserDic objectForKey:@"Date"], _indexPath.row + 1, (unsigned long)[[_photoBrowserDic objectForKey:@"Array"] count]];
    _titleLabel.text = muString;
    
    for (int index = 0; index < [[_photoBrowserDic objectForKey:@"Array"] count]; index++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * _photoBrowserScrollView.frame.size.width, 0, _photoBrowserScrollView.frame.size.width, _photoBrowserScrollView.frame.size.height)];
    
        if (_browerMode == pictureBrowser) {
            imageView.image = [[JECameraManager shareCAMSingleton] getImage:[_photoBrowserDic objectForKey:@"Array"][index] fromAlbumSandboxMode:Original];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
            
            //单击手势
            UITapGestureRecognizer *imageViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            [imageViewSingleTap setNumberOfTapsRequired:1];
            [imageView addGestureRecognizer:imageViewSingleTap];
        }
        else {
            NSMutableString *str = [NSMutableString stringWithString:[_photoBrowserDic objectForKey:@"Array"][index]];
            [str replaceCharactersInRange:NSMakeRange(14, 3) withString:@"png"];
            imageView.image = [[JECameraManager shareCAMSingleton] getVideoPreviewWithName:str];
            
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
    
            //播放按钮
            UIButton *videoPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            videoPlayBtn.center = CGPointMake(imageView.frame.size.width/2, imageView.center.y);
            [videoPlayBtn setImage:[UIImage imageNamed:@"icon_brower_videoPlay"] forState:UIControlStateNormal];
            [videoPlayBtn addTarget:self action:@selector(videoPlayAction) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:videoPlayBtn];
            NSLog(@"%@", videoPlayBtn);
            
        }
    
        [self.photoBrowserScrollView addSubview:imageView];
    }
    
    //返回键
    [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //编辑键
    [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //删除键
    [_delectButton addTarget:self action:@selector(delectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //下载键
    [_downButton addTarget:self action:@selector(downloadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //分享键
    [_shareButton addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //线程的初始化
    saveImageQueue = dispatch_queue_create("com.sirui.saveImageSerial", DISPATCH_QUEUE_SERIAL);
    
}

//返回按钮
- (void)backButtonAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//编辑按钮
- (void)editButtonAction {
    NSLog(@"编辑");
    CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
    int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (_browerMode == pictureBrowser) {
        TOCropViewController *cropVC = [[TOCropViewController alloc] initWithImage:[[JECameraManager shareCAMSingleton] getImage:[_photoBrowserDic objectForKey:@"Array"][currentPage] fromAlbumSandboxMode:Original]];
//        cropVC.delegate = self;
        [self presentViewController:cropVC animated:YES completion:nil];
    }
    else {
        //视频剪辑
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ViewController *vc = [story instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        NSMutableString *str = [NSMutableString stringWithString:[_photoBrowserDic objectForKey:@"Array"][currentPage]];
        [str replaceCharactersInRange:NSMakeRange(14, 3) withString:@"png"];
        vc.firstImage = [[JECameraManager shareCAMSingleton] getVideoPreviewWithName:str];
        vc.videoUrlYFX = [NSURL fileURLWithPath:[[JECameraManager shareCAMSingleton] getVideoPathWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]]];
        vc.saveVideoStyle = Normal;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

//删除按钮
- (void)delectButtonAction {
    
    if (_browerMode == pictureBrowser) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Photo", nil) message:NSLocalizedString(@"Confirm to delete the selected photos?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        //取消
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        //确认
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //同时删除原图和缩略图中的图片
            CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
            int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            
            BOOL delectIsSuccess = [[JECameraManager shareCAMSingleton] deleteImageWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]];
            
            if (delectIsSuccess) {
                SHOW_HUD_DELAY(NSLocalizedString(@"Deleted", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            }
            else {
                SHOW_HUD_DELAY(NSLocalizedString(@"Deleting Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Video", nil) message:NSLocalizedString(@"Confirm to delete the selected videos?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        //取消
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        //确认
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //同时删除原图和缩略图中的图片
            CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
            int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            
            BOOL delectIsSuccess = [[JECameraManager shareCAMSingleton] deleteVideoWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]];
            
            if (delectIsSuccess) {
                SHOW_HUD_DELAY(NSLocalizedString(@"Deleted", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            }
            else {
                SHOW_HUD_DELAY(NSLocalizedString(@"Deleting Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

//下载按钮
- (void)downloadButtonAction {
    if (_browerMode == pictureBrowser) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Photo", nil) message:NSLocalizedString(@"Confirm to save the current photo?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        //取消
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
        }]];
        
        //确认
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"确认");
            
            CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
            int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            
            //保存图片到本地相册中
            UIImage *image = [[JECameraManager shareCAMSingleton] getImage:[_photoBrowserDic objectForKey:@"Array"][currentPage] fromAlbumSandboxMode:Original];
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            __block UIImage *copiedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(saveImageQueue, ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        @autoreleasepool {
                            [[PHPhotoLibrary sharedPhotoLibrary] saveImage:copiedImage ToAlbum:kImageAlbumName completion:^(PHAsset *imageAsset) {
                                NSLog(@"imageAsset = %@", imageAsset);
                                if (imageAsset) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        SHOW_HUD_DELAY(NSLocalizedString(@"Saved", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                    });
                                }
                            } failure:^(NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    SHOW_HUD_DELAY(NSLocalizedString(@"Failed", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                });
                            }];
                        }
                    }
                }];
            });
        }]];
        
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Video", nil) message:NSLocalizedString(@"Confirm to save the current video?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        //取消
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
        }]];
        
        //确认
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"确认");
            
            CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
            int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            
            NSURL *videoURL = [NSURL fileURLWithPath:[[JECameraManager shareCAMSingleton] getVideoPathWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]]];
            NSLog(@"videoURL = %@", videoURL);
            
            dispatch_async(saveImageQueue, ^{
                @try {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        if (status == PHAuthorizationStatusAuthorized) {
                            @autoreleasepool {
                                [[PHPhotoLibrary sharedPhotoLibrary] saveVideoWithUrl:videoURL ToAlbum:kVideoAlbumName completion:^(NSURL *videoUrl) {
                                    if (videoUrl) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SHOW_HUD_DELAY(NSLocalizedString(@"Saved", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                        });
                                    }
                                } failure:^(NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        SHOW_HUD_DELAY(NSLocalizedString(@"Failed", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                    });
                                }];
                            }
                        }
                    }];
                } @catch (NSException *exception) {
                    NSLog(@"catch");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SHOW_HUD_DELAY(NSLocalizedString(@"Saved", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                    });
                } @finally {
                
                }
            });
        }]];
        
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

//分享按钮
- (void)shareButtonAction {
    CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
    int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    NSArray *postItems;
    
    if (_browerMode == pictureBrowser) {
        UIImage *image = [[JECameraManager shareCAMSingleton] getImage:[_photoBrowserDic objectForKey:@"Array"][currentPage] fromAlbumSandboxMode:Original];
        
        postItems = @[image];
    }
    else {
        NSURL *videoUrl = [NSURL fileURLWithPath:[[JECameraManager shareCAMSingleton] getVideoPathWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]]];
        
        postItems = @[videoUrl];
    }
    
    UIActivityViewController *shareC = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    [self presentViewController:shareC animated:YES completion:nil];
}

//图片双击放大手势
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    
    if (_browerMode == pictureBrowser) {
        NSLog(@"放大");
        
        CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
        int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        JEPhotoTapViewController *photoTapVC = [[JEPhotoTapViewController alloc] init];
        photoTapVC.image = [[JECameraManager shareCAMSingleton] getImage:[_photoBrowserDic objectForKey:@"Array"][currentPage] fromAlbumSandboxMode:Original];
        [self presentViewController:photoTapVC animated:YES completion:^{
            
        }];
    }
    else {
        [self videoPlayAction];
    }
}

//播放视频
- (void)videoPlayAction {
    NSLog(@"播放");
    
    CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
    int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    NSURL *videoUrl = [NSURL fileURLWithPath:[[JECameraManager shareCAMSingleton] getVideoPathWithName:[_photoBrowserDic objectForKey:@"Array"][currentPage]]];
    
    [self playVideo:videoUrl];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = _photoBrowserScrollView.frame.size.height / scale;
    NSLog(@"zoomRect.size.height is %f",zoomRect.size.height);
    NSLog(@"self.frame.size.height is %f",_photoBrowserScrollView.frame.size.height);
    zoomRect.size.width = _photoBrowserScrollView.frame.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
    int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    UIImageView *imageView = scrollView.subviews[currentPage];
    return imageView;
}

#pragma mark - UIScrollViewDelegate
// 结束减速时触发（停止）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = _photoBrowserScrollView.frame.size.width;
    
    int currentPage = floor((_photoBrowserScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"当前滑动到了第几页 = %d", currentPage);
    
    //标题栏
    NSMutableString *muString = [NSMutableString stringWithFormat:@"%@  %d/%lu", [_photoBrowserDic objectForKey:@"Date"], currentPage + 1, (unsigned long)[[_photoBrowserDic objectForKey:@"Array"] count]];
    _titleLabel.text = muString;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

//播放
- (void)playVideo:(NSURL *)assURL{
    //test
    AVAsset *asset = [AVAsset assetWithURL:assURL];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    [self enableAudioTracks:YES inPlayerItem:item];
    
    AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:item];
    
    avPlayer.rate = 0.5;
    
    [self.playerViewController supportedInterfaceOrientations];
    
    self.playerViewController.player = avPlayer;
    
    UIDeviceOrientation orientation = [MotionOrientation sharedInstance].deviceOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIDeviceOrientationLandscapeLeft:
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        default:
            break;
    }
    
    [self presentViewController:self.playerViewController animated:YES completion:^{
        
    }];
    
    //开始播放视频
    self.playerViewController.player.rate = 0.5;
    
    [self.playerViewController.player play];
}

//I wrote a function which you can call whenever you want to set the rate for video below 0.5. It enables/disables all audio tracks.
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks)
    {
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
        {
            track.enabled = enable;
        }
    }
}


@end
