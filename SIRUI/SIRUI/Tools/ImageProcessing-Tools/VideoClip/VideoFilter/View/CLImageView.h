//
//  CLImageView.h
//  tiaooo
//
//  Created by ClaudeLi on 16/1/11.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
  scrollView上的ImageView
 */

@interface CLImageView : UIView

@property (nonatomic, strong) UIImageView *bgimageView; // 背景图
@property (nonatomic, strong) UIImageView *filterImageView; // 滤镜图
@property (nonatomic, strong) UIImageView *downImage; 
@property (nonatomic, strong) UILabel *titleName; // 滤镜名

@end
