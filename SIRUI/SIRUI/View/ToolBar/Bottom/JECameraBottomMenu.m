//
//  JECameraBottomMenu.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/4.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraBottomMenu.h"
#define ICON_SIDE 50
#define FONT_SIZE 12
#define ICON_SPACE 50

@interface JECameraBottomMenu ()

//Data
@property (nonatomic, assign) CGFloat   menuWidth;                  //菜单宽度
@property (nonatomic, assign) CGFloat   menuHeight;                 //菜单高度

@end

@implementation JECameraBottomMenu

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIFrame:frame];
    }
    return self;
}

- (void)setupUIFrame:(CGRect)frame  {
    
    _menuWidth  = frame.size.width;
    _menuHeight = frame.size.height;
    
    //数据初始化
    [self initData];
    
    //菜单
    [self setupPictureView];
    [self setupVideoView];
}

- (void)initData {
    self.subButtonPicSelectedName = @"icon_sub_single";
    self.subButtonVideoSelectedName = @"icon_sub_video";
}

#pragma mark - PictureView
- (void)setupPictureView {
    self.subPictureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _menuWidth, _menuHeight)];
    
    NSArray *subPicArray = @[@"icon_sub_single", @"icon_sub_pano", @"icon_sub_NL"];
    NSArray *subPicSelectArray = @[@"icon_sub_single_select", @"icon_sub_pano_select", @"icon_sub_NL_select"];
    
    CGFloat iconSide        = _menuHeight/2;
    CGFloat iconSpace       = (_menuWidth - iconSide * subPicArray.count)/(subPicArray.count + 1);   //菜单主图标之间的间距
    
    //拍照-单拍
    self.subPicSingle = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, _menuHeight/2, iconSide, iconSide)];
    _subPicSingle.tag = 233;
    [_subPicSingle addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingle setImage:[UIImage imageNamed:subPicArray[0]]         forState:UIControlStateNormal];
    [_subPicSingle setImage:[UIImage imageNamed:subPicSelectArray[0]]   forState:UIControlStateSelected];
    [_subPicSingle setTitle:NSLocalizedString(@"Single", nil) forState:UIControlStateNormal];
    _subPicSingle.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subPicSingle.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subPicSingle.selected = YES;
    _subPicSingle.imageView.contentMode = UIViewContentModeScaleToFill;
    _subPicSingle.imageEdgeInsets = UIEdgeInsetsMake(-_subPicSingle.titleLabel.intrinsicContentSize.height, 0, 0, -_subPicSingle.titleLabel.intrinsicContentSize.width);
    _subPicSingle.titleEdgeInsets = UIEdgeInsetsMake(_subPicSingle.imageView.frame.size.height, -iconSide/2-ICON_SPACE-10, 0, -ICON_SPACE);
    [_subPictureView addSubview:_subPicSingle];
    
    //拍照-全景
    self.subPicPano = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + iconSide, _menuHeight/2, iconSide, iconSide)];
    _subPicPano.tag = 234;
    [_subPicPano addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicPano setImage:[UIImage imageNamed:subPicArray[1]]       forState:UIControlStateNormal];
    [_subPicPano setImage:[UIImage imageNamed:subPicSelectArray[1]] forState:UIControlStateSelected];
    [_subPicPano setTitle:NSLocalizedString(@"Pano", nil) forState:UIControlStateNormal];
    _subPicPano.titleLabel.textAlignment = NSTextAlignmentCenter;
    _subPicPano.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subPicPano.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subPicPano.imageView.contentMode = UIViewContentModeScaleToFill;
    _subPicPano.imageEdgeInsets = UIEdgeInsetsMake(-_subPicPano.titleLabel.intrinsicContentSize.height, 0, 0, -_subPicPano.titleLabel.intrinsicContentSize.width);
    _subPicPano.titleEdgeInsets = UIEdgeInsetsMake(_subPicPano.imageView.frame.size.height, -iconSide/2 - ICON_SPACE-10, 0, -ICON_SPACE);
    [_subPictureView addSubview:_subPicPano];
    
    //拍照-九宫图
    self.subPicNL = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + iconSide * 2, _menuHeight/2, iconSide, iconSide)];
    _subPicNL.tag = 235;
    [_subPicNL addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicNL setImage:[UIImage imageNamed:subPicArray[2]]         forState:UIControlStateNormal];
    [_subPicNL setImage:[UIImage imageNamed:subPicSelectArray[2]]   forState:UIControlStateSelected];
    [_subPicNL setTitle:NSLocalizedString(@"Sodoku", nil) forState:UIControlStateNormal];
    _subPicNL.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subPicNL.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subPicNL.imageView.contentMode = UIViewContentModeScaleToFill;
    _subPicNL.imageEdgeInsets = UIEdgeInsetsMake(-_subPicNL.titleLabel.intrinsicContentSize.height, 0, 0, -_subPicNL.titleLabel.intrinsicContentSize.width);
    _subPicNL.titleEdgeInsets = UIEdgeInsetsMake(_subPicNL.imageView.frame.size.height, -iconSide/2 - ICON_SPACE-10, 0, -ICON_SPACE);
    [_subPictureView addSubview:_subPicNL];
    
    [self addSubview:_subPictureView];
    
    _subPictureView.hidden = YES;
    
    [self setupPicSingleView];
    [self setupPicPanoView];
    [self setupPicNLView];
}

- (void)setupPicSingleView {

    //拍照-单拍
    self.subPicSingleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _menuWidth, _menuHeight/2)];
    
    NSArray *subPicSingleArray = @[@"icon_sub_single_normal", @"icon_sub_single_delay1s", @"icon_sub_single_delay2s", @"icon_sub_single_delay3s", @"icon_sub_single_delay4s", @"icon_sub_single_delay5s", @"icon_sub_single_delay10s"];
    NSArray *subPicSingleSelectArray = @[@"icon_sub_single_normal_select", @"icon_sub_single_delay1s_select", @"icon_sub_single_delay2s_select", @"icon_sub_single_delay3s_select", @"icon_sub_single_delay4s_select", @"icon_sub_single_delay5s_select", @"icon_sub_single_delay10s_select"];
    
    CGFloat iconSide = _menuHeight/3;
    
    CGFloat iconSpace = (_menuWidth - iconSide * subPicSingleArray.count)/(subPicSingleArray.count + 1);  //菜单副图标间隔
    
    _subPicSingleView.contentSize = CGSizeMake(subPicSingleArray.count * (iconSpace + iconSide) + iconSpace, _menuHeight/2);
    _subPicSingleView.bounces = YES;
    _subPicSingleView.scrollEnabled = YES;
    _subPicSingleView.showsHorizontalScrollIndicator = YES;
    
    //拍照-单拍-普通
    self.subPicSingleNormal = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, 0, iconSide, iconSide)];
    _subPicSingleNormal.tag = 243;
    _subPicSingleNormal.selected = YES;
    [_subPicSingleNormal addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleNormal setImage:[UIImage imageNamed:subPicSingleArray[0]] forState:UIControlStateNormal];
    [_subPicSingleNormal setImage:[UIImage imageNamed:subPicSingleSelectArray[0]] forState:UIControlStateSelected];
    _subPicSingleNormal.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleNormal];
    
    //拍照-单拍-延时1s
    self.subPicSingleDelay1s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + iconSide, 0, iconSide, iconSide)];
    _subPicSingleDelay1s.tag = 244;
    [_subPicSingleDelay1s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay1s setImage:[UIImage imageNamed:subPicSingleArray[1]] forState:UIControlStateNormal];
    [_subPicSingleDelay1s setImage:[UIImage imageNamed:subPicSingleSelectArray[1]] forState:UIControlStateSelected];
    _subPicSingleDelay1s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay1s];

    //拍照-单拍-延时2s
    self.subPicSingleDelay2s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + iconSide * 2, 0, iconSide, iconSide)];
    _subPicSingleDelay2s.tag = 245;
    [_subPicSingleDelay2s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay2s setImage:[UIImage imageNamed:subPicSingleArray[2]] forState:UIControlStateNormal];
    [_subPicSingleDelay2s setImage:[UIImage imageNamed:subPicSingleSelectArray[2]] forState:UIControlStateSelected];
    _subPicSingleDelay2s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay2s];
    
    //拍照-单拍-延时3s
    self.subPicSingleDelay3s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 4 + iconSide * 3, 0, iconSide, iconSide)];
    _subPicSingleDelay3s.tag = 246;
    [_subPicSingleDelay3s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay3s setImage:[UIImage imageNamed:subPicSingleArray[3]] forState:UIControlStateNormal];
    [_subPicSingleDelay3s setImage:[UIImage imageNamed:subPicSingleSelectArray[3]] forState:UIControlStateSelected];
    _subPicSingleDelay3s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay3s];
    
    //拍照-单拍-延时4s
    self.subPicSingleDelay4s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 5 + iconSide * 4, 0, iconSide, iconSide)];
    _subPicSingleDelay4s.tag = 247;
    [_subPicSingleDelay4s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay4s setImage:[UIImage imageNamed:subPicSingleArray[4]] forState:UIControlStateNormal];
    [_subPicSingleDelay4s setImage:[UIImage imageNamed:subPicSingleSelectArray[4]] forState:UIControlStateSelected];
    _subPicSingleDelay4s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay4s];
    
    //拍照-单拍-延时5s
    self.subPicSingleDelay5s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 6 + iconSide * 5, 0, iconSide, iconSide)];
    _subPicSingleDelay5s.tag = 248;
    [_subPicSingleDelay5s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay5s setImage:[UIImage imageNamed:subPicSingleArray[5]] forState:UIControlStateNormal];
    [_subPicSingleDelay5s setImage:[UIImage imageNamed:subPicSingleSelectArray[5]] forState:UIControlStateSelected];
    _subPicSingleDelay5s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay5s];
    
    //拍照-单拍-延时10s
    self.subPicSingleDelay10s = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 7 + iconSide * 6, 0, iconSide, iconSide)];
    _subPicSingleDelay10s.tag = 249;
    [_subPicSingleDelay10s addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicSingleDelay10s setImage:[UIImage imageNamed:subPicSingleArray[6]] forState:UIControlStateNormal];
    [_subPicSingleDelay10s setImage:[UIImage imageNamed:subPicSingleSelectArray[6]] forState:UIControlStateSelected];
    _subPicSingleDelay10s.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicSingleView addSubview:_subPicSingleDelay10s];
    
    _subPicSingleView.hidden = !_subPicSingle.selected;
    
    [_subPictureView addSubview:_subPicSingleView];
}

- (void)setupPicPanoView {

    //拍照-全景
    self.subPicPanoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _menuWidth, _menuHeight/2)];
    
    NSArray *subPicPanoArray = @[@"icon_sub_pano_90d", @"icon_sub_pano_180d", @"icon_sub_pano_360d", @"icon_sub_pano_3x3"];
    NSArray *subPicPanoSelectArray = @[@"icon_sub_pano_90d_select", @"icon_sub_pano_180d_select", @"icon_sub_pano_360d_select", @"icon_sub_pano_3x3_select"];
    
    CGFloat iconSide = _menuHeight/3;
    
    CGFloat iconSpace = (_menuWidth - iconSide * subPicPanoArray.count)/(subPicPanoArray.count + 1);    //菜单副图标间隔
    
    _subPicPanoView.contentSize = CGSizeMake(subPicPanoArray.count * (iconSpace + iconSide) + iconSpace, _menuHeight/2);
    _subPicPanoView.bounces = YES;
    _subPicPanoView.scrollEnabled = YES;
    _subPicPanoView.showsHorizontalScrollIndicator = YES;
    
    //拍照-全景-90d
    self.subPicPano90d = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, 0, iconSide, iconSide)];
    _subPicPano90d.tag = 253;
    [_subPicPano90d addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicPano90d setImage:[UIImage imageNamed:subPicPanoArray[0]] forState:UIControlStateNormal];
    [_subPicPano90d setImage:[UIImage imageNamed:subPicPanoSelectArray[0]] forState:UIControlStateSelected];
    _subPicPano90d.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicPanoView addSubview:_subPicPano90d];
    
    //拍照-全景-180d
    self.subPicPano180d = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + iconSide, 0, iconSide, iconSide)];
    _subPicPano180d.tag = 254;
    [_subPicPano180d addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicPano180d setImage:[UIImage imageNamed:subPicPanoArray[1]] forState:UIControlStateNormal];
    [_subPicPano180d setImage:[UIImage imageNamed:subPicPanoSelectArray[1]] forState:UIControlStateSelected];
    _subPicPano180d.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicPanoView addSubview:_subPicPano180d];
    
    //拍照-全景-360d
    self.subPicPano360d = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + iconSide * 2, 0, iconSide, iconSide)];
    _subPicPano360d.tag = 255;
    [_subPicPano360d addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicPano360d setImage:[UIImage imageNamed:subPicPanoArray[2]] forState:UIControlStateNormal];
    [_subPicPano360d setImage:[UIImage imageNamed:subPicPanoSelectArray[2]] forState:UIControlStateSelected];
    _subPicPano360d.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicPanoView addSubview:_subPicPano360d];
    
    //拍照-全景-3x3
    self.subPicPano3x3 = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 4 + iconSide * 3, 0, iconSide, iconSide)];
    _subPicPano3x3.tag = 256;
    [_subPicPano3x3 addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicPano3x3 setImage:[UIImage imageNamed:subPicPanoArray[3]] forState:UIControlStateNormal];
    [_subPicPano3x3 setImage:[UIImage imageNamed:subPicPanoSelectArray[3]] forState:UIControlStateSelected];
    _subPicPano3x3.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicPanoView addSubview:_subPicPano3x3];
    
    _subPicPanoView.hidden = !_subPicPano.selected;
    
    [_subPictureView addSubview:_subPicPanoView];

}

- (void)setupPicNLView {
    
    //拍照-九宫图
    self.subPicNLView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _menuWidth, _menuHeight/2)];
    
    NSArray *subPicNLArray = @[@"icon_sub_NL_square", @"icon_sub_NL_rectangle"];
    NSArray *subPicNLSelectArray = @[@"icon_sub_NL_square_select", @"icon_sub_NL_rectangle_select"];
    
    CGFloat iconSide = _menuHeight/3;
    
    CGFloat iconSpace = (_menuWidth - iconSide * subPicNLArray.count)/(subPicNLArray.count + 1);
    
    _subPicNLView.contentSize = CGSizeMake(subPicNLArray.count * (iconSpace + iconSide) + iconSpace, _menuHeight/2);
    _subPicNLView.bounces = YES;
    _subPicNLView.scrollEnabled = YES;
    _subPicNLView.showsHorizontalScrollIndicator = YES;
    
    //拍照-九宫图-模式一
    self.subPicNLSquare = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, 0, iconSide, iconSide)];
    _subPicNLSquare.tag = 263;
    [_subPicNLSquare addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicNLSquare setImage:[UIImage imageNamed:subPicNLArray[0]] forState:UIControlStateNormal];
    [_subPicNLSquare setImage:[UIImage imageNamed:subPicNLSelectArray[0]] forState:UIControlStateSelected];
    _subPicNLSquare.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicNLView addSubview:_subPicNLSquare];
    
    //拍照-九宫图-模式二
    self.subPicNLRectangle = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + iconSide, 0, iconSide, iconSide)];
    _subPicNLRectangle.tag = 264;
    [_subPicNLRectangle addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subPicNLRectangle setImage:[UIImage imageNamed:subPicNLArray[1]] forState:UIControlStateNormal];
    [_subPicNLRectangle setImage:[UIImage imageNamed:subPicNLSelectArray[1]] forState:UIControlStateSelected];
    _subPicNLRectangle.imageView.contentMode = UIViewContentModeScaleToFill;
    [_subPicNLView addSubview:_subPicNLRectangle];
    
    _subPicNLView.hidden = !_subPicNL.selected;
    
    [_subPictureView addSubview:_subPicNLView];
}

#pragma mark - VideoView
- (void)setupVideoView {
    self.subVideoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _menuWidth, _menuHeight)];
    
    NSArray *subVideoArray = @[@"icon_sub_video_normal", @"icon_sub_video_movingZoom", @"icon_sub_video_slowMotion", @"icon_sub_video_locusTimeLapse", @"icon_sub_video_timeLapse"];
    NSArray *subVideoSelectArray = @[@"icon_sub_video_normal_select", @"icon_sub_video_movingZoom_select", @"icon_sub_video_slowMotion_select", @"icon_sub_video_locusTimeLapse_select", @"icon_sub_video_timeLapse_select"];
    
    CGFloat iconSide = _menuHeight/3;
    CGFloat iconSpace = (_menuWidth - iconSide * subVideoArray.count)/(subVideoArray.count + 1);    //图标间距
    
    //录像-普通
    self.subVideoNormal = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, (_menuHeight + iconSide)/2, iconSide, iconSide)];
    _subVideoNormal.tag = 273;
    [_subVideoNormal addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subVideoNormal setImage:[UIImage imageNamed:subVideoArray[0]] forState:UIControlStateNormal];
    [_subVideoNormal setImage:[UIImage imageNamed:subVideoSelectArray[0]] forState:UIControlStateSelected];
    _subVideoNormal.selected = YES;
    [_subVideoNormal setTitle:NSLocalizedString(@"Normal", nil) forState:UIControlStateNormal];
    _subVideoNormal.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subVideoNormal.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subVideoNormal.imageView.contentMode = UIViewContentModeScaleToFill;
    _subVideoNormal.imageEdgeInsets = UIEdgeInsetsMake(-_subVideoNormal.titleLabel.intrinsicContentSize.height, 0, 0, -_subVideoNormal.titleLabel.intrinsicContentSize.width);
    _subVideoNormal.titleEdgeInsets = UIEdgeInsetsMake(_subVideoNormal.imageView.frame.size.height, -iconSide/2 - ICON_SPACE - 15, 0, -ICON_SPACE);
    [_subVideoView addSubview:_subVideoNormal];
    
    //录像-移动变焦
    self.subVideoMovingZoom = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + iconSide, (_menuHeight + iconSide)/2, iconSide, iconSide)];
    _subVideoMovingZoom.tag = 274;
    [_subVideoMovingZoom addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subVideoMovingZoom setImage:[UIImage imageNamed:subVideoArray[1]] forState:UIControlStateNormal];
    [_subVideoMovingZoom setImage:[UIImage imageNamed:subVideoSelectArray[1]] forState:UIControlStateSelected];
    [_subVideoMovingZoom setTitle:NSLocalizedString(@"Motion Zoom", nil) forState:UIControlStateNormal];
    _subVideoMovingZoom.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subVideoMovingZoom.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subVideoMovingZoom.imageView.contentMode = UIViewContentModeScaleToFill;
    _subVideoMovingZoom.imageEdgeInsets = UIEdgeInsetsMake(-_subVideoMovingZoom.titleLabel.intrinsicContentSize.height, 0, 0, -_subVideoMovingZoom.titleLabel.intrinsicContentSize.width);
    _subVideoMovingZoom.titleEdgeInsets = UIEdgeInsetsMake(_subVideoMovingZoom.imageView.frame.size.height, -iconSide/2 - ICON_SPACE - 15, 0, -ICON_SPACE);
    [_subVideoView addSubview:_subVideoMovingZoom];
    
    //录像-慢动作
    /*
    self.subVideoSlowMotion = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + iconSide * 2, (_menuHeight + iconSide)/2, iconSide, iconSide)];
    _subVideoSlowMotion.tag = 275;
    [_subVideoSlowMotion addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subVideoSlowMotion setImage:[UIImage imageNamed:subVideoArray[2]] forState:UIControlStateNormal];
    [_subVideoSlowMotion setImage:[UIImage imageNamed:subVideoSelectArray[2]] forState:UIControlStateSelected];
    [_subVideoSlowMotion setTitle:NSLocalizedString(@"Slow Motion", nil) forState:UIControlStateNormal];
    _subVideoSlowMotion.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subVideoSlowMotion.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subVideoSlowMotion.imageView.contentMode = UIViewContentModeScaleToFill;
    _subVideoSlowMotion.imageEdgeInsets = UIEdgeInsetsMake(-_subVideoSlowMotion.titleLabel.intrinsicContentSize.height, 0, 0, -_subVideoSlowMotion.titleLabel.intrinsicContentSize.width);
    _subVideoSlowMotion.titleEdgeInsets = UIEdgeInsetsMake(_subVideoSlowMotion.imageView.frame.size.height, -iconSide/2 - ICON_SPACE - 15, 0, -ICON_SPACE);
    [_subVideoView addSubview:_subVideoSlowMotion];
     */
    
    //录像-轨迹延时
    self.subVideoLocusTimeLapse = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + iconSide * 2, (_menuHeight + iconSide)/2, iconSide, iconSide)];
    _subVideoLocusTimeLapse.tag = 276;
    [_subVideoLocusTimeLapse addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subVideoLocusTimeLapse setImage:[UIImage imageNamed:subVideoArray[3]] forState:UIControlStateNormal];
    [_subVideoLocusTimeLapse setImage:[UIImage imageNamed:subVideoSelectArray[3]] forState:UIControlStateSelected];
    [_subVideoLocusTimeLapse setTitle:NSLocalizedString(@"Path Lapse", nil) forState:UIControlStateNormal];
    _subVideoLocusTimeLapse.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subVideoLocusTimeLapse.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subVideoLocusTimeLapse.imageView.contentMode = UIViewContentModeScaleToFill;
    _subVideoLocusTimeLapse.imageEdgeInsets = UIEdgeInsetsMake(-_subVideoLocusTimeLapse.titleLabel.intrinsicContentSize.height, 0, 0, -_subVideoLocusTimeLapse.titleLabel.intrinsicContentSize.width);
    _subVideoLocusTimeLapse.titleEdgeInsets = UIEdgeInsetsMake(_subVideoLocusTimeLapse.imageView.frame.size.height, -iconSide/2 - ICON_SPACE - 15, 0, -ICON_SPACE);
    [_subVideoView addSubview:_subVideoLocusTimeLapse];
    
    //录像-延时
    self.subVideoTimeLapse = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 4 + iconSide * 3, (_menuHeight + iconSide)/2, iconSide, iconSide)];
    _subVideoTimeLapse.tag = 277;
    [_subVideoTimeLapse addTarget:self action:@selector(subViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subVideoTimeLapse setImage:[UIImage imageNamed:subVideoArray[4]] forState:UIControlStateNormal];
    [_subVideoTimeLapse setImage:[UIImage imageNamed:subVideoSelectArray[4]] forState:UIControlStateSelected];
    [_subVideoTimeLapse setTitle:NSLocalizedString(@"Time Lapse", nil) forState:UIControlStateNormal];
    _subVideoTimeLapse.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    _subVideoTimeLapse.titleLabel.adjustsFontSizeToFitWidth = YES;
    _subVideoTimeLapse.imageView.contentMode = UIViewContentModeScaleToFill;
    _subVideoTimeLapse.imageEdgeInsets = UIEdgeInsetsMake(-_subVideoTimeLapse.titleLabel.intrinsicContentSize.height, 0, 0, -_subVideoTimeLapse.titleLabel.intrinsicContentSize.width);
    _subVideoTimeLapse.titleEdgeInsets = UIEdgeInsetsMake(_subVideoTimeLapse.imageView.frame.size.height, -iconSide/2 - ICON_SPACE - 15, 0, -ICON_SPACE);
    [_subVideoView addSubview:_subVideoTimeLapse];
    
    _subVideoView.hidden = YES;
    
    [self addSubview:_subVideoView];
}

#pragma mark - Action
- (void)subViewButtonAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomMenuAction:)]) {
        [self.delegate bottomMenuAction:button.tag];
    }
    
    switch (button.tag) {
        case 233: {
            NSLog(@"拍照-单拍");
            _subPicSingle.selected = YES;
            _subPicPano.selected = NO;
            _subPicNL.selected = NO;
            _subPicSingleView.hidden = NO;
            _subPicPanoView.hidden = YES;
            _subPicNLView.hidden = YES;
            [self subViewButtonAction:_subPicSingleNormal];
        }
            break;
            
        case 234: {
            NSLog(@"拍照-全景");
            _subPicSingle.selected = NO;
            _subPicPano.selected = YES;
            _subPicNL.selected = NO;
            _subPicSingleView.hidden = YES;
            _subPicPanoView.hidden = NO;
            _subPicNLView.hidden = YES;
            [self subViewButtonAction:_subPicPano90d];
        }
            break;
            
        case 235: {
            NSLog(@"拍照-九宫图");
            _subPicSingle.selected = NO;
            _subPicPano.selected = NO;
            _subPicNL.selected = YES;
            _subPicSingleView.hidden = YES;
            _subPicPanoView.hidden = YES;
            _subPicNLView.hidden = NO;
            [self subViewButtonAction:_subPicNLSquare];
        }
            break;
            
        case 243: {
            NSLog(@"拍照-单拍-普通");
            _subPicSingleNormal.selected = YES;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 244: {
            NSLog(@"拍照-单拍-1s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = YES;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 245: {
            NSLog(@"拍照-单拍-2s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = YES;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 246: {
            NSLog(@"拍照-单拍-3s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = YES;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 247: {
            NSLog(@"拍照-单拍-4s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = YES;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 248: {
            NSLog(@"拍照-单拍-5s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = YES;
            _subPicSingleDelay10s.selected = NO;
        }
            break;
            
        case 249: {
            NSLog(@"拍照-单拍-10s");
            _subPicSingleNormal.selected = NO;
            _subPicSingleDelay1s.selected = NO;
            _subPicSingleDelay2s.selected = NO;
            _subPicSingleDelay3s.selected = NO;
            _subPicSingleDelay4s.selected = NO;
            _subPicSingleDelay5s.selected = NO;
            _subPicSingleDelay10s.selected = YES;
        }
            break;
            
        case 253: {
            NSLog(@"拍照-全景-90d");
            _subPicPano90d.selected = YES;
            _subPicPano180d.selected = NO;
            _subPicPano360d.selected = NO;
            _subPicPano3x3.selected = NO;
        }
            break;
            
        case 254: {
            NSLog(@"拍照-全景-180d");
            _subPicPano90d.selected = NO;
            _subPicPano180d.selected = YES;
            _subPicPano360d.selected = NO;
            _subPicPano3x3.selected = NO;
        }
            break;
            
        case 255: {
            NSLog(@"拍照-全景-360d");
            _subPicPano90d.selected = NO;
            _subPicPano180d.selected = NO;
            _subPicPano360d.selected = YES;
            _subPicPano3x3.selected = NO;
        }
            break;
            
        case 256: {
            NSLog(@"拍照-全景-3x3");
            _subPicPano90d.selected = NO;
            _subPicPano180d.selected = NO;
            _subPicPano360d.selected = NO;
            _subPicPano3x3.selected = YES;
        }
            break;
            
        case 263: {
            NSLog(@"拍照-九宫格-模式一");
            _subPicNLSquare.selected = YES;
            _subPicNLRectangle.selected = NO;
        }
            break;
            
        case 264: {
            NSLog(@"拍照-九宫格-模式二");
            _subPicNLSquare.selected = NO;
            _subPicNLRectangle.selected = YES;
        }
            break;
            
        case 273: {
            NSLog(@"录像-普通");
            _subVideoNormal.selected = YES;
            _subVideoMovingZoom.selected = NO;
            _subVideoSlowMotion.selected = NO;
            _subVideoLocusTimeLapse.selected = NO;
            _subVideoTimeLapse.selected = NO;
        }
            break;
            
        case 274: {
            NSLog(@"录像-移动变焦");
            _subVideoNormal.selected = NO;
            _subVideoMovingZoom.selected = YES;
            _subVideoSlowMotion.selected = NO;
            _subVideoLocusTimeLapse.selected = NO;
            _subVideoTimeLapse.selected = NO;
        }
            break;
            
        case 275: {
            NSLog(@"录像-慢动作");
            _subVideoNormal.selected = NO;
            _subVideoMovingZoom.selected = NO;
            _subVideoSlowMotion.selected = YES;
            _subVideoLocusTimeLapse.selected = NO;
            _subVideoTimeLapse.selected = NO;
        }
            break;
            
        case 276: {
            NSLog(@"录像-轨迹延时");
            _subVideoNormal.selected = NO;
            _subVideoMovingZoom.selected = NO;
            _subVideoSlowMotion.selected = NO;
            _subVideoLocusTimeLapse.selected = YES;
            _subVideoTimeLapse.selected = NO;
        }
            break;
            
        case 277: {
            NSLog(@"录像-延时");
            _subVideoNormal.selected = NO;
            _subVideoMovingZoom.selected = NO;
            _subVideoSlowMotion.selected = NO;
            _subVideoLocusTimeLapse.selected = NO;
            _subVideoTimeLapse.selected = YES;
        }
            break;
            
        default:
            break;
    }
}

@end
