//
//  CVWrapper.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject

+ (UIImage*) processWithArray:(NSMutableArray*)imageArray withAngle:(CGFloat)angle quality:(int)quality;

+ (UIImage *)imageFromImageRect:(UIImage *)image inRect:(CGRect)rect;

@end
