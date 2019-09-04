//
//  TOCropViewController.h
//
//  Copyright 2015 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropViewController.h"
#import "TOCropView.h"
#import "TOCropToolbar.h"
#import "TOCropViewControllerTransitioning.h"
#import "UIImage+CropRotate.h"
#import "FiltersViewController.h"

typedef enum : NSInteger {
    TOCropViewControllerAspectRatioOriginal = 0,
    TOCropViewControllerAspectRatioSquare,
    TOCropViewControllerAspectRatio3x2,
    TOCropViewControllerAspectRatio4x3,
    TOCropViewControllerAspectRatio16x9,
} TOCropViewControllerAspectRatio;

@interface TOCropViewController () <UIActionSheetDelegate, UIViewControllerTransitioningDelegate, TOCropViewDelegate>

@property (nonatomic, readwrite) UIImage *image;
@property (nonatomic, strong) TOCropToolbar *toolbar;
@property (nonatomic, strong) TOCropView *cropView;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) TOCropViewControllerTransitioning *transitionController;
@property (nonatomic, assign) BOOL inTransition;
@property (nonatomic, assign) BOOL isPresenting;    //判断是否是present出来的页面

@property (nonatomic, assign) TOCropViewControllerAspectRatio aspectRatioStle;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
#pragma clang diagnostic pop

/* Button callback */
- (void)cancelButtonTapped;
- (void)doneButtonTapped;
- (void)showAspectRatioDialog;
- (void)resetCropViewLayout;
- (void)rotateCropView;
/* View layout */
- (CGRect)frameForToolBarWithVerticalLayout:(BOOL)verticalLayout;

@end

@implementation TOCropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;  
}
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    
    if (self) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        _transitionController = [[TOCropViewControllerTransitioning alloc] init];
        
        _image = image;
    
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //屏幕适配
    CGFloat bottomSpace = 0;
    if (self.view.frame.size.height > 811.0f) {
        bottomSpace = 15;
    }
    
//    BOOL landscapeLayout = CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds);

    BOOL landscapeLayout;
    
//    if ([MotionOrientation sharedInstance].interfaceOrientation == UIInterfaceOrientationLandscapeLeft || [MotionOrientation sharedInstance].interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        landscapeLayout = 1;
//    }
//    else {
        landscapeLayout = 0;    //竖屏
//    }
    
    //裁剪内容view
    self.cropView = [[TOCropView alloc] initWithImage:self.image];
    
    if (!landscapeLayout) {
        self.cropView.frame = (CGRect){(landscapeLayout ? 44.0f : 0.0f),0,(CGRectGetWidth(self.view.bounds) - (landscapeLayout ? 44.0f : 0.0f)), (CGRectGetHeight(self.view.bounds) - (landscapeLayout ? 0.0f : 44.0f + bottomSpace)) };
    }
    else {
        self.cropView.frame = (CGRect){0.0f,0,(CGRectGetHeight(self.view.bounds) - (landscapeLayout ? 0.0f : 44.0f + bottomSpace)), (CGRectGetWidth(self.view.bounds) - (landscapeLayout ? 44.0f : 0.0f))};
    }
    self.cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.cropView.delegate = self;
    [self.view addSubview:self.cropView];
    
    CGSize aspectRatio = CGSizeZero;
    self.aspectRatioStle = 0;
    
    [self.cropView setAspectLockEnabledWithAspectRatio:aspectRatio animated:false];
    
    //裁剪工具栏
    self.toolbar = [[TOCropToolbar alloc] initWithFrame:CGRectZero];
    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)];
    [self.view addSubview:self.toolbar];
    
    __weak typeof(self) weakSelf = self;
    self.toolbar.doneButtonTapped =     ^{ [weakSelf doneButtonTapped];};
    self.toolbar.cancelButtonTapped =   ^{ [weakSelf cancelButtonTapped];};
    self.toolbar.resetButtonTapped =    ^{ [weakSelf resetCropViewLayout];};
    self.toolbar.clampButtonTapped =    ^{ [weakSelf showAspectRatioDialog];};
    self.toolbar.rotateButtonTapped =   ^{ [weakSelf rotateCropView];};
    
    self.transitioningDelegate = self;
    
    self.view.backgroundColor = self.cropView.backgroundColor;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        self.inTransition = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.inTransition = NO;
    
    if (animated && [UIApplication sharedApplication].statusBarHidden == NO) {
        [UIView animateWithDuration:0.3f animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
        
        if (self.cropView.gridOverlayHidden)
            [self.cropView setGridOverlayHidden:NO animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.inTransition = YES;
    
    [UIView animateWithDuration:0.5f animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.inTransition = NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return !self.inTransition;
}

- (CGRect)frameForToolBarWithVerticalLayout:(BOOL)verticalLayout
{
    //屏幕适配
    CGFloat bottomSpace = 0;
    if (self.view.frame.size.height > 811.0f) {
        bottomSpace = 15;
    }
    
    CGRect frame = self.toolbar.frame;
    if (verticalLayout ) {
        frame = self.toolbar.frame;
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        frame.size.width = 44.0f;
        frame.size.height = CGRectGetHeight(self.view.frame);
    }
    else {
        frame.origin.x = 0.0f;
        frame.origin.y = CGRectGetHeight(self.view.bounds) - 44.0f - bottomSpace;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        frame.size.height = 44.0f + bottomSpace;
    }
    return frame;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat frameSpace = 0;
    if (self.view.frame.size.height > 811.0f) {
        frameSpace = 40;
    }
    
    BOOL verticalLayout = CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds);
    if (verticalLayout ) {
        CGRect frame = self.cropView.frame;
        frame.origin.x = 44.0f;
        frame.size.width = CGRectGetWidth(self.view.bounds) - 44.0f;
        frame.size.height = CGRectGetHeight(self.view.bounds);
        self.cropView.frame = frame;
    }
    else {
        CGRect frame = self.cropView.frame;
        frame.origin.x = 0.0f;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        frame.size.height = CGRectGetHeight(self.view.bounds) - 44.0f;
        self.cropView.frame = frame;
    }
    
    [UIView setAnimationsEnabled:NO];
    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:verticalLayout];
    [self.toolbar setNeedsLayout];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Rotation Handling -
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.snapshotView = [self.toolbar snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.frame = self.toolbar.frame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        self.snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    else
        self.snapshotView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:self.snapshotView];

    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    [self.toolbar layoutIfNeeded];
    
    self.toolbar.alpha = 0.0f;
    
    self.cropView.simpleMode = YES;
    [self.cropView prepareforRotation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    
    [UIView animateWithDuration:duration animations:^{
        self.snapshotView.alpha = 0.0f;
        self.toolbar.alpha = 1.0f;
    }];
    [self.cropView performRelayoutForRotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.snapshotView removeFromSuperview];
    
    self.snapshotView = nil;
    
    [self.cropView setSimpleMode:NO animated:YES];
}

#pragma mark - Reset -
- (void)resetCropViewLayout
{
    [self.cropView resetLayoutToDefaultAnimated:YES];
    self.cropView.aspectLockEnabled = NO;
    self.toolbar.clampButtonGlowing = NO;
}

#pragma mark - Aspect Ratio Handling -
- (void)showAspectRatioDialog
{
    if (self.cropView.aspectLockEnabled) {
        self.cropView.aspectLockEnabled = NO;
        self.toolbar.clampButtonGlowing = NO;
        return;
    }
    //TODO: Completely overhaul this once iOS 7 support is dropped
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BOOL verticalCropBox = self.cropView.cropBoxAspectRatioIsPortrait;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
    destructiveButtonTitle:nil
    otherButtonTitles:NSLocalizedString(@"Original", nil),
                      NSLocalizedString(@"Square", nil),
                      verticalCropBox ? @"2:3" : @"3:2",
                      verticalCropBox ? @"3:4" : @"4:3",
                      verticalCropBox ? @"9:16" : @"16:9",nil];
    
    [actionSheet showInView:self.view];
#pragma clang diagnostic pop
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CGSize aspectRatio = CGSizeZero;
    
    switch (buttonIndex) {
        case TOCropViewControllerAspectRatioOriginal:
            aspectRatio = CGSizeZero;
            break;
        case TOCropViewControllerAspectRatioSquare:
            aspectRatio = CGSizeMake(1.0f, 1.0f);
            break;
        case TOCropViewControllerAspectRatio3x2:
            aspectRatio = CGSizeMake(3.0f, 2.0f);
            break;
        case TOCropViewControllerAspectRatio4x3:
            aspectRatio = CGSizeMake(4.0f, 3.0f);
            break;
        case TOCropViewControllerAspectRatio16x9:
            aspectRatio = CGSizeMake(16.0f, 9.0f);
            break;
        default:
            return;
    }
    
    if (self.cropView.cropBoxAspectRatioIsPortrait) {
        CGFloat width = aspectRatio.width;
        aspectRatio.width = aspectRatio.height;
        aspectRatio.height = width;
    }
    
    [self.cropView setAspectLockEnabledWithAspectRatio:aspectRatio animated:YES];
    
     self.toolbar.clampButtonGlowing = YES;
}
- (void)rotateCropView
{
    [self.cropView rotateImageNinetyDegreesAnimated:YES];
}

#pragma mark - Crop View Delegates -
- (void)cropViewDidBecomeResettable:(TOCropView *)cropView
{
    self.toolbar.resetButtonEnabled = YES;
}
- (void)cropViewDidBecomeNonResettable:(TOCropView *)cropView
{
    self.toolbar.resetButtonEnabled = NO;
}
#pragma mark - Presentation Handling -
- (void)presentAnimatedFromParentViewController:(UIViewController *)viewController fromFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = self.image;
    self.transitionController.fromFrame = frame;
    
    __weak typeof (self) weakSelf = self;
    [viewController presentViewController:self animated:YES completion:^ {
        typeof (self) strongSelf = weakSelf;
        if (completion) {
            completion();
        }
        [strongSelf.cropView setCroppingViewsHidden:NO animated:YES];
        if (!CGRectIsEmpty(frame)) {
            [strongSelf.cropView setGridOverlayHidden:NO animated:YES];
        }
    }];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController withCroppedImage:(UIImage *)image toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = image;
    self.transitionController.fromFrame = [self.cropView convertRect:self.cropView.cropBoxFrame toView:self.view];
    self.transitionController.toFrame = frame;
    
    [viewController dismissViewControllerAnimated:YES completion:^ {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = self.image;
    self.transitionController.fromFrame = [self.cropView convertRect:self.cropView.imageViewFrame toView:self.view];
    self.transitionController.toFrame = frame;
    
    [viewController dismissViewControllerAnimated:YES completion:^ {
        if (completion) {
            completion();
        }
    }];
}
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    __weak typeof (self) weakSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        typeof (self) strongSelf = weakSelf;
        strongSelf.transitionController.toFrame = [strongSelf.cropView convertRect:strongSelf.cropView.cropBoxFrame toView:strongSelf.view];
        if (!CGRectIsEmpty(strongSelf.transitionController.fromFrame))
            strongSelf.cropView.croppingViewsHidden = YES;
        
        if (strongSelf.prepareForTransitionHandler)
            strongSelf.prepareForTransitionHandler();
        
        strongSelf.prepareForTransitionHandler = nil;
    };
    
    self.transitionController.isDismissing = NO;
    return self.transitionController;
}
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    __weak typeof (self) weakSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        typeof (self) strongSelf = weakSelf;
        if (!CGRectIsEmpty(strongSelf.transitionController.toFrame))
            strongSelf.cropView.croppingViewsHidden = YES;
        else
            strongSelf.cropView.simpleMode = YES;
        
        if (strongSelf.prepareForTransitionHandler)
            strongSelf.prepareForTransitionHandler();
    };
    
    self.transitionController.isDismissing = YES;
    
    return self.transitionController;
}
#pragma mark - Button Feedback -
- (void)cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCancelled:)]) {
        [self.delegate cropViewController:self didFinishCancelled:YES];
        return;
    }
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

//完成按钮
- (void)doneButtonTapped {
    NSLog(@"裁剪完成");
    CGRect cropFrame = self.cropView.croppedImageFrame;
    NSInteger angle = self.cropView.angle;
    
//    if ([self.delegate respondsToSelector:@selector(cropViewController:didCropToImage:withRect:angle:)]) {
        UIImage *image = nil;
        if (angle == 0 && CGRectEqualToRect(cropFrame, (CGRect){CGPointZero, self.image.size})) {
            image = self.image;
        }
        else {
            image = [self.image croppedImageWithFrame:cropFrame angle:angle];
        }
        NSLog(@"裁剪完的 image = %@", image);
        //dispatch on the next run-loop so the animation isn't interuppted by the crop operation
        //为啥要延时来着？？？
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(cropViewController:didCropToImage:withRect:angle:)]) {
                [self.delegate cropViewController:self didCropToImage:image withRect:cropFrame angle:angle];
            }
            FiltersViewController *vc = [[FiltersViewController alloc] init];
            
            vc.filtersImg = image;
            
            vc.imageURL = self.cropURL;
            
            [self presentViewController:vc animated:YES completion:nil];
        });
//    }
}
- (UIImage *)fixOrientation:(UIImage *)aImage{
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - 强制竖屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
