//
//  JECameraSettingTableView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/12.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraSettingTableView.h"

@interface JECameraSettingTableView ()

@end

@implementation JECameraSettingTableView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //分割线颜色
        self.separatorColor = [UIColor grayColor];

    }
    return self;
}

@end
