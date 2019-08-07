//
//  JEVideoLocusTimeLapseView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/20.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JEVideoLocusTimeLapseViewDelegate <NSObject>

- (void)takePointPicWithMotionLapse;
- (void)deletePointPicWithMotionLapse:(NSInteger)row;

@end

@interface JEVideoLocusTimeLapseView : UIView

@property (nonatomic, weak) id<JEVideoLocusTimeLapseViewDelegate> delegate;

@property (nonatomic, strong) NSArray       *pointPicArray;
@property (nonatomic, strong) UITableView   *getPointTableView;         //延时关键点图片
@property (nonatomic, assign) NSInteger     deviceSpeed;                //云台速度
@property (nonatomic, assign) NSInteger     timeScale;                  //快门时间间隔

@end

NS_ASSUME_NONNULL_END
