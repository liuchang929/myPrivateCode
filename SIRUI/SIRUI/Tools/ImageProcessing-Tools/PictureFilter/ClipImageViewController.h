//
//  ClipImageViewController.h
//  PhotpShow
//
//  Created by FLYang on 16/2/26.
//  Copyright © 2016年 Fynn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBMacro.h"

@class CropImageView;

@interface ClipImageViewController : UIViewController

@property (nonatomic, strong) CropImageView           *   clipImageView;
@property (nonatomic, assign) CGRect                      clipImgRect;
@property (nonatomic, strong) UIImage                 *   clipImage;

- (UIImage *)clippingImage;

@end
