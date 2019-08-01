//
//  JECameraSettingTableViewCell.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraSettingTableViewCell.h"

//cell 中 icon 的左边界
#define LEFT_WIDTH 10
//cell 字体大小
#define FONT_SIZE 16

@interface JECameraSettingTableViewCell ()

@end

@implementation JECameraSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.cellName = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_WIDTH, 0, frame.size.width/2, frame.size.height)];
        _cellName.textColor = [UIColor whiteColor];
        _cellName.font = [UIFont systemFontOfSize:FONT_SIZE];
        [self addSubview:_cellName];
        
        self.cellView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height)];
        [self addSubview:_cellView];
    }
    return self;
}

+ (NSString *)ID {
    return @"cameraSettingTableViewCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
