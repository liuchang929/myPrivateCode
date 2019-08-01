//
//  CVWrapper.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"
#import "SRStitcher.hpp"
#import "UIImage+Rotate.h"
#import "GPUImageGrayBlendFilter.h"
#import "FileUtils.h"

using namespace std;

size_t warpImageSize;
const bool try_use_gpu = false;
const string result_name = "result.jpg";

@implementation CVWrapper

cv::Mat stitch (vector<cv::Mat>& images, int *status, int level, BOOL isVertical)
{
    cv::Mat pano;
    cv::Stitcher stitcher = cv::Stitcher::createDefault(false);
    stitcher.setRegistrationResol(-1);
    stitcher.setSeamEstimationResol(0.2);
    stitcher.setFeaturesFinder(cv::makePtr<cv::detail::SurfFeaturesFinder>());
    stitcher.setFeaturesMatcher(cv::makePtr<cv::detail::BestOf2NearestMatcher>(false, 0.65));
    stitcher.setExposureCompensator(cv::detail::ExposureCompensator::createDefault(0));
    stitcher.setWarper(cv::makePtr<cv::SphericalWarper>());
//    if(level == 2){
//        stitcher.setRegistrationResol(0.8);
//        stitcher.setPanoConfidenceThresh(0.95);
//    }else if(level == 1){
//        stitcher.setRegistrationResol(0.7);
//        stitcher.setPanoConfidenceThresh(0.95);
//    }
    
    *status = stitcher.stitch(images, pano);
    
    if (*status != cv::Stitcher::OK)
    {
        cout << "Can't stitch images, error code = " << int(*status) << endl;
        
    }
    return pano;
}

+ (nullable UIImage*) processWithArray:(NSMutableArray*)imageArray withAngle:(CGFloat)angle quality:(int)quality
{   
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
    }
        UIImage* result;

        vector<cv::Mat> matImages;

        for (id image in imageArray) {
            if ([image isKindOfClass: [UIImage class]]) {
                
                UIImage* rotatedImage = [self fixOriantation:image angle:angle];                
                
                //compress to avoid memory warning
                
                rotatedImage = [self compressedToRatio:rotatedImage ratio:0.3];
                
                cv::Mat matImage = [rotatedImage CVMat3];
                NSLog (@"matImage: %@", rotatedImage);
                matImages.push_back(matImage);
            }
        }
        
        [imageArray removeAllObjects];
        
        int status;
    
            @autoreleasepool {
                
                cv::Mat pano = stitch(matImages, &status, quality, 1);
                if(status != 0){
                    return [UIImage new];
                }
                result = [UIImage imageWithCVMat:pano];
            }
            return result;
}

+ (UIImage *)rotateToImageOrientation:(UIImage *)src orientation:(UIImageOrientation)orientation {
    
    // No-op if the orientation is already correct
    if (src.imageOrientation == UIImageOrientationUp) return src;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (src.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (src.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, src.size.width, src.size.height,
                                             CGImageGetBitsPerComponent(src.CGImage), 0,
                                             CGImageGetColorSpace(src.CGImage),
                                             CGImageGetBitmapInfo(src.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (src.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.height,src.size.width), src.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,src.size.width,src.size.height), src.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


+(UIImage *)fixOriantation:(UIImage *)image angle:(float)angle{
    
    UIImage *img = image;
    
    if(angle > -0.1 && angle < 0.1){
        //up
        img = image;
        
    }else if(3.14<angle && angle<3.15){
        //down
        img = [self rotateToImageOrientation:image orientation:UIImageOrientationDown];
        
    }else if(1.57<angle && angle<1.58){
        //left
        img = [self rotateToImageOrientation:image orientation:UIImageOrientationLeft];
        
    }else if(-1.57>angle && angle>-1.58){
        //right
        img = [self rotateToImageOrientation:image orientation:UIImageOrientationRight];
        
    }
    
    return img;
}

+ (UIImage *)compressedToRatio:(UIImage *)img ratio:(float)ratio {
    CGSize compressedSize;
    compressedSize.width=int(img.size.width*ratio);
    compressedSize.height=int(img.size.height*ratio);
    UIGraphicsBeginImageContext(compressedSize);
    [img drawInRect:CGRectMake(0, 0, compressedSize.width, compressedSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+(UIImage *)imageFromImageRect:(UIImage *)image inRect:(CGRect )rect{
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    //返回剪裁后的图片
    return newImage;
}

#pragma mark - New Method
+(UIImage *)Compose:(NSArray *)imagesName points:(NSArray *)points sizes:(NSArray *)sizes
{
    CGFloat minx, maxx;
    CGFloat miny, maxy;
    CGFloat minW, maxW;
    CGFloat minH, maxH;
    
    NSMutableArray *srotH = [NSMutableArray array];
    
    CGPoint firstPoint = [points[0] CGPointValue];
    minx = maxx = firstPoint.x;
    maxy = miny = firstPoint.y;
    minH = maxW = minW = maxH = 0;
    int lastIndex = 0;
    
    for(int index=0; index<points.count; index++){
        CGPoint mp = [points[index]CGPointValue];
        CGSize size = [sizes[index]CGSizeValue];
        
        [srotH addObject:@(size.height)];
        
        minx = fmin(mp.x, minx);
        maxx = fmax(mp.x, maxx);
        if(maxx == mp.x){
            lastIndex = index;
        }
        
        
        miny = fmin(mp.y, miny);
        maxy = fmax(mp.y, maxy);
        
        minW = fmin(minW, size.width);
        minH = fmin(minH, size.height);
        
        maxW = fmax(maxW, size.width);
        maxH = fmax(maxH, size.height);
    }
    
    
    //suppose its cycline pano
    CGFloat markWidth = maxx-minx+[sizes[lastIndex]CGSizeValue].width;
    CGFloat height = maxH;
    CGFloat width = fmax(markWidth, maxW);

    CGFloat avaH;
    if(srotH.count >2){
        NSComparator finderSort = ^(NSNumber *n1, NSNumber *n2){
            if ([n1 floatValue] > [n2 floatValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }else if ([n1 floatValue] < [n2 floatValue]){
                return (NSComparisonResult)NSOrderedAscending;
            }
            else
                return (NSComparisonResult)NSOrderedSame;
        };
        NSArray *resultArray = [srotH sortedArrayUsingComparator:finderSort];
        NSUInteger avaIndex = (NSUInteger)(resultArray.count/2);
        avaH = [resultArray[avaIndex] floatValue];
    }else{
        avaH = maxH;
    }

    
    [[NSUserDefaults standardUserDefaults] setFloat:width forKey:@"cropWidth"];
    [[NSUserDefaults standardUserDefaults] setFloat:avaH forKey:@"cropHeight"];

    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    
    for(int index=0; index<points.count; index++){
        
        UIImage *img = [UIImage imageWithContentsOfFile:imagesName[index]];
        CGPoint drawPoint = [points[index]CGPointValue];
        CGSize size = [sizes[index]CGSizeValue];
        
        [img drawInRect:CGRectMake(drawPoint.x-minx, drawPoint.y-miny, size.width, size.height)];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}


+(void)Blend:(NSArray *)srcName maskNames:(NSArray *)maskNames
{
    for(int index=0; index<maskNames.count; index++){
        //        [self blend1:srcName mask:maskNames index:index];
        [self blend2:srcName mask:maskNames index:index];
    }
    
}


+(void)blend2:(NSArray *)srcName mask:(NSArray *)maskNames index:(int)index
{
    @autoreleasepool {
        UIImage *overlayImage = [UIImage imageWithContentsOfFile:srcName[index]];
        UIImage *backgroundImage = [UIImage imageWithContentsOfFile:maskNames[index]];
        
        CIImage *moi2 = [CIImage imageWithCGImage:overlayImage.CGImage];
        CIImage *gradimage = [CIImage imageWithCGImage:backgroundImage.CGImage];
        
        CIFilter* blend = [CIFilter filterWithName:@"CIBlendWithMask"];
        [blend setValue:moi2 forKey:@"inputImage"];
        [blend setValue:gradimage forKey:@"inputMaskImage"];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = blend.outputImage;
        
        CGImageRef image = [context createCGImage:outputImage fromRect:outputImage.extent];
        UIImage *blendedImage = [UIImage imageWithCGImage:image];
        CGImageRelease(image);
        NSData *imageData = UIImagePNGRepresentation(blendedImage);
        [imageData writeToFile:[FileUtils blendImagePath:index] atomically:YES];
    }
}

+(void)blend1:(NSArray *)srcName mask:(NSArray *)maskNames index:(int)index
{
    @autoreleasepool {
        GPUImageGrayBlendFilter *gbf = [[GPUImageGrayBlendFilter alloc] init];
        
        UIImage *img1 = [UIImage imageWithContentsOfFile:srcName[index]];
        GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:img1];
        UIImage *img2 = [UIImage imageWithContentsOfFile:maskNames[index]];
        GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:img2];
        
        [pic1 addTarget:gbf];
        [pic2 addTarget:gbf];
        
        [gbf useNextFrameForImageCapture];
        [pic1 processImage];
        [pic2 processImage];
        UIImage *blendedImage = [gbf imageFromCurrentFramebuffer];
        
        NSData *imageData = UIImagePNGRepresentation(blendedImage);
        [imageData writeToFile:[FileUtils blendImagePath:index] atomically:YES];
        
        [gbf endProcessing];
    }
}

+(UIImage *)blendAndCompose
{
    NSArray *conners = [NSKeyedUnarchiver unarchiveObjectWithFile:[FileUtils connersPath]];
    NSArray *sizes = [NSKeyedUnarchiver unarchiveObjectWithFile:[FileUtils sizesPath]];
    NSMutableArray *sources = [NSMutableArray array];
    NSMutableArray *masks   = [NSMutableArray array];
    
    for(int i=0; i<warpImageSize; i++){
        [sources addObject:[FileUtils warpImagePath:i]];
        [masks addObject:[FileUtils maskImagePath:i]];
    }
    
    std::vector<cv::Point> vcorners;
    std::vector<cv::Size> vsizes;
    
    cv::Ptr<cv::detail::Blender> blender = cv::makePtr<cv::detail::MultiBandBlender>();
    
    for(int i=0; i<conners.count; i++){
        CGPoint p = [conners[i] CGPointValue];
        CGSize s = [sizes[i] CGSizeValue];
        
        vcorners.push_back(cv::Point(p.x, p.y));
        vsizes.push_back(cv::Size(s.width, s.height));
    }
    
    blender->prepare(vcorners, vsizes);
    
    for(int i=0; i<warpImageSize; i++){
        UIImage *srcImage = [UIImage imageWithContentsOfFile:[FileUtils warpImagePath:i]];
        UIImage *maskImage = [UIImage imageWithContentsOfFile:[FileUtils maskImagePath:i]];
        
        blender->feed([srcImage CVMat3], [maskImage CVGrayscaleMat], vcorners[i]);
        
    }
    
    cv::Mat output;
    
    cv::Mat result, result_mask;
    blender->blend(result, result_mask);
    
    result.convertTo(result, CV_8UC3);
    
    return [UIImage imageWithCVMat:result];
}


@end
