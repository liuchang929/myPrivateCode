//
//  JEAuxLinesView.h
//  Sight
//
//  Created by fangxue on 2018/12/13.
//  Copyright © 2018年 fangxue. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum auxLinesMode {
    Square,
    SquareDiagonal,
    CenterPoint
}AuxLinesMode;

@interface JEAuxLinesView : UIView

@property (nonatomic, assign) AuxLinesMode auxLinesMode;

- (void)drawViewWithMode:(AuxLinesMode)mode;

@end

NS_ASSUME_NONNULL_END
