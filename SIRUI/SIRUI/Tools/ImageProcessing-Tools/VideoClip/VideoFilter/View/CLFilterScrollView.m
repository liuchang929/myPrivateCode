//
//  CLFilterScrollView.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLFilterScrollView.h"
#import "CLImageView.h"

#define FilterImageWidth 98.0f // 带边框图片宽度
#define FilterSpacing  11.0f // 两张图距

@interface CLFilterScrollView ()

@property (nonatomic, strong) UIImage* image;

@end

@implementation CLFilterScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.indicatorStyle = UIScrollViewIndicatorStyleBlack;//滚动条样式
        self.showsHorizontalScrollIndicator = NO;//横向滚动条
        self.showsVerticalScrollIndicator = NO;//关闭纵向滚动条
        self.bounces = NO;//取消反弹效果
        self.userInteractionEnabled = YES;
        //scrollerView.pagingEnabled = YES;//划一屏
    }
    return self;
}

- (void)setFilterImages:(NSMutableArray *)filterImage titleArray:(NSArray *)titleArray index:(NSInteger)index
{
    self.contentSize = CGSizeMake(filterImage.count*(FilterImageWidth + FilterSpacing) + FilterSpacing, 0);
    
    for(int i = 0;i<filterImage.count;i++)
    {
        // 取出图片
        self.image = [filterImage objectAtIndex:i];
        
        CLImageView *bgImageView = [[CLImageView alloc]initWithFrame:CGRectMake(11+(FilterImageWidth + FilterSpacing)*i, (FilterScrollHight - FilterImageHight)/2, FilterImageWidth, FilterImageHight)];
         
        [self.imageArr addObject:bgImageView];
        [self.rectArr addObject:[NSValue valueWithCGRect:bgImageView.frame]];
        bgImageView.userInteractionEnabled = YES;
        bgImageView.filterImageView.image = self.image;
        
        if (i == 0) {
            
            bgImageView.downImage.hidden = YES;
        }
        if (titleArray.count > 0) {
            
            bgImageView.titleName.text = [titleArray objectAtIndex:i];
        }
        if (i == index) {
            
            bgImageView.bgimageView.image = KImageName(@"filter_box");
        }
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
        bgImageView.tag = i + 1;
        [bgImageView addGestureRecognizer:ges];
        [self addSubview:bgImageView];
        
    }
}

- (void)changeImage:(UITapGestureRecognizer *)tap
{
    for (int i = 0; i < self.imageArr.count; i++) {
        CLImageView *imageView = [self.imageArr objectAtIndex:i];
        imageView.bgimageView.image = nil;
        imageView.frame = [[self.rectArr objectAtIndex:i] CGRectValue];
    }
    CLImageView *view = (CLImageView *)tap.view;
    view.bgimageView.image = KImageName(@"filter_box");
    scaleAnimation(view);
    if ([self.tbDelegate respondsToSelector:@selector(seletcScrollIndex:)]) {
        [self.tbDelegate seletcScrollIndex:(view.tag - 1)];
    }
}
- (NSMutableArray *)imageArr
{
    if (!_imageArr) {
        
        _imageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArr;
}

- (NSMutableArray *)rectArr
{
    if (!_rectArr) {
        _rectArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _rectArr;
}

@end
