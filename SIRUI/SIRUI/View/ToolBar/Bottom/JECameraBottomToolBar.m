//
//  JECameraBottomToolBar.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/2.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraBottomToolBar.h"
#import "JECameraBottomMenu.h"

//图标尺寸
#define ICON_SIDE       75

@interface JECameraBottomToolBar () <JECameraBottomMenuDelegate>

//Data
@property (nonatomic, assign) CGFloat   barWidth;                   //底边栏宽度
@property (nonatomic, assign) CGFloat   barHeight;                  //底边栏高度
@property (nonatomic, assign) CGFloat   bottomSpace;                //距离底边的距离

@end

@implementation JECameraBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame CameraMode:(BottomConnectMode)cameraMode {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUIFrame:frame CameraMode:cameraMode];
    }
    return self;
}

#pragma mark - UI
- (void)setupUIFrame:(CGRect)frame CameraMode:(BottomConnectMode)mode {
    
    NSArray *iconImageNameArray   = @[@"icon_shootSwitchBackground", @"icon_sub_single", @"icon_shoot_camera", @"icon_lansSwitch", @"icon_album"];
    
    _barWidth  = frame.size.width;
    _barHeight = frame.size.height;
    CGFloat topSpace  = 20.0f;
    _bottomSpace = 10.0f;    //距离底边的距离
    if (ITS_X_SERIES) {
        topSpace = 10.0f;
        _bottomSpace = 20.0f;
    }
    
    CGFloat iconSpace = (_barWidth - ICON_SIDE * iconImageNameArray.count)/(iconImageNameArray.count + 1);   //图标之间的间距
    
    //toolBar 背景
    self.toolBar = [[SRGradientbackground alloc] initWithFrame:CGRectMake(0, _barHeight - ICON_SIDE - _bottomSpace, _barWidth, ICON_SIDE + _bottomSpace) andTop:NO];
    
    //拍摄模式切换按钮
    self.shootSwitchButton = [[UIImageView alloc] initWithFrame:CGRectMake(iconSpace, (ICON_SIDE + _bottomSpace)/4, ICON_SIDE, ICON_SIDE/2)];
    _shootSwitchButton.userInteractionEnabled   = YES;
    _shootSwitchButton.image                    = [UIImage imageNamed:iconImageNameArray[0]];
    _shootSwitchButton.contentMode              = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer *shootSwitchButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootSwitchButtonTapAction)];
    shootSwitchButtonTap.numberOfTapsRequired = 1;  //单击
    [_shootSwitchButton addGestureRecognizer:shootSwitchButtonTap];
    //圆点
    self.shootSwitchTone = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _shootSwitchButton.frame.size.height, _shootSwitchButton.frame.size.height)];
    _shootSwitchTone.contentMode            = UIViewContentModeScaleAspectFit;
    _shootSwitchTone.userInteractionEnabled = YES;
    _shootSwitchTone.image                  = [UIImage imageNamed:@"icon_shootSwitchTone"];
    [_shootSwitchButton addSubview:_shootSwitchTone];
    //拍照模式
    self.shootSwitchPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(_shootSwitchButton.frame.size.height * 0.2, _shootSwitchButton.frame.size.height * 0.2, _shootSwitchButton.frame.size.height * 0.6, _shootSwitchButton.frame.size.height * 0.6)];
    _shootSwitchPhoto.userInteractionEnabled    = YES;
    _shootSwitchPhoto.image                     = [UIImage imageNamed:@"icon_shootSwitchPhoto_select"];
    _shootSwitchPhoto.contentMode               = UIViewContentModeScaleAspectFit;
    [_shootSwitchButton addSubview:_shootSwitchPhoto];
    //录像模式
    self.shootSwitchVideo = [[UIImageView alloc] initWithFrame:CGRectMake(_shootSwitchButton.frame.size.width - _shootSwitchButton.frame.size.height * 0.8, _shootSwitchButton.frame.size.height * 0.2, _shootSwitchButton.frame.size.height * 0.6, _shootSwitchButton.frame.size.height * 0.6)];
    _shootSwitchVideo.userInteractionEnabled    = YES;
    _shootSwitchVideo.image                     = [UIImage imageNamed:@"icon_shootSwitchVideo"];
    _shootSwitchVideo.contentMode               = UIViewContentModeScaleAspectFit;
    [_shootSwitchButton addSubview:_shootSwitchVideo];
    [_toolBar addSubview:_shootSwitchButton];
    
    //底部菜单键
    self.subBottomButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + ICON_SIDE, 0, ICON_SIDE, ICON_SIDE)];
    _subBottomButton.tag = 223;
    [_subBottomButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_subBottomButton setImage:[UIImage imageNamed:iconImageNameArray[1]] forState:UIControlStateNormal];
    _subBottomButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_subBottomButton];
    
    //快门键
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + ICON_SIDE * 2, 0, ICON_SIDE, ICON_SIDE)];
    _cameraButton.tag = 224;
    [_cameraButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraButton setImage:[UIImage imageNamed:iconImageNameArray[2]] forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"icon_shoot_stop"] forState:UIControlStateSelected];
    _cameraButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_cameraButton];
    
    //切换镜头键
    self.lensSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 4 + ICON_SIDE * 3, 0, ICON_SIDE, ICON_SIDE)];
    _lensSwitchButton.tag = 225;
    [_lensSwitchButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_lensSwitchButton setImage:[UIImage imageNamed:iconImageNameArray[3]] forState:UIControlStateNormal];
    _lensSwitchButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_lensSwitchButton];
    
    //相册键
    self.albumButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 5 + ICON_SIDE * 4, 0, ICON_SIDE, ICON_SIDE)];
    _albumButton.tag = 226;
    [_albumButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_albumButton setImage:[UIImage imageNamed:iconImageNameArray[4]] forState:UIControlStateNormal];
    _albumButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_albumButton];
    
    [self addSubview:_toolBar];
    
    self.bottomMenu = [[JECameraBottomMenu alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH * 0.6 - 105)];
    _bottomMenu.delegate = self;
    
    [self addSubview:_bottomMenu];
}

#pragma mark - Action
- (void)bottomToolButtonAction:(NSInteger)buttonTag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarButtonAction:)]) {
        [self.delegate bottomToolBarButtonAction:buttonTag];
    }
}

- (void)bottomButtonAction:(UIButton *)button {
    [self bottomToolButtonAction:button.tag];
}

- (void)shootSwitchButtonTapAction {
    [self bottomToolButtonAction:222];
}

#pragma mark - JECameraBottomMenuDelegate
- (void)bottomMenuAction:(NSInteger)buttonTag {
    [self.delegate bottomToolBarButtonAction:buttonTag];
    switch (buttonTag) {
        case 243:
        {
            //拍照单拍普通
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_normal"] forState:UIControlStateNormal];
        }
            break;
            
        case 244:
        {
            //拍照单拍 1s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay1s"] forState:UIControlStateNormal];
        }
            break;
            
        case 245:
        {
            //拍照单拍 2s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay2s"] forState:UIControlStateNormal];
        }
            break;
            
        case 246:
        {
            //拍照单拍 3s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay3s"] forState:UIControlStateNormal];
        }
            break;
            
        case 247:
        {
            //拍照单拍 4s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay4s"] forState:UIControlStateNormal];
        }
            break;
            
        case 248:
        {
            //拍照单拍 5s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay5s"] forState:UIControlStateNormal];
        }
            break;
            
        case 249:
        {
            //拍照单拍 10s
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_single_delay10s"] forState:UIControlStateNormal];
        }
            break;
            
        case 253:
        {
            //拍照全景 90d
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_pano_90d"] forState:UIControlStateNormal];
        }
            break;
            
        case 254:
        {
            //拍照全景 180d
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_pano_180d"] forState:UIControlStateNormal];
        }
            break;
            
        case 255:
        {
            //拍照全景 360d
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_pano_360d"] forState:UIControlStateNormal];
        }
            break;
            
        case 256:
        {
            //拍照全景 3x3
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_pano_3x3"] forState:UIControlStateNormal];
        }
            break;
            
        case 263:
        {
            //拍照九宫格模式一
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_NL_square"] forState:UIControlStateNormal];
        }
            break;
            
        case 264:
        {
            //拍照九宫格模式二
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_NL_rectangle"] forState:UIControlStateNormal];
        }
            break;
            
        case 273:
        {
            //录像普通
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_video_normal"] forState:UIControlStateNormal];
        }
            break;
            
        case 274:
        {
            //录像移动变焦
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_video_movingZoom"] forState:UIControlStateNormal];
        }
            break;
            
        case 275:
        {
            //录像慢动作
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_video_slowMotion"] forState:UIControlStateNormal];
        }
            break;
            
        case 276:
        {
            //录像轨迹延时
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_video_locusTimeLapse"] forState:UIControlStateNormal];
        }
            break;
            
        case 277:
        {
            //录像延时
            [_subBottomButton setImage:[UIImage imageNamed:@"icon_sub_video_timeLapse"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

@end
