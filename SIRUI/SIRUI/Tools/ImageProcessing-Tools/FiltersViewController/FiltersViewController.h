//
//  FiltersViewController.h
//  PhotpShow
//
//  Created by FLYang on 16/2/26.
//  Copyright © 2016年 Fynn. All rights reserved.
//

#import "FBPictureViewController.h"
#import "FBFootView.h"
#import "FiltersView.h"
#import "FBMacro.h"

@interface FiltersViewController : FBPictureViewController

@property (nonatomic, strong) FiltersView         *   filtersView;            //  滤镜视图
@property (nonatomic, strong) FBFootView          *   footView;               //  底部工具栏
@property (nonatomic, strong) UIImageView         *   filtersImageView;       //  需要处理的图片视图
@property (nonatomic, strong) UIImage             *   filtersImg;             //  需要处理的图片
@property (nonatomic, strong) NSString            *   filterName;             //  选择的滤镜名字
@property (nonatomic, strong) NSURL *imageURL;


@end
