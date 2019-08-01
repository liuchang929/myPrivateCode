//
//  ZHPSlider.m
//  ZHPSlider
//
//  Created by 朱慧平 on 16/7/29.
//  Copyright © 2016年 Crystal. All rights reserved.
//

#import "ZHPSlider.h"

@interface ZHPSlider() {
}
@end

@implementation ZHPSlider

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    _value = 0.f;
    _minimumValue = 0.f;
    _maximumValue = 1.f;
    _decimalPlaces = 0.0f;
    
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 0.7;
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_backgroundImageView];
    _thumbImageView = [[UIImageView alloc] init];
    [self addSubview:_thumbImageView];
    // value labels
   
    _labelAboveThumb = [[UILabel alloc] init];
    _labelAboveThumb.backgroundColor = [UIColor clearColor];
    _labelAboveThumb.textAlignment = NSTextAlignmentCenter;
    _labelAboveThumb.font = [UIFont systemFontOfSize:7];
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
    _labelAboveThumb.adjustsFontSizeToFitWidth = YES;
    _labelAboveThumb.textColor = [UIColor whiteColor];
    [self addSubview:_labelAboveThumb];
}
- (void)setValue:(float)value
{
    if (value < _minimumValue || value > _maximumValue) {
        return;
    }
    _value = value;
    
    if (!_directionType) {
        _thumbImageView.center = CGPointMake([self xForValue:value], _thumbImageView.center.y);
    }else{
        _thumbImageView.center = CGPointMake(_thumbImageView.center.x, [self yForValue:value]);
    }
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
    
    [self setNeedsDisplay];
}

- (NSString *)valueStringFormat
{
    return [NSString stringWithFormat:@"%%.%df", _decimalPlaces];
}
- (void)layoutSubviews{
    
    CGFloat thumbHeight ;
    CGFloat thumbWidth ;
    
    if (!_directionType) {
        thumbHeight = 110.f *  _backgroundImageView.bounds.size.height / 64.f;   // thumb height is relative to track height
        thumbWidth = 110.f * thumbHeight / 110.f; // thumb width and height keep the same ratio as the original image size
    }else{
        thumbWidth = 110.f *  _backgroundImageView.bounds.size.width / 64.f;
        thumbHeight = 110.f * thumbWidth / 110.f;
    }
    
    _thumbImageView.frame = CGRectMake(0, 0,thumbWidth,thumbHeight);
    
    if (!_directionType) {
        _thumbImageView.frame = CGRectMake(0, 0,20,20);
        _thumbImageView.center = CGPointMake([self xForValue:_value], CGRectGetMidY(_backgroundImageView.frame));
    }else{
        _thumbImageView.frame = CGRectMake(0, 0,15,15);
        _thumbImageView.center = CGPointMake(CGRectGetMidX(_backgroundImageView.frame), [self yForValue:_value]);
    }
    
    if (!_directionType) {
        _labelAboveThumb.frame = CGRectMake(_thumbImageView.frame.origin.x, _thumbImageView.frame.origin.y - _thumbImageView.frame.size.height , _thumbImageView.frame.size.width, _thumbImageView.frame.size.height);
    }else{
        _labelAboveThumb.frame = CGRectMake(_thumbImageView.frame.origin.x + _thumbImageView.frame.size.width , _thumbImageView.frame.origin.y, _thumbImageView.frame.size.width, _thumbImageView.frame.size.height);
    }
}
- (float)xForValue:(float)value
{
    if (_sortType) {
        return self.frame.size.width * (_maximumValue - value) / (_maximumValue - _minimumValue);
    }else{
        return self.frame.size.width * (value - _minimumValue) / (_maximumValue - _minimumValue);
    }
    
}
- (float)yForValue:(float)value{
    if (_sortType) {
        return self.frame.size.height * (_maximumValue - value) / (_maximumValue - _minimumValue);
    }else{
        return self.frame.size.height * (value - _minimumValue) / (_maximumValue - _minimumValue);
    }
    
}
- (float)valueForX:(float)x
{
    if (_sortType) {
        return _maximumValue - x / self.frame.size.width * (_maximumValue - _minimumValue);
    }else{
        return _minimumValue + x / self.frame.size.width * (_maximumValue - _minimumValue);
    }
}
- (float)valueForY:(float)y{
    if (_sortType) {
        return _maximumValue - y /self.frame.size.height * (_maximumValue - _minimumValue);
    }else{
        return _minimumValue + y /self.frame.size.height * (_maximumValue - _minimumValue);
    }
    
}

- (void)drawRect:(CGRect)rect{
    // _labelOnThumb.center = _thumbImageView.center;
    if (!_directionType) {
        _labelAboveThumb.center = CGPointMake(_thumbImageView.center.x, _thumbImageView.center.y - _labelAboveThumb.frame.size.height);
    }else{
        _labelAboveThumb.center = CGPointMake(_thumbImageView.center.x + _labelAboveThumb.frame.size.width , _thumbImageView.center.y );
    }
}
- (float)stepMarkerXCloseToX:(float)x
{
    float xPercent = MIN(MAX(x / self.frame.size.width, 0), 1);
    float stepPercent = 1.f / 5.f;
    float midStepPercent = stepPercent / 2.f;
    int stepIndex = 0;
    while (xPercent > midStepPercent) {
        stepIndex++;
        midStepPercent += stepPercent;
    }
    return stepPercent * (float)stepIndex * self.frame.size.width;
}
- (float)stepMarkerYCloseToY:(float)y{
    float yPercent = MIN(MAX(y / self.frame.size.height, 0), 1);
    float stepPercent = 1.f / 5.f;
    float midStepPercent = stepPercent / 2.f;
    int stepIndex = 0;
    while (yPercent > midStepPercent) {
        stepIndex ++;
        midStepPercent += stepPercent;
    }
    return stepPercent * (float)stepIndex * self.frame.size.height;
}
#pragma mark - Touch events handling
-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    /*
        CGPoint touchPoint = [touch locationInView:self];
    if(CGRectContainsPoint(_thumbImageView.frame, touchPoint)){
        _thumbOn = YES;
       
    }else {
        _thumbOn = NO;
    }
     */
    _thumbOn = YES;
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_thumbOn) {
        
        if (!_directionType) {
            _value = [self valueForX:_thumbImageView.center.x];
        }else{
            _value = [self valueForY:_thumbImageView.center.y];
        }
       
        NSLog(@"%f %@",_value,NSStringFromCGRect(_thumbImageView.frame));
        
        [self.delegate tellSliderValue:_value];
        
        CGFloat width =  _thumbImageView.frame.size.width;
        CGFloat height = _thumbImageView.frame.size.height;
        CGFloat x = _thumbImageView.frame.origin.x;
        CGFloat y = _thumbImageView.frame.origin.y;
        
        if (_value==1&&(self.directionType==DirectionHorizontal)) {
            
           _thumbImageView.frame =   CGRectMake(0, y, width, height);
        }
        if (_value==255&&(self.directionType==DirectionHorizontal)) {
            
           _thumbImageView.frame =   CGRectMake(x-width/2, y, width, height);
        }
        _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    _thumbOn = YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_thumbOn) return YES;
    
    CGPoint touchPoint = [touch locationInView:self];
    if (!_directionType) {
        
        if (_sortType) {
            _thumbImageView.center = CGPointMake( MIN( MAX( [self xForValue:_maximumValue], touchPoint.x), [self xForValue:_minimumValue]), _thumbImageView.center.y);
        }else{
            _thumbImageView.center = CGPointMake( MIN( MAX( [self xForValue:_minimumValue], touchPoint.x), [self xForValue:_maximumValue]), _thumbImageView.center.y);
        }
        _value = [self valueForX:_thumbImageView.center.x];
    }else{
        
        if (_sortType) {
            _thumbImageView.center = CGPointMake( _thumbImageView.center.x, MIN( MAX( [self yForValue:_maximumValue], touchPoint.y), [self yForValue:_minimumValue]));
        }else{
            _thumbImageView.center = CGPointMake( _thumbImageView.center.x, MIN( MAX( [self yForValue:_minimumValue], touchPoint.y), [self yForValue:_maximumValue]));
        }
        _value = [self valueForY:_thumbImageView.center.y];
    }
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    return YES;
}

@end

