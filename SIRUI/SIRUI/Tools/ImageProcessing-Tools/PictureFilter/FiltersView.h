//
//  FiltersView.h
//  fineix
//
//  Created by FLYang on 16/3/4.
//  Copyright © 2016年 taihuoniao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBMacro.h"

@interface FiltersView : UIView <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView    *   filtersCollectionView;      //  滤镜菜单
@property (nonatomic, strong) NSArray             *   filters;                    //  滤镜
@property (nonatomic, strong) UIImage *imageFilter;
@property (nonatomic, strong) NSArray *filtersName;

@end
