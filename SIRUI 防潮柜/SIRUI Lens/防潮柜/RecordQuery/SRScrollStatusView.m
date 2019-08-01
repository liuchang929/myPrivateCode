//
//  SRScrollStatusView.m

//
//  Created by zhenyong on 16/4/30.
//  Copyright © 2016年 com.lnl. All rights reserved.
//

#import "SRScrollStatusView.h"
#import "Macros.h"

@implementation SRScrollStatusView


-(instancetype)initWithFrame:(CGRect)frame andTitleArr:(NSArray *)titleArr;
{
    self = [super initWithFrame:frame];
    [self setStatusViewWithTitle:titleArr];
    return self;
}
-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type
{
    if (type == ScrollTapTypeWithNavigation) {
        self = [super initWithFrame:CGRectMake(0, 64, kMain_Screen_Width, kMain_Screen_Height-64)];
    }
    else if(type == ScrollTapTypeWithNavigationAndTabbar)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kMain_Screen_Width, kMain_Screen_Height-64-49)];
    }
    else if(type == ScrollTapTypeWithNothing)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kMain_Screen_Width, kMain_Screen_Height)];
    }
    [self setStatusViewWithTitle:titleArr];
    return self;
}
-(instancetype)initWithTitleArr:(NSArray *)titleArr andType:(ScrollTapType)type andNormalTabColor:(UIColor *)normalTabColor andSelectTabColor:(UIColor *)selectTabColor
{
    if (type == ScrollTapTypeWithNavigation) {
        self = [super initWithFrame:CGRectMake(0, 64, kMain_Screen_Width, kMain_Screen_Height-64)];
    }
    else if(type == ScrollTapTypeWithNavigationAndTabbar)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kMain_Screen_Width, kMain_Screen_Height-64-49)];
    }
    else if(type == ScrollTapTypeWithNothing)
    {
        self = [super initWithFrame:CGRectMake(0, 0, kMain_Screen_Width, kMain_Screen_Height)];
    }
    curNormalTabColor = normalTabColor;
    curSelectTabColor = selectTabColor;
    [self setStatusViewWithTitle:titleArr];
    return self;

}

-(void)setStatusViewWithTitle:(NSArray *)titleArr
{
    float height = self.frame.size.height;
    self.statusView = [[SRStatusView alloc]initWithFrame:CGRectMake(0, 0, kMain_Screen_Width, 45)];
    self.statusView.delegate = self;
    self.statusView.isScroll = YES;
    if (curNormalTabColor && curSelectTabColor) {
        [self.statusView setUpStatusButtonWithTitlt:titleArr NormalColor:curNormalTabColor SelectedColor:curSelectTabColor LineColor:kColorBlue];
    }
    else
    {
        [self.statusView setUpStatusButtonWithTitlt:titleArr NormalColor:kColorBlue SelectedColor: kColorBlue LineColor:kColorBlue];
    }
    [self addSubview:self.statusView];
    float y = 45;
    UIView *sessionLine = [[UIView alloc]initWithFrame:CGRectMake(0, y, kMain_Screen_Width, 5)];
    sessionLine.backgroundColor = [UIColor clearColor];//DTColor(242, 242, 242, 1);
    [self addSubview:sessionLine];
    y+=5;
    //
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, kMain_Screen_Width, height-y)];
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = NO;
    float mainScrollH = _mainScrollView.frame.size.height;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kMain_Screen_Width*titleArr.count, mainScrollH);
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_mainScrollView];
    _tableArr = [NSMutableArray array];
    for ( int i = 0; i < titleArr.count; i++) {
        UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(kMain_Screen_Width*i, 0, kMain_Screen_Width, mainScrollH)];
        table.tableFooterView = [[UIView alloc]init];
        table.backgroundColor = [UIColor clearColor];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.delegate = self;
        table.dataSource = self;
        table.tag = i+1;
        __weak SRScrollStatusView *weakSelf = self;
        if (i==0) {
            table.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                isrefresh = YES;
                if (_scrollStatusDelegate) {
                    
                    [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:YES];
                    [table.mj_header endRefreshing];
                    isrefresh = NO;
                }
            }];
        }

//        table.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//            isrefresh = YES;
//            if (_scrollStatusDelegate) {
//                isrefresh = YES;
//                [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:NO];
//            }
//            [table.mj_footer endRefreshing];
//            isrefresh = NO;
//        }];
        [_tableArr addObject:table];
        [_mainScrollView addSubview:table];
    }
    //获取当前tableview
    if (_tableArr.count > 0) {
        _curTable = _tableArr[0];
    }
}


-(void)refreshViewWithTag:(int)tag andIsHeader:(BOOL)isHeader
{
    if(isHeader)
    {
        if(tag == 1)
        {
//           / UITableView *table = _scrollTapViw.tableArr[tag -1];
//            [table reloadData];
        }
        //NSLog(@"当前%d个tableview 的头部正在刷新",tag);
    }
    else
    {
        //NSLog(@"当前%d个tableview 的尾部正在刷新",tag);
    }
}


#pragma mark--delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            return  [_scrollStatusDelegate numberOfSectionsInTableView:tableView];
            
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   [_scrollStatusDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            return [_scrollStatusDelegate tableView:tableView numberOfRowsInSection:section];
        }
        
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)] ) {
            
            
            
            
            
            return [_scrollStatusDelegate tableView:tableView viewForHeaderInSection:section];
        }
        
    }
    return nil;

    
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)] ) {
            return [_scrollStatusDelegate tableView:tableView heightForHeaderInSection:section];
        }
        
    }
    return 0.001;
    
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)] ) {
            return [_scrollStatusDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
        }
        
    }
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_scrollStatusDelegate) {
        if ([_scrollStatusDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            return [_scrollStatusDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UITableView class]])
    {
    if (isrefresh == NO) {
        int scrollIndex = scrollView.contentOffset.x/kMain_Screen_Width;
        [_statusView changeTag:scrollIndex];
        _curTable = _tableArr[scrollIndex];
    }
    }
}
- (void)statusViewSelectIndex:(NSInteger)index;
{
    
   [_mainScrollView setContentOffset:CGPointMake(kMain_Screen_Width*index, 0) animated:YES];
    _curTable = _tableArr[index];
}
@end
