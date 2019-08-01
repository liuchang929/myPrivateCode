//
//  convert.m
//  opencvTest
//
//  Created by sirui on 16/8/15.
//  Copyright © 2016年 sirui. All rights reserved.
//

#import "ConvertTool.h"

@implementation ConvertTool


#pragma mark - UIImage -> cv:Mat

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

#pragma mark - cv:Mat -> UIImage

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+(cv::Mat)convertToOpenCV:(CMSampleBufferRef)sampleBuffer format:(int *)format_opencv
{
    // convert from Core Media to Core Video
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void* bufferAddress;
    size_t width;
    size_t height;
    size_t bytesPerRow;
    
    OSType format = CVPixelBufferGetPixelFormatType(imageBuffer);
    if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        
        *format_opencv = CV_8UC1;
        
        bufferAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
        height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
        bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        
    } else { // expect kCVPixelFormatType_32BGRA
        
        *format_opencv = CV_8UC4;
        
        bufferAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        width = CVPixelBufferGetWidth(imageBuffer);
        height = CVPixelBufferGetHeight(imageBuffer);
        bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        
    }
    // delegate image processing to the delegate
    cv::Mat image((int)height, (int)width, *format_opencv, bufferAddress, bytesPerRow);
    
    
#ifdef CV_DEBUG
    CGImage* dstImage;
    CGColorSpaceRef colorSpace;
    CGContextRef context;
    
    //     check if matrix data pointer or dimensions were changed by the delegate
    bool iOSimage = false;
    if (height == (size_t)image.rows && width == (size_t)image.cols && *format_opencv == image.type() && bufferAddress == image.data && bytesPerRow == image.step) {
        iOSimage = true;
    }
    
    
    // (create color space, create graphics context, render buffer)
    CGBitmapInfo bitmapInfo;
    
    // basically we decide if it's a grayscale, rgb or rgba image
    if (image.channels() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone;
    } else if (image.channels() == 3) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGImageAlphaNone;
        if (iOSimage) {
            bitmapInfo |= kCGBitmapByteOrder32Little;
        } else {
            bitmapInfo |= kCGBitmapByteOrder32Big;
        }
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGImageAlphaPremultipliedFirst;
        if (iOSimage) {
            bitmapInfo |= kCGBitmapByteOrder32Little;
        } else {
            bitmapInfo |= kCGBitmapByteOrder32Big;
        }
    }
    
    if (iOSimage) {
        context = CGBitmapContextCreate(bufferAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
        dstImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    } else {
        
        NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        
        // Creating CGImage from cv::Mat
        dstImage = CGImageCreate(image.cols,                                 // width
                                 image.rows,                                 // height
                                 8,                                          // bits per component
                                 8 * image.elemSize(),                       // bits per pixel
                                 image.step,                                 // bytesPerRow
                                 colorSpace,                                 // colorspace
                                 bitmapInfo,                                 // bitmap info
                                 provider,                                   // CGDataProviderRef
                                 NULL,                                       // decode
                                 false,                                      // should interpolate
                                 kCGRenderingIntentDefault                   // intent
                                 );
        
        CGDataProviderRelease(provider);
    }
    
    
    // render buffer
    @weakify(self)
    dispatch_sync(dispatch_get_main_queue(), ^{
        @strongify(self)
        self->cvContent.contents = (__bridge id)dstImage;
    });
    
    CGImageRelease(dstImage);
    CGColorSpaceRelease(colorSpace);
#endif
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

+(UIImage *)imageFromUMat:(const cv::UMat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.getMat(CV_8UC4).data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *ret = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

@end
