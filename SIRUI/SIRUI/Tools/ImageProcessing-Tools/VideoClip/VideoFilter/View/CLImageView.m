//
//  CLImageView.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/11.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLImageView.h"

@implementation CLImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.borderWidth = 5;
//        self.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:1].CGColor;
        self.bgimageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.bgimageView];
        
        self.filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, self.frame.size.width - 8, self.frame.size.height - 8)];
        _filterImageView.layer.cornerRadius = 5;
        _filterImageView.layer.masksToBounds = YES;
        [self.bgimageView addSubview:_filterImageView];
        
        self.downImage = [[UIImageView alloc] init];
        self.downImage.frame = self.filterImageView.bounds;
        self.downImage.image = KImageName(@"filter_downGrond");
        [self.filterImageView addSubview:self.downImage];
        
        self.titleName = [UILabel new];
        self.titleName.frame = CGRectMake(0, self.filterImageView.frame.size.height - 16, self.filterImageView.frame.size.width, 16);
        self.titleName.textColor = [UIColor whiteColor];
        //        self.titleName.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        //        self.titleName.shadowOffset = CGSizeMake(1, 1);
        //        self.titleName.layer.shadowRadius = 1;
        self.titleName.font = [UIFont systemFontOfSize:12];
        self.titleName.textAlignment = NSTextAlignmentCenter;
        [self.filterImageView addSubview:self.titleName];
    }
    return self;
}


@end
