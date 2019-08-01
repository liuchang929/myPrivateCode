//
//  SRTimelapseRecordTool.h
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/31.
//

#import <Foundation/Foundation.h>
#import "SRCamerModel.h"

@protocol SRTimelapseProtocol
-(void)timelapseCaptureFinish;
-(void)timelapseSaveFinish:(NSError *)error;
@end

@interface SRTimelapseRecordTool : NSObject

@property(nonatomic, strong) SRCamerModel *camModel;
@property(nonatomic, assign) CGSize        size;
@property(nonatomic, strong) GPUImageFilter *filter;
@property(nonatomic, assign) id<SRTimelapseProtocol>delegate;

- (void)takeVideowithDuration:(NSInteger) durationTime andInterval:(double) intervalTime;
- (instancetype)initWithModel:(SRCamerModel *)model size:(CGSize)size;
- (void) stopMakeTimelapseVideo;
- (void) timelapseTakePicture:(BOOL) needStop;
@end
