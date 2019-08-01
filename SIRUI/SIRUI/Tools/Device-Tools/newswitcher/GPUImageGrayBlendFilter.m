//
//  GPUImageGrayBlendFilter.m
//  Stitcher
//
//  Created by sirui on 2017/2/20.
//  Copyright © 2017年 sirui. All rights reserved.
//

#import "GPUImageGrayBlendFilter.h"

NSString *const kGPUImageGrayBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     highp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
     
     highp float gray = (overlayer.r + overlayer.g + overlayer.b)/3.0;
     
     if(gray<1.0)
     {
         gray = 0.0;
     }
     
     gl_FragColor = vec4(base.r, base.g, base.b, gray);
 }
 );


@implementation GPUImageGrayBlendFilter


- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageGrayBlendFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
