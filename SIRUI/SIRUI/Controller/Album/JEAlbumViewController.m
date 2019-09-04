//
//  JEAlbumViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/23.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEAlbumViewController.h"
#import "JEAlbumCollectionViewCell.h"
#import "JECameraManager.h"
#import "JEPhotoBrowserViewController.h"
#import "JEAlbumCollectionViewHeader.h"

@interface JEAlbumViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    AVPlayer *_avPlayer;
    UIImageView *nullBackView;
}

@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@property (nonatomic, strong) UIView            *topView;                   //顶部视图
@property (nonatomic, strong) UIView            *segmentView;               //选择页面视图
@property (nonatomic, strong) UIView            *contentView;               //内容视图
@property (nonatomic, strong) UISegmentedControl *segmentControl;           //分段选择器
@property (nonatomic, strong) UICollectionView  *collectionView;            //相片视图
@property (nonatomic, strong) NSArray           *albumPhotoArray;           //相片数组
@property (nonatomic, strong) NSArray           *albumVideoPreArray;        //相册内视频数组
@property (nonatomic, strong) NSMutableArray    *btnSelectedStateArray;     //按钮被选择状态数组
@property (nonatomic, strong) UIButton          *editButton;                //选择按钮
@property (nonatomic, strong) UIButton          *deleteButton;              //删除按钮

@property (nonatomic, strong) NSMutableArray    *selectedArray;             //多选数组

@property (nonatomic, assign) BOOL      isEnterSelecting;     //是否进入选择

@end

@implementation JEAlbumViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_segmentControl.selectedSegmentIndex == 0) {
        self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Photo];
    }
    else {
        self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Video];
        self.albumVideoPreArray = [[JECameraManager shareCAMSingleton] getAlbumArray:VideoPre];
    }
    [_btnSelectedStateArray removeAllObjects];
    for (int index = 0; index < _albumPhotoArray.count; index ++) {
        [_btnSelectedStateArray addObject:@"0"];
    }
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] init];
    _btnSelectedStateArray = [[NSMutableArray alloc] init];
    
    [self setupUI];
}

- (void)setupUI {
    //顶部视图
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SAFE_AREA_TOP_HEIGHT)];
        _topView.backgroundColor = MAIN_TABBAR_COLOR;
    [self.view addSubview:_topView];
    //内容视图
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SAFE_AREA_TOP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - SAFE_AREA_TOP_HEIGHT)];
        _contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    [self.view addSubview:_contentView];
    
    //标题 label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SAFE_AREA_TOP_HEIGHT - 50, self.view.frame.size.width, 50)];
    titleLabel.text = JELocalizedString(@"Media Library", nil);
    titleLabel.textColor = MAIN_TEXT_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:titleLabel];
    
    //返回 button
    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SAFE_AREA_TOP_HEIGHT - 40, 40, 40)];
    [exitBtn setImage:[UIImage imageNamed:@"icon_cameraSetting_back"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    exitBtn.alpha = 0.8;
    [self.topView addSubview:exitBtn];
    
    //数据来源
    self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Photo];
    
    //如果数据为空，则放图提示
    if (_albumPhotoArray.count == 0) {
        if (!nullBackView) {
            nullBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_album_null"]];
            nullBackView.frame = CGRectMake(0, 0, 200, 200);
            nullBackView.contentMode = UIViewContentModeScaleAspectFill;
            nullBackView.backgroundColor = [UIColor clearColor];
            nullBackView.center = CGPointMake(_contentView.center.x, _contentView.center.y - 100);
            [self.contentView addSubview:nullBackView];
        }
    }
    else {
        if (nullBackView) {
            [nullBackView removeFromSuperview];
            nullBackView = nil;
        }
    }
    
    //选择视图
    self.segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    _segmentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    NSArray *segmentArray = @[JELocalizedString(@"Photos", nil), JELocalizedString(@"Videos", nil)];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
    _segmentControl.frame = CGRectMake(0, 0, self.view.frame.size.width/3, 30);
    _segmentControl.center = _segmentView.center;
    _segmentControl.selectedSegmentIndex = 0;
    _segmentControl.tintColor = MAIN_TEXT_COLOR;
    [_segmentControl addTarget:self action:@selector(segmentTouchActionWithSender:) forControlEvents:UIControlEventValueChanged];
    [_segmentView addSubview:_segmentControl];
    [self.contentView addSubview:_segmentView];
    
    //编辑按钮
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, 0, 60, 40)];
        [_editButton setTitle:JELocalizedString(@"Select", nil) forState:UIControlStateNormal];
        [_editButton setTitle:JELocalizedString(@"Cancel", nil) forState:UIControlStateSelected];
        [_editButton addTarget:self action:@selector(editBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editButton setTitleColor:MAIN_BLUE_COLOR forState:UIControlStateNormal];
        _editButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_editButton];
    
    //删除按钮
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 110, 0, 50, 40)];
        [_deleteButton setImage:[UIImage imageNamed:@"icon_album_delect"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
        _deleteButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_deleteButton];
    
    //内容视图
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(self.view.frame.size.width/3, self.view.frame.size.width/3);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 50);//头视图大小
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _segmentView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _topView.frame.size.height - _segmentView.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[JEAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"albumCell"];
        _collectionView.delegate   = self;
        _collectionView.dataSource = self;
    
        [_collectionView registerClass:[JEAlbumCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"albumHeader"];
    
    [self.contentView addSubview:_collectionView];
}

#pragma mark - Action
- (void)exitBtnAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)editBtnAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    self.isEnterSelecting = _editButton.isSelected;
    
    _deleteButton.hidden = !_isEnterSelecting;
    
    [_selectedArray removeAllObjects];
    
    [_btnSelectedStateArray removeAllObjects];
    for (int index = 0; index < _albumPhotoArray.count; index ++) {
        [_btnSelectedStateArray addObject:@"0"];
    }
    
    [_collectionView reloadData];
}

- (void)deleteBtnAction:(UIButton *)sender {
    
    UIAlertController *alertC;
    
    if (_segmentControl.selectedSegmentIndex == 0) {
        alertC = [UIAlertController alertControllerWithTitle:JELocalizedString(@"Information", nil) message:JELocalizedString(@"Confirm to delete all the selected photos?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        
    }
    else if (_segmentControl.selectedSegmentIndex == 1) {
        alertC = [UIAlertController alertControllerWithTitle:JELocalizedString(@"Information", nil) message:JELocalizedString(@"Confirm to delete all the selected videos?", nil) preferredStyle:UIAlertControllerStyleAlert];
    }
    
    [alertC addAction:[UIAlertAction actionWithTitle:JELocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *flashArray = [self sortSelectedArray];
        
        if (_segmentControl.selectedSegmentIndex == 0) {
            //删除照片
            for (int index = 0; index < flashArray.count; index++) {
                NSString *imageName = [_albumPhotoArray[[[flashArray[index] objectForKey:@"Section"] integerValue]] objectForKey:@"Array"][[[flashArray[index] objectForKey:@"Row"] integerValue]];
                
                if ([[JECameraManager shareCAMSingleton] deleteImageWithName:imageName]) {
                    //删除成功
                    SHOW_HUD_DELAY(JELocalizedString(@"Deleted", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                }
                else {
                    SHOW_HUD_DELAY(JELocalizedString(@"Deleting Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                }
            }
            self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Photo];
        }
        else if (_segmentControl.selectedSegmentIndex == 1) {
            //删除视频
            for (int index = 0; index < flashArray.count; index++) {
                NSString *videoName = [_albumPhotoArray[[[flashArray[index] objectForKey:@"Section"] integerValue]] objectForKey:@"Array"][[[flashArray[index] objectForKey:@"Row"] integerValue]];
                
                if ([[JECameraManager shareCAMSingleton] deleteVideoWithName:videoName]) {
                    //删除成功
                    SHOW_HUD_DELAY(JELocalizedString(@"Deleted", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                }
                else {
                    SHOW_HUD_DELAY(JELocalizedString(@"Deleting Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                }
            }
            self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Video];
            self.albumVideoPreArray = [[JECameraManager shareCAMSingleton] getAlbumArray:VideoPre];
        }
    
        [self editBtnAction:_editButton];
    }]];
    
    [alertC addAction:[UIAlertAction actionWithTitle:JELocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

- (void)headerSelectBtnAction:(UIButton *)sender {

    //修改 section 选中状态值，因为复用的关系，如果直接更改 sender 的选择状态会被清除掉
    NSString *select = [NSString stringWithFormat:@"%d", !sender.isSelected];
    [_btnSelectedStateArray replaceObjectAtIndex:(sender.tag - 345) withObject:select];
    
    NSMutableArray *flashArray = [[NSMutableArray alloc] initWithArray:_selectedArray];
    
    if ([_btnSelectedStateArray[sender.tag - 345] integerValue]) {
        //获取一下当前 section 的长度
        NSLog(@"全选");

        for (int index = 0; index < [[_albumPhotoArray[sender.tag - 345] objectForKey:@"Array"] count]; index++) {
            if (_selectedArray.count == 0) {
                NSString *section = [NSString stringWithFormat:@"%ld", sender.tag - 345];
                NSString *row = [NSString stringWithFormat:@"%d", index];
                [flashArray addObject:@{@"Section":section, @"Row":row}];
            }
            else {
                
                BOOL isSame = 0;
                
                for (int inx = 0; inx < _selectedArray.count; inx++) {
                    if (([[_selectedArray[inx] objectForKey:@"Section"] integerValue] == (sender.tag - 345)) && ([[_selectedArray[inx] objectForKey:@"Row"] integerValue] == index)) {
                        //重复
                        isSame = 1;
                    }
                    else {
                        //没重复
                    }
                }
                
                if (!isSame) {
                    NSString *section = [NSString stringWithFormat:@"%ld", sender.tag - 345];
                    NSString *row = [NSString stringWithFormat:@"%d", index];
                    [flashArray addObject:@{@"Section":section, @"Row":row}];
                }
            }
        }
    }
    else {
        NSLog(@"取消");
    
        for (NSInteger index = flashArray.count - 1; index >= 0; index--) {
            if ([[flashArray[index] objectForKey:@"Section"] integerValue] == (sender.tag - 345)) {
                [flashArray removeObjectAtIndex:index];
            }
        }
    }
    
    _selectedArray = flashArray;

    [_collectionView reloadData];
    
}

- (void)segmentTouchActionWithSender:(UISegmentedControl *)sender {
    
    [_selectedArray removeAllObjects];
    
    if (sender.selectedSegmentIndex == 0) {
        self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Photo];
        [_collectionView reloadData];
    }
    else {
        self.albumPhotoArray = [[JECameraManager shareCAMSingleton] getAlbumArray:Video];
        self.albumVideoPreArray = [[JECameraManager shareCAMSingleton] getAlbumArray:VideoPre];
        [_collectionView reloadData];
    }
    
    if (_segmentControl.selectedSegmentIndex == 0) {
        if (_albumPhotoArray.count == 0) {
            if (!nullBackView) {
                nullBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_album_null"]];
                nullBackView.frame = CGRectMake(0, 0, 200, 200);
                nullBackView.contentMode = UIViewContentModeScaleAspectFill;
                nullBackView.backgroundColor = [UIColor clearColor];
                nullBackView.center = CGPointMake(_contentView.center.x, _contentView.center.y - 100);
                [self.contentView addSubview:nullBackView];
            }
        }
        else {
            if (nullBackView) {
                [nullBackView removeFromSuperview];
                nullBackView = nil;
            }
        }
    }
    else if (_segmentControl.selectedSegmentIndex == 1) {
        if (_albumPhotoArray.count == 0) {
            if (!nullBackView) {
                nullBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_album_null"]];
                nullBackView.frame = CGRectMake(0, 0, 200, 200);
                nullBackView.contentMode = UIViewContentModeScaleAspectFill;
                nullBackView.backgroundColor = [UIColor clearColor];
                nullBackView.center = CGPointMake(_contentView.center.x, _contentView.center.y - 100);
                [self.contentView addSubview:nullBackView];
            }
        }
        else {
            if (nullBackView) {
                [nullBackView removeFromSuperview];
                nullBackView = nil;
            }
        }
    }
}

- (AVPlayerViewController *)playerViewController{
    
    if (!_playerViewController) {
        
        _playerViewController = [[AVPlayerViewController alloc]init];
    }
    return _playerViewController;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    JEAlbumCollectionViewHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"albumHeader" forIndexPath:indexPath];
    
    header.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    if (!header.headerLabel) {
        header.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width/2 - 15, 50)];
        
        header.headerLabel.textColor = MAIN_TEXT_COLOR;
        
        [header addSubview:header.headerLabel];
    }
    
    if (_isEnterSelecting) {
        if (!header.selectedBtn) {
            header.selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, 0, 60, 50)];
            [header.selectedBtn setTitleColor:MAIN_BLUE_COLOR forState:UIControlStateNormal];
            [header.selectedBtn addTarget:self action:@selector(headerSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [header addSubview:header.selectedBtn];
        }
        else {
            header.selectedBtn.hidden = NO;
        }
        header.selectedBtn.tag = 345+indexPath.section;
        [header.selectedBtn setTitle:JELocalizedString(@"Select", nil) forState:UIControlStateNormal];
        [header.selectedBtn setTitle:JELocalizedString(@"Cancel", nil) forState:UIControlStateSelected];
        header.selectedBtn.selected = [_btnSelectedStateArray[indexPath.section] integerValue];
    }
    else {
        if (header.selectedBtn) {
            header.selectedBtn.hidden = YES;
        }
    }
    
    header.headerLabel.text = [_albumPhotoArray[indexPath.section] objectForKey:@"Date"];
    
    return header;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _albumPhotoArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([[_albumPhotoArray[section] objectForKey:@"Array"] count] == 0) {
        _editButton.hidden = YES;
    }
    else {
        _editButton.hidden = NO;
    }
    return [[_albumPhotoArray[section] objectForKey:@"Array"] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JEAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[JEAlbumCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/3, self.view.frame.size.width/3)];
    }
    
    cell.occlusionView.hidden = NO;
    cell.selectedBtn.hidden = YES;
    
    if (_segmentControl.selectedSegmentIndex == 0) {
        [cell.photoImageView setImage:[[JECameraManager shareCAMSingleton] getImage:[_albumPhotoArray[indexPath.section] objectForKey:@"Array"][indexPath.row] fromAlbumSandboxMode:Thumbnail] forState:UIControlStateNormal];
        
        cell.videoPlayBtn.hidden = YES;
        
        if (_isEnterSelecting) {
            cell.occlusionView.backgroundColor = [UIColor blackColor];
            
            for (int index = 0; index < _selectedArray.count; index++) {
                if (([[_selectedArray[index] objectForKey:@"Section"] integerValue] == indexPath.section) && ([[_selectedArray[index] objectForKey:@"Row"] integerValue] == indexPath.row)) {
                    cell.selectedBtn.hidden = NO;
                    cell.occlusionView.backgroundColor = [UIColor whiteColor];
                }
            }
        }
        else {
            cell.occlusionView.backgroundColor = [UIColor clearColor];
        }
    }
    else if (_segmentControl.selectedSegmentIndex == 1) {
        NSMutableString *str = [NSMutableString stringWithString:[_albumPhotoArray[indexPath.section] objectForKey:@"Array"][indexPath.row]];
        [str replaceCharactersInRange:NSMakeRange(14, 3) withString:@"png"];
        [cell.photoImageView setImage:[[JECameraManager shareCAMSingleton] getVideoPreviewWithName:str] forState:UIControlStateNormal];
        
        cell.videoPlayBtn.hidden = NO;
        
        if (_isEnterSelecting) {
            cell.occlusionView.backgroundColor = [UIColor blackColor];
            
            for (int index = 0; index < _selectedArray.count; index++) {
                if (([[_selectedArray[index] objectForKey:@"Section"] integerValue] == indexPath.section) && ([[_selectedArray[index] objectForKey:@"Row"] integerValue] == indexPath.row)) {
                    cell.selectedBtn.hidden = NO;
                    cell.occlusionView.backgroundColor = [UIColor whiteColor];
                }
            }
        }
        else {
            cell.occlusionView.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (_isEnterSelecting) {
        
        BOOL isSame = 0;
        int sameIndex = 0;
        
        for (int index = 0; index < _selectedArray.count; index++) {
            if (([[_selectedArray[index] objectForKey:@"Section"] integerValue] == indexPath.section) && ([[_selectedArray[index] objectForKey:@"Row"] integerValue] == indexPath.row)) {
                isSame = 1;
                sameIndex = index;
            }
        }
        
        if (isSame) {
            [_selectedArray removeObjectAtIndex:sameIndex];
        }
        else {
            NSString *section = [NSString stringWithFormat:@"%ld", indexPath.section];
            NSString *row = [NSString stringWithFormat:@"%ld", indexPath.row];
            
            [_selectedArray addObject:@{@"Section":section, @"Row":row}];
        }
        
        [_collectionView reloadData];
    }
    else {
        //点击进入相册浏览器
        if (_segmentControl.selectedSegmentIndex == 0) {
            JEPhotoBrowserViewController *vc = [[JEPhotoBrowserViewController alloc] init];
            vc.photoBrowserDic = _albumPhotoArray[indexPath.section];
            vc.indexPath = indexPath;
            vc.browerMode = pictureBrowser;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
        else if (_segmentControl.selectedSegmentIndex == 1) {
            JEPhotoBrowserViewController *vc = [[JEPhotoBrowserViewController alloc] init];
            vc.photoBrowserDic = _albumPhotoArray[indexPath.section];
            vc.indexPath = indexPath;
            vc.browerMode = videoBrowser;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
    }
}

#pragma mark - Tools
//对数组排序
- (NSArray *)sortSelectedArray {
    /*
     1.先将数组里的按照 section 分组
     2.按照 section 将元素按照 row 排序
     3.对 section 降序放回数组
     */
    
    /*
     1.循环 selected，遍历每一个元素
     2.循环 flash，遍历比较每一个元素，大于比较元素时，将元素插入在其前面，如果 flash 为空则直接放入
     */

    NSMutableArray *flashArray = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < _selectedArray.count; index ++) {
        if (flashArray.count == 0) {
            [flashArray addObject:_selectedArray[index]];
        }
        else {
            for (int index2 = 0; index2 < flashArray.count; index2++) {
                if ([[flashArray[index2] objectForKey:@"Section"]integerValue] == [[_selectedArray[index] objectForKey:@"Section"]integerValue]) {
                    //section相同，比较 row
                    if ([[flashArray[index2] objectForKey:@"Row"]integerValue] < [[_selectedArray[index] objectForKey:@"Row"]integerValue]) {
                        [flashArray insertObject:_selectedArray[index] atIndex:index2];
                        break;
                    }else if ((index2 + 1) == flashArray.count){
                        [flashArray addObject:_selectedArray[index]];
                        break;
                    }
                }
                else if ([[flashArray[index2] objectForKey:@"Section"]integerValue] < [[_selectedArray[index] objectForKey:@"Section"]integerValue]) {
                    //section
                    [flashArray insertObject:_selectedArray[index] atIndex:index2];
                    break;
                }
                else if ((index2 + 1) == flashArray.count) {
                    [flashArray addObject:_selectedArray[index]];
                    break;
                }
            }
        }
    }

    return flashArray;
}

//播放
- (void)playVideo:(NSURL *)assURL{
    //test
    AVAsset *asset = [AVAsset assetWithURL:assURL];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    [self enableAudioTracks:YES inPlayerItem:item];
    
    _avPlayer = [AVPlayer playerWithPlayerItem:item];
    
    _avPlayer.rate = 0.5;
    
    [self.playerViewController supportedInterfaceOrientations];
    
    self.playerViewController.player = _avPlayer;
    
    UIDeviceOrientation orientation = [MotionOrientation sharedInstance].deviceOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIDeviceOrientationLandscapeLeft:
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        default:
            break;
    }
    
    [self presentViewController:self.playerViewController animated:YES completion:^{

    }];

    //开始播放视频
    self.playerViewController.player.rate = 0.5;
    
    [self.playerViewController.player play];
}

//I wrote a function which you can call whenever you want to set the rate for video below 0.5. It enables/disables all audio tracks.
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks)
    {
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
        {
            track.enabled = enable;
        }
    }
}

@end
