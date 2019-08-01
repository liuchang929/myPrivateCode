//
//  SRSliderView.m
//  SiRuiIOT
//
//  Created by 杨芳学 on 2018/8/8.
//

#import "SliderView.h"

@implementation SliderView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
       
        [self setupUI];
    }
    
    return self;
}
- (void)setupUI{
    
    _srSlider = [[ZHPSlider alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _srSlider.directionType = DirectionVertical;
    _srSlider.sortType = SortReverse;
    _srSlider.decimalPlaces = 2;
    _srSlider.minimumValue = 1.0;
    _srSlider.maximumValue = 3.0;
    [_srSlider setValue:1.0];
    _srSlider.thumbImageView.image = [UIImage imageNamed:@"icon_zoom_point"];
    [self addSubview:_srSlider];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
