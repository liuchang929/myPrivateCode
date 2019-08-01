//
//  UIImage+WaterMark.m
//  PictureWatermark
//
//  Created by AD-iOS on 15/8/3.
//  Copyright (c) 2015年 Adinnet. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

- (UIImage*)imageWaterMarkWithImage:(UIImage *)image imageRect:(CGRect)imgRect alpha:(CGFloat)alpha
{
    return [self imageWaterMarkWithString:nil rect:CGRectZero attribute:nil image:image imageRect:imgRect alpha:alpha];
}

- (UIImage*)imageWaterMarkWithImage:(UIImage*)image imagePoint:(CGPoint)imgPoint alpha:(CGFloat)alpha
{
    return [self imageWaterMarkWithString:nil point:CGPointZero attribute:nil image:image imagePoint:imgPoint alpha:alpha];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str rect:(CGRect)strRect attribute:(NSDictionary *)attri
{
    return [self imageWaterMarkWithString:str rect:strRect attribute:attri image:nil imageRect:CGRectZero alpha:0];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str point:(CGPoint)strPoint attribute:(NSDictionary*)attri
{
    return [self imageWaterMarkWithString:str point:strPoint attribute:attri image:nil imagePoint:CGPointZero alpha:0];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str point:(CGPoint)strPoint attribute:(NSDictionary*)attri image:(UIImage*)image imagePoint:(CGPoint)imgPoint alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeNormal alpha:1.0];
    if (image) {
        [image drawAtPoint:imgPoint blendMode:kCGBlendModeNormal alpha:alpha];
    }
    
    if (str) {
        [str drawAtPoint:strPoint withAttributes:attri];
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
    
}
- (UIImage*)imageWaterMarkWithString:(NSString*)str rect:(CGRect)strRect attribute:(NSDictionary *)attri image:(UIImage *)image imageRect:(CGRect)imgRect alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    if (image) {
            [image drawInRect:imgRect blendMode:kCGBlendModeNormal alpha:alpha];
    }
    
    if (str) {
        [str drawInRect:strRect withAttributes:attri];
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 5.0f, 5.0f); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

//切割成井字图
+ (UIImage *)NineLatticeWaterMarkWithImage:(UIImage *)image{
    NSLog(@"切割成井字图");
    CGFloat spaceP = (image.size.height)/3;
    CGFloat lineSpace = 20;
    
    UIImage *image2 = [image imageWaterMarkWithImage:[UIImage imageWithColor:[UIColor whiteColor]] imageRect:CGRectMake(0, spaceP, image.size.width, lineSpace) alpha:1];
    UIImage *image3 = [image2 imageWaterMarkWithImage:[UIImage imageWithColor:[UIColor whiteColor]] imageRect:CGRectMake(0, spaceP*2, image.size.width, lineSpace) alpha:1];
    
    CGFloat spaceH = (image.size.width)/3;
    UIImage *im2 = [image3 imageWaterMarkWithImage:[UIImage imageWithColor:[UIColor whiteColor]] imageRect:CGRectMake(spaceH, 0, lineSpace, image.size.height) alpha:1];
    UIImage *im3 = [im2 imageWaterMarkWithImage:[UIImage imageWithColor:[UIColor whiteColor]] imageRect:CGRectMake(spaceH*2, 0, lineSpace, image.size.height) alpha:1];
    NSLog(@"切割完返回的图 = %@", im3);
    return im3;
}

@end
