//
//  JEAuxLineView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/6/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum auxLineMode {
    Square,             //九宫格
    SquareDiagonal,     //九宫格加对角线
    CenterPoint         //中心点
}AuxLineMode;

@interface JEAuxLineView : UIView

@property (nonatomic, assign) AuxLineMode auxLineMode;  //辅助线模式

@end

NS_ASSUME_NONNULL_END
