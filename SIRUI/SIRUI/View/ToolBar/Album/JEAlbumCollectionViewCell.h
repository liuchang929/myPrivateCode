//
//  JEAlbumCollectionViewCell.h
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/7/24.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEAlbumCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton    *photoImageView;  //预览图
@property (nonatomic, strong) UIView      *occlusionView;   //遮拦 view
@property (nonatomic, strong) UIButton    *videoPlayBtn;    //播放按钮
@property (nonatomic, strong) UIButton    *selectedBtn;     //多选按钮

@end

NS_ASSUME_NONNULL_END
