//
//  JEAlbumCollectionViewCell.m
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/7/24.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEAlbumCollectionViewCell.h"

@interface JEAlbumCollectionViewCell ()

@property (nonatomic, assign) CGFloat cellWidth;

@end

@implementation JEAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cellWidth = frame.size.width;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.photoImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _cellWidth - 5, _cellWidth - 5)];
        _photoImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.photoImageView];
    
    self.videoPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _videoPlayBtn.center = CGPointMake(_cellWidth/2, _cellWidth/2);
    [_videoPlayBtn setImage:[UIImage imageNamed:@"icon_album_videoPlay"] forState:UIControlStateNormal];
    [self addSubview:self.videoPlayBtn];
    
    self.occlusionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _cellWidth - 5, _cellWidth - 5)];
        _occlusionView.backgroundColor = [UIColor clearColor];
        _occlusionView.alpha = 0.5;
    [self addSubview:self.occlusionView];
    
    self.selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(_cellWidth - 45, _cellWidth - 45, 40, 40)];
        [_selectedBtn setImage:[UIImage imageNamed:@"icon_album_selected"] forState:UIControlStateNormal];
    [self addSubview:self.selectedBtn];
}

@end
