//
//  CLFilterViewController.h
//  tiaooo
//  
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef enum {
    NormalCL = 0,
    DelayedCL,
    SlowCL
}SaveVideoStyleCL;

@interface CLFilterViewController : UIViewController
{
    BOOL isPlay;//播放暂停 开始
    BOOL isShowFilter;// 滤镜显示 隐藏
}
@property (nonatomic,strong)NSURL *videoUrl; //传入视频url
@property (nonatomic,strong)UIImage *firstImage;

@property(nonatomic,assign)SaveVideoStyleCL saveVideoStyleCL;

@end
