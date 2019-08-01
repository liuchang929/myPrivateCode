//
//  SRShootSwicher.h
//  SiRuiIOT
//
//  Created by SIRUI on 2017/7/19.
//
//

#import <UIKit/UIKit.h>

@protocol SRShootSwicherPotocol

-(void)switchVideo:(BOOL)video;

@end

@interface SRShootSwicher : UIImageView

@property(nonatomic, weak) id<SRShootSwicherPotocol>delegate;

-(void)commonInit:(CGRect)frame;
-(void)toggle;

@end
