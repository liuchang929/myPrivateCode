//
//  JECameraSettingOptionsView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraSettingOptionsView.h"
#import "JECameraSettingTableViewCell.h"

//顶部视图的高度
#define HEAD_HEIGHT 40
//tableview cell 的高度
#define CELL_HEIGHT 45
//cell icon 的高度和宽度
#define CELL_ICON_HEIGHT 30
#define CELL_ICON_TOPLEFT_WIDTH 7.5
#define CELL_ICON_RIGHT_WIDTH 35

@interface JECameraSettingOptionsView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView                    *headView;      //顶部 View
@property (nonatomic, strong) UIView                    *backView;      //背景 View
@property (nonatomic, strong) UIVisualEffectView        *effeView;      //模糊 View
@property (nonatomic, strong) UIButton                  *backBtn;       //返回 Button

@end

@implementation JECameraSettingOptionsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //背景视图
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effeView = [[UIVisualEffectView alloc]initWithEffect:blur];
        _effeView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_backView addSubview:_effeView];
        [self addSubview:_backView];
        
        //顶部视图
        self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, HEAD_HEIGHT)];
        _headView.backgroundColor = [UIColor blackColor];
        _headView.alpha = 0.5;
        self.headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _headView.frame.size.width, _headView.frame.size.height)];
        _headLabel.textColor = [UIColor whiteColor];
        _headLabel.textAlignment = NSTextAlignmentCenter;
        _headLabel.backgroundColor = [UIColor blackColor];
        _headLabel.alpha = 0.5;
        [_headView addSubview:_headLabel];
        self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_ICON_TOPLEFT_WIDTH, CELL_ICON_TOPLEFT_WIDTH, _headView.frame.size.height - CELL_ICON_TOPLEFT_WIDTH * 2, _headView.frame.size.height - CELL_ICON_TOPLEFT_WIDTH * 2)];
        [_backBtn setImage:[UIImage imageNamed:@"icon_cameraSetting_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_backBtn];
        [self addSubview:_headView];
        
        //设置列表
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEAD_HEIGHT, frame.size.width, frame.size.height - HEAD_HEIGHT)];
        _tableView.backgroundColor = [UIColor clearColor];
        [self cellLineMoveLeft];
        _tableView.separatorColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    return self;
}

- (void)resetUISize:(CGSize)size {
    self.backView.frame = CGRectMake(0, 0, size.width, size.height);
    self.effeView.frame = CGRectMake(0, 0, size.width, size.height);
    self.headView.frame = CGRectMake(0, 0, size.width, HEAD_HEIGHT);
    self.headLabel.frame = CGRectMake(0, 0, size.width, HEAD_HEIGHT);
    self.tableView.frame = CGRectMake(0, HEAD_HEIGHT, size.width, size.height - HEAD_HEIGHT);
    [_tableView reloadData];
}

#pragma mark - Action
- (void)backBtnAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(hideOptionsView)]) {
        [self.delegate hideOptionsView];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JECameraSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JECameraSettingTableViewCell ID]];
    if (!cell) {
        cell = [[JECameraSettingTableViewCell alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, CELL_HEIGHT)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.cellName.text = JELocalizedString([_cellArray[indexPath.row] valueForKey:@"option"], nil);
    if ([_cellArray[indexPath.row] valueForKey:@"image"] != nil) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(cell.cellView.frame.size.width - CELL_ICON_HEIGHT - CELL_ICON_RIGHT_WIDTH, CELL_ICON_TOPLEFT_WIDTH, CELL_ICON_HEIGHT, CELL_ICON_HEIGHT)];
        [icon setImage:[UIImage imageNamed:[_cellArray[indexPath.row] valueForKey:@"image"]]];
        [cell.cellView addSubview:icon];
    }
    
    switch (_cameraSettingMode) {
        case auxiliaryLine: {
            if (USER_GET_SaveAuxLines_Integer == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        case flash: {
            if (USER_GET_SaveFlashMode_Integer == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        case resolution: {
            if (USER_GET_SaveVideoResolution_Integer == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_cameraSettingMode) {
        case auxiliaryLine: {
            USER_SET_SaveAuxLines_Integer(indexPath.row);
            if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraAuxLineMode:)]) {
                [self.delegate setCameraAuxLineMode:indexPath.row];
            }
        }
            break;
            
        case flash: {
            USER_SET_SaveFlashMode_Integer(indexPath.row);
            if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraFlashMode:)]) {
                [self.delegate setCameraFlashMode:indexPath.row];
            }
        }
            break;
            
        case resolution: {
            USER_SET_SaveVideoResolution_Integer(indexPath.row);
            if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraVideoResolution:)]) {
                [self.delegate setCameraVideoResolution:indexPath.row];
            }
        }
            break;
            
        default:
            break;
    }
    [tableView reloadData];
}

#pragma mark - Tools
//tableView 分割线左移15个像素
- (void)cellLineMoveLeft {
    //cell分割线向左移动15像素
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

@end
