//
//  SRTrackingCore.h
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/24.
//  
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface SRTrackingCore : NSObject

@property(nonatomic, assign) CGFloat compressRatio;
@property(nonatomic, assign) CGRect  trackingRect;
@property(nonatomic, assign) int     type;

-(instancetype)initTracker:(CGRect)ocRect imageBuffer:(CMSampleBufferRef)imageBuffer compressRate:(CGFloat)rate type:(int)type;
-(CGRect)track:(CMSampleBufferRef)buffer;
-(void)deleteTracker;
-(CGRect)getTrackingRect;
-(BOOL)isLost;
-(void)initTrackingArea:(CGRect)ocRect imageBuffer:(CMSampleBufferRef)imageBuffer compressRate:(CGFloat)rate;

+(void)drawBufferRectangle:(CMSampleBufferRef)buffer lt:(CGPoint)lt rd:(CGPoint)rd scalar:(UIColor *)color;
+(CGRect)drawBufferRotateRect:(CMSampleBufferRef)buffer rotateRect:(CGRect)rotateRect ratio:(CGFloat)ratio lastRect:(CGRect)lastRect;
@end
