//
//  SRGradientbackground.h
//  SiRuiIOT
//
//  Created by SIRUI on 2017/7/19.
//
//

#import <UIKit/UIKit.h>

@interface SRGradientbackground : UIView

@property(nonatomic, assign)  BOOL isTop;

-(id)initWithFrame:(CGRect)frame andTop:(BOOL)top;
-(void)updateBackground:(CGRect)frame;

@end
