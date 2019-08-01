//
//  convert.h
//  opencvTest
//
//  Created by sirui on 16/8/15.
//  Copyright © 2016年 sirui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#include "opencv2/stitching.hpp"

@interface ConvertTool : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+(cv::Mat)convertToOpenCV:(CMSampleBufferRef)sampleBuffer format:(int *)format_opencv;
+(UIImage *)imageFromUMat:(const cv::UMat&)cvMat;

@end
