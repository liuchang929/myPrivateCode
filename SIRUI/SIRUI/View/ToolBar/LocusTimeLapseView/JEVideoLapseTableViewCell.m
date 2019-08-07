//
//  JEVideoLapseTableViewCell.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/6/22.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEVideoLapseTableViewCell.h"

@implementation JEVideoLapseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (NSString *)ID {
    return @"videoLocusTimeLapseTableViewCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    
        self.pointImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 275, 100)];
        self.pointImage.image = [UIImage imageNamed:@"view_motionLapse_pointImage"];
        self.pointImage.contentMode = UIViewContentModeScaleAspectFit;
        self.pointImage.userInteractionEnabled = YES;
        self.pointImage.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.pointImage];
    
        self.pointDeleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(275 - 50, 25, 50, 50)];
        [_pointDeleteBtn setImage:[UIImage imageNamed:@"icon_album_delect"] forState:UIControlStateNormal];
        _pointDeleteBtn.backgroundColor = [UIColor clearColor];
        _pointDeleteBtn.hidden = YES;
        [self addSubview:self.pointDeleteBtn];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
