//
//  SRTrackingCore.m
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/24.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/tracking/tracking.hpp>
#import <SRTracker/CMT.h>
#import "SRTrackingCore.h"
#import "ConvertTool.h"
#import "UIImage+OpenCV.h"

#define LOST_COUNT 5

@interface SRTrackingCore()
{
    cmt::SRTrack *cmtTracker;
}
@end

@implementation SRTrackingCore

-(instancetype)initTracker:(CGRect)ocRect imageBuffer:(CMSampleBufferRef)imageBuffer compressRate:(CGFloat)rate type:(int)type
{
    self = [super init];
    
    if(self){
        self.type = type;
        [self newTracker];
        [self initTrackingArea:ocRect imageBuffer:imageBuffer compressRate:rate];
    }
    return self;
}
-(instancetype)init
{
    self = [super init];
    
    if(self){
        
        [self newTracker];
    }
    return self;
}
-(void)newTracker
{
    [self deleteTracker];
    
    cmtTracker = new cmt::SRTrack();
}
-(void)initTrackingArea:(CGRect)ocRect imageBuffer:(CMSampleBufferRef)imageBuffer compressRate:(CGFloat)rate
{
    //NSLog(@"%@",NSStringFromCGRect(ocRect));
    
    _compressRatio = rate;
    
    int format_opencv;
    cv::Mat input = [ConvertTool convertToOpenCV:imageBuffer format:&format_opencv];
    
    cv::Rect rect = cv::Rect(ocRect.origin.x, ocRect.origin.y, ocRect.size.width, abs(ocRect.size.height));
    
    cv::Size dsize = cv::Size(input.cols*_compressRatio, input.rows*_compressRatio);
    Mat image2 = Mat(dsize,format_opencv);
    resize(input, image2, dsize);
    
    cmtTracker->initialize(image2, rect);
}

-(void)dealloc
{
    [self deleteTracker];
}

- (CGRect)getTrackingRect {
    if(self.type == 0){
        if(cmtTracker != NULL){
            cv::RotatedRect rect =  cmtTracker->bb_rot;
            return CGRectMake(rect.center.x, rect.center.y, rect.size.width, rect.size.height);
        }
    }
    return CGRectZero;
}
- (CGRect)track:(CMSampleBufferRef)imageBuffer {
    if(self.type == 0){
       if(cmtTracker == NULL)
       return CGRectZero;
    }
    if(cmtTracker == NULL){
       return CGRectZero;
    }
    int format_opencv;
    
    cv::Mat input = [ConvertTool convertToOpenCV:imageBuffer format:&format_opencv];
    
    cv::Size dsize = cv::Size(input.cols*_compressRatio, input.rows*_compressRatio);
    
    Mat image2 = Mat(dsize,format_opencv);
    
    resize(input, image2, dsize);
    
    cmtTracker->processFrame(image2);
    
    cv::RotatedRect rect =  cmtTracker->bb_rot;
    
    CGRect tr = CGRectMake(rect.center.x, rect.center.y, rect.size.width, rect.size.height);
    
    self.trackingRect = tr;
    
    return self.trackingRect;
}

-(BOOL)isLost
{
    return cmtTracker->tracked == false;
}

-(void)deleteTracker
{
    if(cmtTracker != NULL){
        delete cmtTracker;
        cmtTracker = NULL;
    }
}
+(CGRect)drawBufferRotateRect:(CMSampleBufferRef)buffer rotateRect:(CGRect)rotateRect ratio:(CGFloat)ratio lastRect:(CGRect)lastRect
{
    int cvFormat;
    CGRect retRect;
    
    cv::Mat oriImage = [ConvertTool convertToOpenCV:buffer format:&cvFormat];
    
    cv::Point2f OriCenter = cv::Point2f(rotateRect.origin.x/ratio, rotateRect.origin.y/ratio);
    cv::Size2f OriSize = cv::Size2f(rotateRect.size.width/ratio, rotateRect.size.height/ratio);
    cv::RotatedRect oriRect = cv::RotatedRect(OriCenter, OriSize, 0);
    
    cv::Point2f vertices[4];
    oriRect.points(vertices);
    
    for (int i = 0; i < 4; i++)
    {
        cv::Point2f p = vertices[i];
        p.y = p.y-oriRect.size.height;
        
        circle(oriImage, p, 15, cv::Scalar(0, 0, 0), 5);
        
        
    }
    
    return retRect;
    
}

+(void)drawBufferRectangle:(CMSampleBufferRef)buffer lt:(CGPoint)lt rd:(CGPoint)rd scalar:(UIColor *)color;
{
    int format_opencv;
    
    cv::Mat img = [ConvertTool convertToOpenCV:buffer format:&format_opencv];
    
    cv::Point cvLT = cv::Point(lt.x, lt.y);
    cv::Point cvRD = cv::Point(rd.x, rd.y);
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    cv::Scalar sc = cv::Scalar(255, 255, 255);
    
    [self drawCVRectangle:img lt:cvLT rd:cvRD scalar:sc];
}

+(void)drawCVRectangle:(cv::Mat)img lt:(cv::Point)lt rd:(cv::Point)rd scalar:(cv::Scalar)scalar
{
    rectangle(img, lt, rd, scalar, 1);
    //    circle(img, lt, 15, cv::Scalar(0, 0, 0), 5);
    //    circle(img, rd, 15, cv::Scalar(255, 255, 255), 5);
}


@end

