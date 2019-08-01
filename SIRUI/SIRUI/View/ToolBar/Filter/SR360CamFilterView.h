//
//  SR360CamSettingView.h
//  SiRuiIOT
//
//  Created by sirui on 2017/5/25.
//
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@protocol SR360CamFilterDelegate <NSObject>

@required
- (void)process:(GPUImageFilter *)filter;

@end

@interface SR360CamFilterView : UIView

@property(nonatomic, strong) GPUImageFilter *currentFilter;
@property(nonatomic, weak) id<SR360CamFilterDelegate> delegate;
@property(nonatomic, assign) NSUInteger currentIndex;
@property(nonatomic, strong) UICollectionView *containView;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)changeFilterAtIndex:(NSUInteger)index;
- (GPUImageFilter *)newFilterFromCurrentIndex;

@end
