//
//  JEUpdateFirmwareView.m
//  Sight
//
//  Created by fangxue on 2018/10/16.
//  Copyright © 2018年 fangxue. All rights reserved.
//

#import "JEUpdateFirmwareView.h"
#import "Masonry.h"

@interface JEUpdateFirmwareView () <BLEProgressViewDelegate>

@end

@implementation JEUpdateFirmwareView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effeView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effeView.frame = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height);
    [backView addSubview:effeView];
    [self addSubview:backView];
    
    //设置圆角边框
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    
    //标题图标
    self.titleView = [[UIImageView alloc] init];
    self.titleView.image = [UIImage imageNamed:@"view_updateFirmware"];
    [self addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
    //view标题
    self.updateTitle = [[UILabel alloc] init];
    self.updateTitle.text = JELocalizedString(@"Firmware Update", nil);
    self.updateTitle.font = [UIFont systemFontOfSize:18];
    self.updateTitle.textAlignment = NSTextAlignmentCenter;
    [self.updateTitle setTextColor:[UIColor whiteColor]];
    [self addSubview:self.updateTitle];
    [self.updateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    //更新确认键
    self.updateConfirmBtn = [[UIButton alloc] init];
    [self.updateConfirmBtn setTitle:JELocalizedString(@"Update", nil) forState:UIControlStateNormal];
    [self.updateConfirmBtn setTitleColor:kTitleColor forState:UIControlStateNormal];
    self.updateConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.updateConfirmBtn.layer.borderWidth = 1;
    self.updateConfirmBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.updateConfirmBtn.layer.cornerRadius = 20;
    self.updateConfirmBtn.layer.masksToBounds = YES;
    [self.updateConfirmBtn addTarget:self action:@selector(updateConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.updateConfirmBtn];
    [self.updateConfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-5);
        make.right.equalTo(self.mas_right).with.offset(-5);
        make.width.mas_equalTo(self.frame.size.width/2 - 7.5);
        make.height.mas_equalTo(50);
    }];
    
    //更新取消键
    self.updateCancelBtn = [[UIButton alloc] init];
    [self.updateCancelBtn setTitle:JELocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.updateCancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.updateCancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.updateCancelBtn.layer.borderWidth = 1;
    self.updateCancelBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    self.updateCancelBtn.layer.cornerRadius = 20;
    self.updateCancelBtn.layer.masksToBounds = YES;
    [self.updateCancelBtn addTarget:self action:@selector(updateCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.updateCancelBtn];
    [self.updateCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.bottom.equalTo(self.updateConfirmBtn.mas_bottom);
        make.width.mas_equalTo(self.frame.size.width/2 - 7.5);
        make.height.mas_equalTo(50);
    }];
    
    //更新进度条
    self.progressView = [[BLEProgressView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 55, self.frame.size.width - 10, 50)];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    self.progressView.layer.cornerRadius = 15;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.delegate = self;
    [self addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.bottom.equalTo(self.mas_bottom).with.offset(-5);
        make.right.equalTo(self.mas_right).with.offset(-5);
        make.height.mas_equalTo(50);
    }];
    
    //view更新内容
    self.updateTextView = [[UITextView alloc] init];
    self.updateTextView.editable = NO;
    self.updateTextView.backgroundColor = [UIColor clearColor];
    [self.updateTextView setTextColor:[UIColor whiteColor]];
    [self.updateTextView setTintColor:[UIColor whiteColor]];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 8;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.updateTextView.typingAttributes = attributes;
    [self addSubview:self.updateTextView];
    [self.updateTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updateTitle.mas_bottom).with.offset(20);
        make.left.equalTo(self.mas_left).with.offset(15);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.bottom.equalTo(self.updateConfirmBtn.mas_top).with.offset(-15);
    }];
    
    
}

//确认
- (void)updateConfirm:(id)sender {
    
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

//取消
- (void)updateCancel:(id)sender {
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end
