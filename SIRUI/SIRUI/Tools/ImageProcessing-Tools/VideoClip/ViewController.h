//
//  ViewController.h
//  Sight
//
//  Created by fangxue on 16/8/12.
//  Copyright © 2016年 fangxue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Normal = 0,
    Delayed,
    Slow
}SaveVideoStyle;

#import "FBPictureViewController.h"

@interface ViewController : FBPictureViewController

@property(nonatomic,strong)NSURL *videoUrlYFX;

@property(nonatomic,strong)UIImage *firstImage;

@property(nonatomic,assign)SaveVideoStyle saveVideoStyle;

@end

