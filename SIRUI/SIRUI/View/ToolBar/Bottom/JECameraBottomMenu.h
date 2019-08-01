//
//  JECameraBottomMenu.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/4.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JECameraBottomMenuDelegate <NSObject>

- (void)bottomMenuAction:(NSInteger)buttonTag;

@end

@interface JECameraBottomMenu : UIView

@property (nonatomic, weak) id<JECameraBottomMenuDelegate> delegate;

@property (nonatomic, strong) UIView *subPictureView;        //拍照模式的菜单
@property (nonatomic, strong) UIView *subVideoView;          //录像模式的菜单
//menu
@property (nonatomic, strong) UIScrollView  *subPicSingleView;      //拍照-单拍菜单
@property (nonatomic, strong) UIScrollView  *subPicPanoView;        //拍照-全景菜单
@property (nonatomic, strong) UIScrollView  *subPicNLView;          //拍照-九宫图菜单
@property (nonatomic, strong) NSString *subButtonPicSelectedName;   //已选择的拍照模式名
@property (nonatomic, strong) NSString *subButtonVideoSelectedName; //已选择的录像模式名
//menuIcon
@property (nonatomic, strong) UIButton      *subPicSingle;              //拍照-单拍
@property (nonatomic, strong) UIButton      *subPicSingleNormal;        //拍照-单拍-普通
@property (nonatomic, strong) UIButton      *subPicSingleDelay1s;       //拍照-单拍-延迟1s
@property (nonatomic, strong) UIButton      *subPicSingleDelay2s;       //拍照-单拍-延迟2s
@property (nonatomic, strong) UIButton      *subPicSingleDelay3s;       //拍照-单拍-延迟3s
@property (nonatomic, strong) UIButton      *subPicSingleDelay4s;       //拍照-单拍-延迟4s
@property (nonatomic, strong) UIButton      *subPicSingleDelay5s;       //拍照-单拍-延迟5s
@property (nonatomic, strong) UIButton      *subPicSingleDelay10s;      //拍照-单拍-延迟10s
@property (nonatomic, strong) UIButton      *subPicPano;                //拍照-全景
@property (nonatomic, strong) UIButton      *subPicPano90d;             //拍照-全景-90度
@property (nonatomic, strong) UIButton      *subPicPano180d;            //拍照-全景-180度
@property (nonatomic, strong) UIButton      *subPicPano360d;            //拍照-全景-360度
@property (nonatomic, strong) UIButton      *subPicPano3x3;             //拍照-全景-3x3
@property (nonatomic, strong) UIButton      *subPicNL;                  //拍照-九宫图
@property (nonatomic, strong) UIButton      *subPicNLSquare;            //拍照-九宫图-正方
@property (nonatomic, strong) UIButton      *subPicNLRectangle;         //拍照-九宫图-长方
@property (nonatomic, strong) UIButton      *subVideoNormal;            //录像-普通
@property (nonatomic, strong) UIButton      *subVideoMovingZoom;        //录像-移动变焦
@property (nonatomic, strong) UIButton      *subVideoSlowMotion;        //录像-慢动作
@property (nonatomic, strong) UIButton      *subVideoLocusTimeLapse;    //录像-轨迹延时
@property (nonatomic, strong) UIButton      *subVideoTimeLapse;         //录像-延时摄影

- (void)subViewButtonAction:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
