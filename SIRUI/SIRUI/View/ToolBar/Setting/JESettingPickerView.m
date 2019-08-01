//
//  JESettingPickerView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/18.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JESettingPickerView.h"

@interface JESettingPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation JESettingPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
        [self loadData];
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
        
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor clearColor];
        
        [_pickerView setTransform:transform];
        _pickerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        [self addSubview:_pickerView];
        
    }
    return self;
}

- (void)loadData {
    _array = [[NSMutableArray alloc] init];
    for (int index = 1; 5 * index < 101; index ++) {
        [_array addObject:[NSString stringWithFormat:@"%d",5*index]];
    }
}

#pragma mark - UIPickerViewDataSource && UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _array.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);

    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    itemLabel.text = _array[row];
    itemLabel.textColor = [UIColor whiteColor];
    itemLabel.textAlignment = NSTextAlignmentCenter;
    [itemLabel setTransform:transform];
    
    return itemLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.delegate pickerView:pickerView didSelectRow:row];
}

@end
