//
//  SR360CamSettingView.m
//  SiRuiIOT
//
//  Created by sirui on 2017/5/25.
//
//

#import "SR360CamFilterView.h"
#import "OneAxiFilterCell.h"
#import "IFImageFilter.h"
#import "IFRiseFilter.h"
#import "IFSutroFilter.h"
#import "IFHudsonFilter.h"
#import "IFLomofiFilter.h"
#import "IFInkwellFilter.h"
#import "IF1977Filter.h"
#import "IFEarlybirdFilter.h"
#import "IFValenciaFilter.h"
#import "IFSierraFilter.h"
#import "IFBrannanFilter.h"
#import "IFHefeFilter.h"
#import "IFNormalFilter.h"
#import "IFXproIIFilter.h"
#import "IFWaldenFilter.h"
#import "IFNashvilleFilter.h"
#import "IFLordKelvinFilter.h"
#import "IFAmaroFilter.h"
#import "IFToasterFilter.h"
#import "GPUImageExposureFilter.h"

@interface SR360CamFilterView() <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *_filters;
    NSArray *_filterToolName;
    NSArray *_filtersName;
}

@property(nonatomic, strong) NSMutableArray *filters;

@end

@implementation SR360CamFilterView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if(self){
        
        self.userInteractionEnabled = YES;
        
        _filters = [NSMutableArray arrayWithArray:@[
                                                    [GPUImageFilter       new],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null],
                                                    [NSNull      null]
                                                    ]];
        
        _filterToolName = @[@"GPUImageFilter",
                            @"IFToasterFilter",
                            @"IFAmaroFilter",
                            @"IFLordKelvinFilter",
                            @"IFNashvilleFilter",
                            @"IFWaldenFilter",
                            @"IFXproIIFilter",
                            @"IFHefeFilter",
                            @"IFBrannanFilter",
                            @"IFSierraFilter",
                            @"IFValenciaFilter",
                            @"IFEarlybirdFilter",
                            @"IF1977Filter",
                            @"IFInkwellFilter",
                            @"IFLomofiFilter",
                            @"IFHudsonFilter",
                            @"IFSutroFilter",
                            @"IFRiseFilter"
                            ];
        
        _filtersName = @[
                         JELocalizedString(@"Origin",comment: ""),
                         JELocalizedString(@"Toaster",comment: ""),
                         JELocalizedString(@"Amaro",comment: ""),
                         JELocalizedString(@"LordKelvin",comment: ""),
                         JELocalizedString(@"Nashville",comment: ""),
                         JELocalizedString(@"Walden",comment: ""),
                         JELocalizedString(@"XproII",comment: ""),
                         JELocalizedString(@"Hefe",comment: ""),
                         JELocalizedString(@"Brannan",comment: ""),
                         JELocalizedString(@"Sierra",comment: ""),
                         JELocalizedString(@"Valencia",comment: ""),
                         JELocalizedString(@"Earlybird",comment: ""),
                         JELocalizedString(@"1977",comment: ""),
                         JELocalizedString(@"Inkwell",comment: ""),
                         JELocalizedString(@"Lomofi",comment: ""),
                         JELocalizedString(@"Hudson",comment: ""),
                         JELocalizedString(@"Sutro",comment: ""),
                         JELocalizedString(@"Rise",comment: "")
                         ];
        
        self.currentFilter = _filters[0];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(frame.size.height*0.9, frame.size.height*0.9);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        
        _containView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        _containView.collectionViewLayout = layout;
        [_containView registerNib:[UINib nibWithNibName:@"OneAxiFilterCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        _containView.backgroundColor = [UIColor clearColor];
        _containView.delegate = self;
        _containView.dataSource = self;
        [self addSubview:_containView];
        
    }
    
    return self;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filterToolName.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OneAxiFilterCell *cell = (OneAxiFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if(_currentIndex == indexPath.row){
        cell.imgSelect.hidden = NO;
    }else{
        cell.imgSelect.hidden = YES;
    }
    
    cell.cover.image = [UIImage imageNamed:[@"filterimage" stringByAppendingFormat:@"%d.jpg", (int)indexPath.row]];
    cell.lbName.text = _filtersName[indexPath.row];
    cell.transform = [MotionOrientation sharedInstance].affineTransform;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"点击到了第 %ld 个滤镜", (long)indexPath.row);
    _currentIndex = indexPath.row;
//    OneAxiFilterCell *lastcell = (OneAxiFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
//    lastcell.imgSelect.hidden = YES;
//    [lastcell setNeedsDisplay];
    
    [self changeFilterAtIndex:indexPath.row];
    
//    OneAxiFilterCell *currentcell = (OneAxiFilterCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    currentcell.imgSelect.hidden = NO;
}

//改变滤镜 : index为滤镜菜单栏的序号
-(void)changeFilterAtIndex:(NSUInteger)index
{
    NSLog(@"改变为第 %ld 个滤镜", index);
    [_containView reloadData];
    
    self.currentFilter = [self filterAtIndex:index];
    _currentIndex = index;

    [self.delegate process:self.currentFilter];
}

-(GPUImageFilter *)newFilterFromCurrentIndex
{
    GPUImageFilter *filter;
    
    Class c = NSClassFromString(_filterToolName[_currentIndex]);
    filter = [[c alloc]init];
    
    return filter;
}

//返回滤镜 : index为滤镜菜单栏的序号
-(GPUImageFilter *)filterAtIndex:(NSUInteger)index
{
    NSLog(@"返回第 %ld 个滤镜", index);
    GPUImageFilter *filter = _filters[index];
    NSLog(@"filter = %@", filter);
    if([filter isEqual:[NSNull null]]){
        Class c = NSClassFromString(_filterToolName[index]);
        filter = [[c alloc]init];
        [_filters replaceObjectAtIndex:index withObject:filter];
    }

    _currentFilter =  _filters[index];
    return _currentFilter;
}

@end
