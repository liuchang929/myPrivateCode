//
//  JESearchDevicesView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/22.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import "JESearchDevicesView.h"
#import "JEBluetoothManager.h"
#import <Masonry.h>

//顶部视图的高度
#define HEAD_HEIGHT 50

@interface JESearchDevicesView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView                *headView;          //顶部 view
@property (nonatomic, strong) UIView                *backView;          //背景 view
@property (nonatomic, strong) UIVisualEffectView    *effeView;          //模糊 view
@property (nonatomic, strong) UILabel               *headLabel;         //顶部 label

@end

@implementation JESearchDevicesView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    //背景视图
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backView.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effeView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [_backView addSubview:_effeView];
    [self addSubview:_backView];
    
    //顶部视图
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEAD_HEIGHT)];
        _headView.backgroundColor = [UIColor blackColor];
        _headView.alpha = 0.5;
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _headView.frame.size.width, _headView.frame.size.height)];
        _headLabel.text = NSLocalizedString(@"Search device", nil);
        _headLabel.textColor = [UIColor whiteColor];
        _headLabel.textAlignment = NSTextAlignmentCenter;
        _headLabel.backgroundColor = [UIColor clearColor];
        [_headView addSubview:_headLabel];
    [self addSubview:_headView];
    
    //设备列表
    self.deviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEAD_HEIGHT, self.frame.size.width, self.frame.size.height - HEAD_HEIGHT) style:UITableViewStylePlain];
        _deviceTableView.delegate = self;
        _deviceTableView.dataSource = self;
        _deviceTableView.backgroundColor = [UIColor clearColor];
    [self cellLineMoveLeft];
    [self addSubview:_deviceTableView];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"CELLID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    NSLog(@"设备列表数据 : %@", _deviceArray);
    
    cell.textLabel.text = ((CBPeripheral *)[_deviceArray[indexPath.row] valueForKey:@"Peripheral"]).name;
    cell.detailTextLabel.text = [_deviceArray[indexPath.row] valueForKey:@"MacAddress"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选择的是第 %ld 行设备 = %@", indexPath.row, (CBPeripheral *)[_deviceArray[indexPath.row] valueForKey:@"Peripheral"]);
    [self.delegate searchDeviceSelect:(CBPeripheral *)[_deviceArray[indexPath.row] valueForKey:@"Peripheral"]];
}

#pragma mark - Tools
//tableView 分割线左移15个像素
- (void)cellLineMoveLeft {
    
    //cell分割线向左移动15像素
    
    if ([_deviceTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_deviceTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_deviceTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_deviceTableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}




@end
