//
//  RecordQueryViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/13.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "RecordQueryViewController.h"
#import "CustomTextField.h"
#import "SRScrollStatusView.h"
#import "SRStatusView.h"
#import "DatePickerViewController.h"
#import "SRTimeInfo.h"
#import "KeyIMEIArrEntity.h"
#import "Macros.h"
#import "SRCabinetInfo.h"
#import "CommonUtils.h"
#import "UIView+Sizes.h"
#import "Macros.h"
#import "JPUSHService.h"
#import "LabeledActivityIndicatorView.h"
#import "SRDeviceUtils.h"


#define NumberOfPages  30
NSString * const kRecordCellReuseIdentifier = @"recordcellReuseIdentifier";
NSString * const kCustomCellReuseIdentifier = @"customCellReuseIdentifier";
@interface RecordQueryViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,SRStatusViewDelegate>
@property (nonatomic,strong) UIImageView  *backgoundView;
@property (strong , nonatomic) SRStatusView *statusView;
@property (strong , nonatomic) UIScrollView *mainScrollView;
@property (strong , nonatomic) UIButton *clickBtn;


//显示总数的label，默认隐藏
@property (strong , nonatomic) UILabel * totalNumberLabel;
@property (strong , nonatomic) UILabel * customNumberLabel;



@property (strong , nonatomic) UITableView *recordTableView;
@property (strong , nonatomic) UITableView *customTableView;
@property (strong , nonatomic) NSMutableArray *tableArr;
@property (strong , nonatomic) NSMutableArray *recordArr;
@property (strong , nonatomic) NSMutableArray *cutsomArr;

@property (strong , nonatomic) NSNumber *recordtotal;//数据总数
@property (strong , nonatomic) NSNumber *cutsomtotal;
@property (nonatomic, strong) LabeledActivityIndicatorView *laiView;
@end

@implementation RecordQueryViewController
{
    BOOL isrefresh;
    int recordFlag;
    int cutsomFlag;
    BOOL  isHidden;//默认yes
}
- (instancetype)initWithRecordQueryStyle:(RecordQueryStyle)style{
   self =  [super init];
     if (self) {
  
        self.style =style;
      }
    return self;
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetAllData];//重置所有时间数据
    [self basicSettings];
    [self setupSubView];
    [self addTapGesture];
    
    
    
    //
    
    
    
    [self reloadRecordData:1];//默认第一次加载数据
    [self.recordTableView.mj_header beginRefreshing];
    
    
    
}

-(void)basicSettings{
    
    //初始化刷新，默认为刷新第一页
    recordFlag = 1;
    cutsomFlag = 1;
    
    if (self.style == kAlarmRecordQuery) {
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        [JPUSHService resetBadge];
        
    }
}



-(void)viewDidDisappear:(BOOL)animated{
    if (self.style == kAlarmRecordQuery) {
       [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        [JPUSHService resetBadge];
        
    }
    
}


-(void)resetAllData{
  [[SRTimeInfo sharedInstance] clearAllInfo];//每一次进来清除所有时间信息
  _cutsomArr = nil;//第一次加载页面的时候自定义的数组置nil
    
  KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
  [keyArrEntity.recordArr removeAllObjects];//第一次加载视图置nil
    
}

-(void)viewDidAppear:(BOOL)animated{
 

    [_laiView stopRotationWithDone];
    [_laiView setDescription:[self getNavTitle] font:nil color:nil];
    
    
    
    
    //keyArrEntity.recordArr保存的是自定义下的日期数据
    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
    if (keyArrEntity.recordArr.count) {
        _cutsomArr = keyArrEntity.recordArr;
        [self.customTableView reloadData];
    }
    
    
    
    //显示记录总数
    if ([[SRTimeInfo sharedInstance].recordtotal intValue]) {
        _customNumberLabel.text = [NSString stringWithFormat:@"%@--%@ (%@)",[SRTimeInfo sharedInstance].startTimeStr,[SRTimeInfo sharedInstance].endTimeStr,[SRTimeInfo sharedInstance].recordtotal];
        _cutsomtotal = [SRTimeInfo sharedInstance].recordtotal;
    }
    
    
    
    
    
    
    
    
}

//懒加载
- (NSMutableArray *)recordArr
{
    if (_recordArr == nil) {
        _recordArr = [NSMutableArray array];
    }
 
    return _recordArr;
}




#pragma mark - 刷新最近的记录
-(void)reloadRecordData:(int)several{//several第几次刷新拿到数据
    //判断查询的类型(警报记录，开门记录，关门记录)
    NSString  *urlStr = @"";//判断查询的类型对应的请求url
    NSString * typeStr = @"";//判断查询的类型是开门记录还是关门记录type

    switch (self.style) {
        case kAlarmRecordQuery:
            urlStr = kAlarmrecodeUrl;
            break;
            
        case kOpenRecordQuery:
            urlStr = kDoorrecodeUrl;
            break;
        case kCloseRecordQuery:
            urlStr = kDoorrecodeUrl;
            break;
        default:
            break;
    }
    
    switch (self.style) {
        case kAlarmRecordQuery:
             typeStr = @"";
            break;
            
        case kOpenRecordQuery:
            typeStr = kClosedoorType;
            break;
        case kCloseRecordQuery:
            typeStr = kOpendoorType;
            break;
        default:
            break;
    }
    
    
    
    
    
    //单例传值
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!didStr.length) {//判断单例是否传入成功
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    
    
    //配置传入参数:did,page,type(type用于判断时开门记录还是关门记录)
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:didStr forKey:kDidKey];
    NSString * severalStr =[NSString stringWithFormat:@"%d",several];
    [dict setObject:severalStr forKey:kPageKey];//默认是page==1
    
    if (typeStr.length) {
        [dict setObject:typeStr forKey:kTypeKey];
    }
    
    
    
    
    
   // [self showLoading];
    //[self.view setUserInteractionEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:urlStr parameters:dict success:^(id data) {
        
        //[self stopLoading];
      //  [self.view setUserInteractionEnabled:YES];
        [weakSelf.laiView stopRotationWithDone];
        [weakSelf.laiView setDescription:[self getNavTitle] font:nil color:nil];
    [weakSelf.recordTableView.mj_header endRefreshing];
    [weakSelf.recordTableView.mj_footer endRefreshing];
    
        isrefresh = NO;
        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {

            
             id jsondic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
            
            
            NSLog(@"jsondic:===========%@",jsondic);
            
            
            id temp =[CommonUtils parserData_key:data];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                recordFlag -= 1;//一旦取不到数据，重新回到返回之前数值
                return ;
            }
            
            weakSelf.recordtotal =[temp valueForKey:@"total"];
            
            weakSelf.totalNumberLabel.text = [NSString stringWithFormat:@"%@:(%d)",NSLocalizedString(@"The total number of records", nil),[[temp valueForKey:@"total"] intValue]];
            
           
            if (weakSelf.recordtotal.intValue ==0) {
                [weakSelf showHintMessage:NSLocalizedString(@"No records", nil)];
                return;
            }
            
            
            
            
            
            if (several==1) {//做刷新时的判断
                [weakSelf.recordArr removeAllObjects];//删除所有记录，重新加载最新的
                
                    [weakSelf showHintMessage:NSLocalizedString(@"Successfully updated!", nil)];
               

                
            }
            
            
            NSArray  *arr =[temp valueForKey:kRowsKey];
            if (arr.count) {
                for (NSDictionary * dic  in arr) {
                    [weakSelf.recordArr addObject:dic];
                }
            }
            
            
            
            
            
//            for (NSDictionary * dic  in (NSMutableArray *)[temp valueForKey:kRowsKey]) {
//                [_recordArr addObject:dic];
//            }
            
            [self.recordTableView reloadData];
            
            
            
            
            
            
            
        }else{///其他返回编码处理
            
            NSString *str = [CommonUtils parserCode_keyMessage:data];
            recordFlag -= 1;//一旦取不到数据，重新回到返回之前数值
            if (!str) {
                [self showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [self showHintMessage:str];
            }
        }
        
    } failure:^(NSError *error) {
       
        recordFlag -= 1;//一旦取不到数据，重新回到返回之前数值
        //[self stopLoading];
       // [self.view setUserInteractionEnabled:YES];
        
        
        [weakSelf.recordTableView.mj_header endRefreshing];
        [weakSelf.recordTableView.mj_footer endRefreshing];
        

        [weakSelf.laiView stopRotationWithDone];
        [weakSelf.laiView setDescription:[self getNavTitle] font:nil color:nil];
        
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];
    
    
}






#pragma mark - 自定义刷新接口
-(void)reloadCutsomData:(int)several{
    
    //several第几次刷新获取数据
    //判断查询的类型(警报记录，开门记录，关门记录)
    NSString  *urlStr = @"";//判断查询的类型对应的请求url
    NSString * typeStr = @"";//判断查询的类型是开门记录还是关门记录type
    
    switch (self.style) {
        case kAlarmRecordQuery:
            urlStr = kAlarmrecodeUrl;
            break;
            
        case kOpenRecordQuery:
            urlStr = kDoorrecodeUrl;
            break;
        case kCloseRecordQuery:
            urlStr = kDoorrecodeUrl;
            break;
        default:
            break;
    }
    
    switch (self.style) {
        case kAlarmRecordQuery:
            typeStr = @"";
            break;
            
        case kOpenRecordQuery:
            typeStr = kClosedoorType;
            break;
        case kCloseRecordQuery:
            typeStr = kOpendoorType;
            break;
        default:
            break;
    }
    
    
    
    
    
    
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!didStr.length) {
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    
    
    
    
    
    NSString *startStr = [SRTimeInfo sharedInstance].startTimeIntervalStr;
    NSString *endStr = [SRTimeInfo sharedInstance].endTimeIntervalStr;
    
    
    if (startStr.length==0||endStr.length==0) {
        [self showHintMessage:NSLocalizedString(@"Access time error", nil)];
        return;
    }
    
    //配置parameters:did,page,type(type用于判断时开门记录还是关门记录)
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:didStr forKey:kDidKey];
    NSString * severalStr =[NSString stringWithFormat:@"%d",several];
    [dict setObject:severalStr forKey:kPageKey];//默认是page==1
    [dict setObject:startStr forKey:kStimeKey];
    [dict setObject:endStr forKey:kEtimeKey];
    if (typeStr.length) {
        [dict setObject:typeStr forKey:kTypeKey];
    }
    
    
    
    
    
    //[self showLoading];
    //[self.view setUserInteractionEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:urlStr parameters:dict success:^(id data) {
        
       // [self stopLoading];
        //[self.view setUserInteractionEnabled:YES];
        isrefresh = NO;
        [weakSelf.customTableView.mj_footer endRefreshing];
        

        
        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
 
            
            
            id temp =[CommonUtils parserData_key:data];//
            
            
            if (![temp isKindOfClass:[NSDictionary class]]) {
                recordFlag -= 1;//一旦取不到数据，重新回到返回之前数值
                return ;
            }
            
            weakSelf.cutsomtotal =[temp valueForKey:@"total"];
            
            if (weakSelf.cutsomtotal.intValue ==0) {
                [weakSelf showHintMessage:NSLocalizedString(@"No records", nil)];
                return;
            }
            
            if (several==1) {//加载的是第一页则移除所有数据重新加载最新的数据
                [_cutsomArr removeAllObjects];
            }
            
            
             NSArray  *arr =[temp valueForKey:kRowsKey];
            if (arr.count) {
                for (NSDictionary * dic  in arr) {
                    [weakSelf.cutsomArr addObject:dic];
                }
            }
            
//            for (NSDictionary * dic  in (NSMutableArray *)[temp valueForKey:kRowsKey]) {
//                [_cutsomArr addObject:dic];
//            }
            
            [self.customTableView reloadData];
            
            
            
            
            
            
            
        }else{///其他返回编码处理
            cutsomFlag -=1;

            NSString *str = [CommonUtils parserCode_keyMessage:data];
            
            if (!str) {
                [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [weakSelf showHintMessage:str];
            }
        }
        
    } failure:^(NSError *error) {
        
        
        cutsomFlag -=1;
    [weakSelf.customTableView.mj_footer endRefreshing];
     //[self.view setUserInteractionEnabled:YES];
       // [self stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];
    

    
    
}

-(void)setupSubView{
    
    _laiView = [LabeledActivityIndicatorView new];
    self.navigationItem.titleView = _laiView;
    
    [_laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
    [_laiView startRotation];
    
    
    
    self.view.backgroundColor = kColorBlack;
    _backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    
     [self setStatusViewWithTitle:@[NSLocalizedString(@"Recent log", nil),NSLocalizedString(@"Custom", nil)]];

}



-(NSString *)getNavTitle{
    
        switch (self.style) {
            case kAlarmRecordQuery:
                return NSLocalizedString(@"AlarmLog", nil);
                break;
    
            case kOpenRecordQuery:
                return NSLocalizedString(@"OpeningLog", nil);
                break;
            case kCloseRecordQuery:
                return  NSLocalizedString(@"ClosingLog", nil);
                break;
            default:
                return @"";
                break;
        }
}


-(void)setStatusViewWithTitle:(NSArray *)titleArr
{
    
    
    
    //隐藏totalNumberLabel和customNumberLabel
    isHidden = YES;
    
    
    float height = self.view.frame.size.height;
    self.statusView = [[SRStatusView alloc]initWithFrame:CGRectMake(0, 64, kMain_Screen_Width, 45)];
    
    if([SRDeviceUtils isNotchScreen])
    {
        self.statusView.frame = CGRectMake(0, 64 + 20, kMain_Screen_Width, 45);
    }
    
    self.statusView.delegate = self;
    self.statusView.isScroll = YES;
    [self.statusView setUpStatusButtonWithTitlt:titleArr NormalColor:kColorGray SelectedColor: kColorBlue LineColor:kColorBlue];
   
    [self.view addSubview:self.statusView];

    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.statusView.bottom, kMain_Screen_Width, height-self.statusView.bottom)];
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = NO;
    float mainScrollH = _mainScrollView.frame.size.height;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kMain_Screen_Width*titleArr.count, mainScrollH);
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_mainScrollView];
    _tableArr = [NSMutableArray array];
    
    
    _totalNumberLabel = [[UILabel alloc]init];
    _totalNumberLabel.frame =CGRectMake(0, 0, self.view.width, isHidden?0:50);
    _totalNumberLabel.text = NSLocalizedString(@"The total number of records: 0", nil);//@"总记录数：0条";
    [_totalNumberLabel setFont:[UIFont systemFontOfSize:14]];
    _totalNumberLabel.textColor = kColorBlue;
    _totalNumberLabel.textAlignment = NSTextAlignmentCenter;
    _totalNumberLabel.hidden = isHidden;
    
    [_mainScrollView addSubview:_totalNumberLabel];
    
    
          _recordTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,isHidden?0:50, kMain_Screen_Width, mainScrollH-(isHidden?0:50))];
    
            _recordTableView.backgroundColor = [UIColor clearColor];
            _recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _recordTableView.delegate = self;
            _recordTableView.dataSource = self;
           _recordTableView.tag = 100;
           [_mainScrollView addSubview:_recordTableView];
    
    
           __weak typeof(self) weakSelf = self;
            _recordTableView.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                
                
                
                    isrefresh = YES;
                  //  if (_scrollStatusDelegate) {
                
                [weakSelf.laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
                [weakSelf.laiView startRotation];
                
                    [weakSelf refreshViewWithTag:100 andIsHeader:YES];
    
                       // [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:YES];
                        //[_recordTableView.mj_header endRefreshing];
                       // isrefresh = NO;
                    //}
                }];
    
    
    
    
            weakSelf.recordTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                    isrefresh = YES;
                
                [weakSelf.laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
                [weakSelf.laiView startRotation];
                    [weakSelf refreshViewWithTag:100 andIsHeader:NO];
                    //if (_scrollStatusDelegate) {
                    // isrefresh = YES;
                    // [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:NO];
                    //}
//                    [_recordTableView.mj_footer endRefreshing];
                    isrefresh = NO;
                }];
    
    
    

    
    
    _clickBtn = [[UIButton alloc]init];
    _clickBtn.frame =CGRectMake(kMain_Screen_Width, 0, self.view.width, 50);
    //_clickBtn.backgroundColor = kColorInchworm;
    [_clickBtn setTitle:NSLocalizedString(@"Click to select the query time period", nil) forState:UIControlStateNormal];
    _clickBtn.titleLabel.numberOfLines = 2;
    [_clickBtn setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [_clickBtn setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    
    [_clickBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    //        exitBtn.layer.borderWidth = 1.f;
    //        exitBtn.layer.borderColor = kColorBlue.CGColor;
    //        exitBtn.layer.cornerRadius = 15.0f;
    [_mainScrollView addSubview:_clickBtn];
    
    
    
    
    _customNumberLabel = [[UILabel alloc]init];
    _customNumberLabel.frame =CGRectMake(kMain_Screen_Width, 50, self.view.width, isHidden?0:20);
    _customNumberLabel.text = @"";//@"该时间端记录数：0条";
    
    _customNumberLabel.textColor = kColorBlue;
    [_customNumberLabel setFont:[UIFont systemFontOfSize:14]];
    _customNumberLabel.textAlignment = NSTextAlignmentCenter;
    _customNumberLabel.hidden = isHidden;
    [_mainScrollView addSubview:_customNumberLabel];

    
    
    
    
    _customTableView = [[UITableView alloc]initWithFrame:CGRectMake(kMain_Screen_Width,50+(isHidden?0:20), kMain_Screen_Width, mainScrollH-50-((isHidden?0:20)))];
    
    _customTableView.backgroundColor = [UIColor clearColor];
    _customTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
      _customTableView.tableFooterView = [[UIView alloc]init];
    _customTableView.delegate = self;
    _customTableView.dataSource = self;
    _customTableView.tag = 200;
    [_mainScrollView addSubview:_customTableView];
    
    _customTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        isrefresh = YES;
        [weakSelf refreshViewWithTag:200 andIsHeader:NO];
        //if (_scrollStatusDelegate) {
        // isrefresh = YES;
        // [weakSelf.scrollStatusDelegate refreshViewWithTag:i+1 andIsHeader:NO];
        //}
        //[_customTableView.mj_footer endRefreshing];
        isrefresh = NO;
    }];


    
    
}





-(void)refreshViewWithTag:(int)tag andIsHeader:(BOOL)isHeader
{
    
    
    if(isHeader)//头部刷新
    {
        if(tag == 100)
        {
            
            [self.recordTableView reloadData];
            [self reloadRecordData:1];//头部刷新，默认都是第一次刷新数据，拿到最新的数据
        }
       
    }
    else//尾部刷新
    {
        
       
        if (tag == 100) {
            recordFlag++;
           
            
            //一旦recordFlag次数大于可以容纳的页数，则代表下一页无数据，不再刷新数据
            if (recordFlag > (([_recordtotal intValue])/NumberOfPages)+1) {
                
                
                [_laiView stopRotationWithDone];
                [_laiView setDescription:[self getNavTitle] font:nil color:nil];
                [_recordTableView.mj_footer endRefreshing];
                [self showHintMessage:NSLocalizedString(@"There is no record", nil)];
                return;
            }
            
            
            [self reloadRecordData:recordFlag];
        }
        

        
        
        if (tag == 200) {
            cutsomFlag++;
            
            //一旦cutsomFlag次数大于可以容纳的页数，则代表下一页无数据，不再刷新数据
            if (cutsomFlag > (([_cutsomtotal intValue])/NumberOfPages)+1) {
                
                [_laiView stopRotationWithDone];
                [_laiView setDescription:[self getNavTitle] font:nil color:nil];
                [_customTableView.mj_footer endRefreshing];
                [self showHintMessage:NSLocalizedString(@"There is no record", nil)];
                return;
            }
            [self reloadCutsomData:cutsomFlag];
        }
        
        
        
        
        
    }
}



#pragma mark--delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView.tag ==100) {
        return self.recordArr.count;
    }
    if (tableView.tag ==200) {
        return self.cutsomArr.count;
    }
    
    return 0;
    
}





#pragma mark - 单元格数据源
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell   *cell;

    
    
    //最近记录的tableViewCell
    if (tableView.tag == 100) {
        cell=[tableView dequeueReusableCellWithIdentifier:kRecordCellReuseIdentifier];
        
        if(cell==nil){
            
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRecordCellReuseIdentifier];
        }else{
            // SRLog(@"重用单元格:%@",cell.textLabel.text);
        }

        
        if (_recordArr.count) {
            
            
            
            //显示时间
            NSDictionary *temp = [_recordArr objectAtIndex:indexPath.row];
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[temp valueForKey:kTimes] integerValue]/1000];
            NSString *timeStr  = [CommonUtils stringForNSDate:date];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",timeStr];
            
            
            
            
            
            
            
            //显示记录类型
            NSString  *detailTextStr  =  [NSString string];
            switch (self.style) {
                case kAlarmRecordQuery:
                    if ([[temp valueForKey:kTypeKey] isKindOfClass:[NSNumber class]]) {
                       int  flagType = [[temp valueForKey:kTypeKey] intValue];
                        switch (flagType) {
                            case 1:
                                detailTextStr = NSLocalizedString(@"Error password alarm", nil);
                                break;
                            case 2:
                                detailTextStr = NSLocalizedString(@"The device is moved by the alarm", nil);
                                break;
                            case 3:
                                detailTextStr = NSLocalizedString(@"Vibration alarm", nil);
                                break;
                                
                            default:
                                break;
                        }
                        
                        
                        
                    }else{
                        detailTextStr = NSLocalizedString(@"The alarm time of the device", nil);
                    }
                    
                    
                    break;
                    
                case kOpenRecordQuery:
                    detailTextStr = NSLocalizedString(@"The moment to open the door", nil);
                    break;
                case kCloseRecordQuery:
                    detailTextStr = NSLocalizedString(@"The moment of closing the door", nil);
                    break;
                default:
                    break;
            }
            
            
             cell.detailTextLabel.text = detailTextStr;
           
            cell.detailTextLabel.textColor = [UIColor yellowColor];
            cell.textLabel.textColor = kColorWhite;
            cell.backgroundColor = [UIColor clearColor];
            cell.imageView.image= [UIImage imageNamed:@"cabinet_cell_icon"];
            
        }
    }
    
    
    
    
    //自定义的tableViewCell
    if (tableView.tag == 200) {

        cell=[tableView dequeueReusableCellWithIdentifier:kCustomCellReuseIdentifier];
        
        if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCustomCellReuseIdentifier];
        }else{
            // SRLog(@"重用单元格:%@",cell.textLabel.text);
        }
        
        
        if (_cutsomArr.count) {

            
        //显示时间
        NSDictionary *temp = [_cutsomArr objectAtIndex:indexPath.row];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[temp valueForKey:kTimes] integerValue]/1000];
        NSString *timeStr  = [CommonUtils stringForNSDate:date];
        cell.textLabel.text = timeStr;
            
            
            
            
        
            
        //显示记录的类型
        NSString  *detailTextStr  =  [NSString string];
        
        switch (self.style) {
                case kAlarmRecordQuery:
                    if ([[temp valueForKey:kTypeKey] isKindOfClass:[NSNumber class]]) {
                        int  flag = [[temp valueForKey:kTypeKey] intValue];
                        switch (flag) {
                            case 1:
                                detailTextStr = NSLocalizedString(@"Error password alarm", nil);
                                break;
                            case 2:
                                detailTextStr = NSLocalizedString(@"The device is moved by the alarm", nil);
                                break;
                            case 3:
                                detailTextStr = NSLocalizedString(@"Vibration alarm", nil);
                                break;
                                
                            default:
                                break;
                        }
                        
                        
                        
                    }else{
                        detailTextStr = NSLocalizedString(@"The alarm time of the device", nil);
                    }
                    
                    
                    break;
                    
                case kOpenRecordQuery:
                    detailTextStr = NSLocalizedString(@"The moment to open the door", nil);
                    break;
                case kCloseRecordQuery:
                    detailTextStr = NSLocalizedString(@"The moment of closing the door", nil);
                    break;
                default:
                    break;
            }
            
            
            cell.detailTextLabel.text = detailTextStr;
            
            cell.detailTextLabel.textColor = [UIColor yellowColor];
            cell.textLabel.textColor = kColorWhite;
            cell.backgroundColor = [UIColor clearColor];
            cell.imageView.image= [UIImage imageNamed:@"cabinet_cell_icon"];
            
        }
        
       
    }
 
    


    return cell;
}

#pragma mark - 选择时间段查询
-(void)clickAction{
    
   
    DatePickerViewController *vc =[[DatePickerViewController alloc]init];
    
    
    switch (self.style) {
        case kAlarmRecordQuery:
            //vc.type = 0;
            [vc saveType:0];
            break;
            
        case kOpenRecordQuery:
            [vc saveType:1];
            break;
        case kCloseRecordQuery:
            [vc saveType:2];
            break;
        default:
            break;
    }
    
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}






-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return 55;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    }
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
    
    if(![scrollView isKindOfClass:[UITableView class]])
    {
        if (isrefresh == NO) {
            int scrollIndex = scrollView.contentOffset.x/kMain_Screen_Width;
            [_statusView changeTag:scrollIndex];
           // _curTable = _tableArr[scrollIndex];
            if (scrollIndex) {
              
                
               
            }
        }
    }
}



#pragma mark - SRStatusView delegate
- (void)statusViewSelectIndex:(NSInteger)index;
{
    
    [_mainScrollView setContentOffset:CGPointMake(kMain_Screen_Width*index, 0) animated:YES];
    //_curTable = _tableArr[index];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgoundView.frame = self.view.bounds;

 }



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
