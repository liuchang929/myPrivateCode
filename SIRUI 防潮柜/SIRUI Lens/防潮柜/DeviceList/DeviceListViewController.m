//
//  DeviceListViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/9.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "DeviceListViewController.h"
#import "GuidingPageViewController.h"
#import "EmptyListView.h"
#import "BindViewController.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "JPUSHService.h"
#import "Macros.h"
#import "SRLocalData.h"
#import "CommonUtils.h"
#import "KeyIMEIArrEntity.h"
#import "SRCabinetInfo.h"
#import "UIView+Sizes.h"
#import "LabeledActivityIndicatorView.h"
#import "SRDeviceUtils.h"

NSString * const kListCellReuseIdentifier = @"cellReuseIdentifier";
@interface DeviceListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong)EmptyListView  *emptyListView;
@property (nonatomic,strong) UIImageView  *backgoundView;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, assign) BOOL          isEmptyView;
@property (nonatomic, assign) BOOL          isHidden;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) LabeledActivityIndicatorView *laiView;
@end
@implementation DeviceListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self setupSubViews];
}

-(void)backMainViewAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}



#pragma mark - 每一次呈现时刷新在线状态和设备名称
-(void)viewDidAppear:(BOOL)animated{
    
    NSMutableArray  * allIds = [SRLocalData readAllData];
    _contacts = [NSMutableArray array];
    if (allIds.count) {
        self.emptyListView.hidden = YES;
        
        _contacts = allIds;
        [self.tableView reloadData];
        [self updateNameAndOnlineWithTip:NO];
        
    }else{
        [_laiView stopRotationWithDone];
        [_laiView setDescription:NSLocalizedString(@"SIRUI-Cabinet", nil) font:nil color:nil];
        
        self.emptyListView.hidden =  NO;
    }
    
}



-(void)setupSubViews{
    
    
    self.backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if (weakSelf.contacts.count==0) {
            [weakSelf showHintMessage:NSLocalizedString(@"No equipment available", nil)];
            [weakSelf.tableView.mj_header endRefreshing];
            return;
        }
        
        
        [weakSelf.laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
        [weakSelf.laiView startRotation];
        [weakSelf updateNameAndOnlineWithTip:YES];//刷新所有名字和状态
        
    }];
    
    
    
    [weakSelf.view addSubview:self.tableView];
    
    
    
    weakSelf.emptyListView = [[EmptyListView alloc]initWithFrame:CGRectZero];
    weakSelf.emptyListView.hidden = YES;
    [weakSelf.self.emptyListView.headIv setImage:[UIImage imageNamed:@"cabinet_icon"]];
    weakSelf.self.emptyListView.tittleLabel.text = NSLocalizedString(@"EmptyList", nil);
    [weakSelf.view addSubview:weakSelf.emptyListView];
    
    
}



#pragma mark - 更新设备名和在线状态
-(void)updateNameAndOnlineWithTip:(BOOL)tip{
    
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    
    //updateName
    __weak typeof(self) weakSelf = self;
    dispatch_group_async(group, q, ^{
        
        dispatch_group_enter(group);//
        
        if (!_contacts.count) {
            return;
        }
       // [self.view setUserInteractionEnabled:NO];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:_contacts forKey:kDidsKey];
        [CommonUtils postJsonWithUrlString:kDeviceNameUrlbyJson parameters:dict success:^(id data) {
            
            
            
            
          //  [self.view setUserInteractionEnabled:YES];
            // [self stopLoading];
            [weakSelf.laiView stopRotationWithDone];
            [weakSelf.laiView setDescription:NSLocalizedString(@"SIRUI-Cabinet", nil) font:nil color:nil];
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            
            
            
            
            
            
            //判断解析出来的data属于字典类型
            if (![data isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            if ([[data valueForKey:@"_code_"] isEqualToString:kCode0]) {
                
                
                NSMutableArray * emptyNames  =[NSMutableArray array];
                
                
                NSDictionary  *dataDic = [data valueForKey:kDataKey];
                NSMutableArray  * allNames =[NSMutableArray array];
                for (NSString  *str in weakSelf.contacts) {
                    if(![str isEqualToString:@"leo_account"])
                    {
                        [allNames addObject:[dataDic valueForKey:str]];
                        
                        if (![[dataDic valueForKey:str] isKindOfClass:[NSString class]]) {
                            [emptyNames addObject:str];
                        }
                    }
                    
                }
                SRLog(@"筛选前的设备名====%@",allNames);
                
               
                
                if (emptyNames.count!=0) {
                   
                    ///发送清除指令
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"2222" object:nil userInfo:nil];
                    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
                    
                    [keyArrEntity saveEmptyArr:emptyNames];
                    
                    
                    
                    
                    
                }
                
                
                
                
                
                //筛选--防止一旦遇到没有经过airkiss连接而扫码的设备，设备名字为空（null），将设备名为空的设备初始化默认值为@“我的思锐防潮柜”
                NSMutableArray  * screeningNames =[NSMutableArray array];
                
                for (id str in allNames) {
                    
                    if (![str isKindOfClass:[NSString class]]) {
                        [screeningNames addObject:NSLocalizedString(@"The connection is canceled", nil)];
                        
                        
                        
                        
                        
                        
                    }else{
                        
                        [screeningNames addObject:str];
                        
                    }
                    
                }
                
                SRLog(@"筛选后的设备名====%@",screeningNames);
                
                if (screeningNames.count){///本地保存设备名称
                    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
                    [keyArrEntity clearNamerArr];
                    [keyArrEntity saveNameArr:screeningNames];
                    SRLog(@"keyArrEntity.nameArr:%@",keyArrEntity.nameArr);
                    [self.tableView reloadData];
                }
                
                
                
                
                
                
                
            }else{///其他返回编码处理
                
                NSString *str = [CommonUtils parserCode_keyMessageWithDic:data];
                
                
                if (!str) {
                    [self showHintMessage:NSLocalizedString(@"Data error", nil)];
                }else{
                    [self showHintMessage:str];
                }
                
            }
            
            
            
            dispatch_group_leave(group);//
            
            
            
        } failure:^(NSError *error) {
            
            SRLog(@"%@",error);
            
           // [self.view setUserInteractionEnabled:YES];
            [weakSelf.laiView stopRotationWithDone];
            [weakSelf.laiView setDescription:NSLocalizedString(@"SIRUI-Cabinet", nil) font:nil color:nil];
            weakSelf.contacts = [NSMutableArray arrayWithCapacity:0];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView reloadData];
            
            dispatch_group_leave(group);//
        }];
        
        
        
    });
    
    
    
    
    
    // updateOnline
    
    dispatch_group_async(group, q, ^{
        
        dispatch_group_enter(group);
        
        if (!_contacts.count) {
            return;
        }
        
        //[self.view setUserInteractionEnabled:NO];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:_contacts forKey:kDidsKey];
        [CommonUtils postJsonWithUrlString:kDeviceonlineUrlbyJson parameters:dict success:^(id data) {
            
          //  [self.view setUserInteractionEnabled:YES];
            // [self stopLoading];
            [weakSelf.laiView stopRotationWithDone];
            [weakSelf.laiView setDescription:NSLocalizedString(@"SIRUI-Cabinet", nil) font:nil color:nil];
            [weakSelf.tableView.mj_header endRefreshing];
            
            if (tip) {
                 [weakSelf showHintMessage:NSLocalizedString(@"Successfully updated!", nil)];
            }
           
            
            
            if (![data isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            
            if ([[data valueForKey:@"_code_"] isEqualToString:kCode0]) {
                
                NSDictionary  *Datadic = [data valueForKey:kDataKey];
                SRLog(@"设备的在线状态%@",Datadic);
                KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
                keyArrEntity.onlineArr = nil;
                for (NSString  *str in weakSelf.contacts) {
                    [keyArrEntity.onlineArr addObject:[Datadic valueForKey:str]];
                }
                
                [weakSelf.tableView reloadData];
                
                
                
            }else{///其他返回编码处理
                
                NSString *str = [CommonUtils parserCode_keyMessageWithDic:data];
                
                if (!str) {
                    [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
                }else{
                    [weakSelf showHintMessage:str];
                }
                
            }
            
            
            
            dispatch_group_leave(group);
            
        } failure:^(NSError *error) {
            
            SRLog(@"%@",error);
            //[self.view setUserInteractionEnabled:YES];
            [weakSelf.laiView stopRotationWithDone];
            [weakSelf.laiView setDescription:NSLocalizedString(@"SIRUI-Cabinet", nil) font:nil color:nil];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView reloadData];
            [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
            
            
            dispatch_group_leave(group);
        }];
        
    });
    
    
    
    
    
    
    
}






-(void)pushVC{
    BindViewController * vc = [[BindViewController alloc]init];
    [self.navigationController pushViewController:vc  animated:YES];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}



#pragma mark - 单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell   *cell;
    cell=[tableView dequeueReusableCellWithIdentifier:kListCellReuseIdentifier];
    
    if(cell==nil){
        
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kListCellReuseIdentifier];
    }else{
        // SRLog(@"重用单元格:%@",cell.textLabel.text);
    }
    
    
    //default name
    cell.textLabel.text=NSLocalizedString(@"Refresh to get the device name", nil);
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    //name
    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
    if (keyArrEntity.nameArr.count ==[SRLocalData readAllData].count) {
        cell.textLabel.text=keyArrEntity.nameArr[indexPath.row];
    }
    
    
    //online
    if (keyArrEntity.onlineArr.count==[SRLocalData readAllData].count) {
        NSString * onlineStr = ([keyArrEntity.onlineArr[indexPath.row] isEqualToString:@"1"])?NSLocalizedString(@"online", nil):NSLocalizedString(@"offline", nil);
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",onlineStr];
        
        
        cell.detailTextLabel.textColor = ([keyArrEntity.onlineArr[indexPath.row] isEqualToString:@"1"])?kColorWhite:[UIColor grayColor];
        cell.textLabel.textColor = ([keyArrEntity.onlineArr[indexPath.row] isEqualToString:@"1"])?kColorWhite:[UIColor grayColor];
        
    }else{
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Unknown state", nil)];
        
    }
    
    
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16]];
    
    
    
    
    
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image= [UIImage imageNamed:@"cabinet_cell_icon"];
    
    //设置附件
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80.f;//64.f;
}







#pragma mark - 选中某个单元格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //SRCabinetInfo保存选定的id
    [[SRCabinetInfo sharedInstance] setDeviceIMEI:_contacts[indexPath.row]];
    
    
    //SRCabinetInfo保存id对应的设备昵称
    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
    if (keyArrEntity.nameArr.count==_contacts.count) {
        
        [[SRCabinetInfo sharedInstance] setDeviceName:keyArrEntity.nameArr[indexPath.row]];
    }
    
    
    
    //进入主界面
    GuidingPageViewController * vc = [[GuidingPageViewController alloc]init];
    
    [self.navigationController pushViewController:vc  animated:YES];
    
    
    
    
}







#pragma mark - tableView编辑删除选项

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 提交的是删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SRLocalData deleteDataByDid:self.contacts[indexPath.row]];
        
        //重新获取所有本地的id，重新上报tag
        NSMutableArray  * keyIMEIArr = [SRLocalData readAllData];
        
        if (keyIMEIArr.count) {
            
            [JPUSHService setTags:[NSSet setWithArray:keyIMEIArr] alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
                
                SRLog(@"iTags=======%@",iTags);
            }];
        }else{//提交空集合覆盖之前的集合，则为不发送tag标签，不做推送
            
            [JPUSHService setTags:[NSSet set] alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
                
                
            }];
            
            
        }
        
        
        
        
        
        //删除本地持久化的名字
        KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
        
        if (keyArrEntity.nameArr.count == _contacts.count) {
            [keyArrEntity removeNameAtIndex:indexPath.row];
        }
        
        
        
        //删除模型数据
        [self.contacts removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}










































//---------view------------

-(void)setupNavView{
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backMainViewAction)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    
    _laiView = [LabeledActivityIndicatorView new];
    self.navigationItem.titleView = _laiView;
    
    [_laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
    [_laiView startRotation];
    
    
    
    
    self.title = NSLocalizedString(@"SIRUI-Cabinet", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:16],
       
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent=YES;
    
    
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nav_add_icon" ofType:@"png"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(pushVC)];
}

-(void)viewDidLayoutSubviews{
    
    self.emptyListView.frame = self.view.bounds;
    self.backgoundView.frame = self.view.bounds;
    self.tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height-64);
    if([SRDeviceUtils isNotchScreen])
    {
        self.tableView.frame = CGRectMake(0, 84, self.view.width, self.view.height-64);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
