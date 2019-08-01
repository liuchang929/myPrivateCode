//
//  SRScrollStatusView.h

//
//  Created by zhenyong on 16/4/30.
//  Copyright © 2016年 com.lnl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRStatusView.h"
#import "MJRefresh.h"
typedef NS_ENUM(NSInteger , ScrollTapType)
{
    ScrollTapTypeWithNavigation,  //含有导航栏
    ScrollTapTypeWithNavigationAndTabbar, //含有tarbar
    ScrollTapTypeWithNothing,  //什么都不含有
};
@protocol SRScrollStatusDelegate<UITableViewDelegate,UITableViewDataSource>

-(void)refreshViewWithTag:(int)tag andIsHeader:(BOOL)isHeader;

@end
@interface SRScrollStatusView : UIView<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,SRStatusViewDelegate>
{
    BOOL isrefresh;
    UIColor *curSelectTabColor;
    UIColor *curNormalTabColor;
}
@property (strong , nonatomic) SRStatusView *statusView;
@property (strong , nonatomic) UIScrollView *mainScrollView;
@property (strong , nonatomic) UITableView *curTable;
@property (strong , nonatomic) NSMutableArray *tableArr;
@property (strong , nonatomic) id<SRScrollStatusDelegate> scrollStatusDelegate;




-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type;

-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type andNormalTabColor:(UIColor *)normalTabColor andSelectTabColor:(UIColor *)selectTabColor;

-(instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSArray *)titleArr;
@end
