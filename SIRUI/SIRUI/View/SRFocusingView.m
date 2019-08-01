//
//  SRFocusingView.m
//  SiRuiIOT
//
//  Created by 杨芳学 on 2018/8/1.
//

#import "SRFocusingView.h"
@implementation SRFocusingView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"SRFocusingView" owner:self options:nil] lastObject];
    
    if (self) {
        
        self.frame = frame;
        
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    self.focusImageView.userInteractionEnabled = YES;
    
    self.focusImageView.frame = CGRectMake(0,22.5,75,75);
    
    _slider = [[ZHPSlider alloc]initWithFrame:CGRectMake(self.focusImageView.frame.origin.x + self.focusImageView.frame.size.width+30, 0, 2 , 120)];
    _slider.backgroundColor = [UIColor yellowColor];
    _slider.directionType = DirectionVertical;
    _slider.sortType = SortReverse;
    _slider.decimalPlaces = 2;
    _slider.minimumValue = 0;
    _slider.maximumValue = 1.0;
    [_slider setValue:0.5];
    _slider.thumbImageView.image = [UIImage imageNamed:@"icon_focus_point"];
    [self addSubview:_slider];
}


@end
