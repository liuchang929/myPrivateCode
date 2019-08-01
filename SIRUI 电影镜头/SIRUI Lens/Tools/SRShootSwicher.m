//
//  SRShootSwicher.m
//  SiRuiIOT
//
//  Created by SIRUI on 2017/7/19.
//
//

#import "SRShootSwicher.h"
#import "POP.h"

@interface SRShootSwicher()
{
    BOOL videoSelect;
    UIImageView *tone;
    UIImageView *still;
    UIImageView *video;
}
@end

@implementation SRShootSwicher

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
//    [self commonInit:self.frame];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        [self commonInit:frame];
        
    }
    
    return self;
}

-(void)commonInit:(CGRect)frame
{
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
    self.image = [UIImage imageNamed:@"shoot_switch_background"];
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    tone = [[UIImageView  alloc]initWithFrame:CGRectMake(30, 0, 30, 30)];
    tone.contentMode = UIViewContentModeScaleAspectFit;
    tone.userInteractionEnabled = YES;
    tone.image = [UIImage imageNamed:@"shoot_switch_tone"];
    [self addSubview:tone];
    
    still = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    still.userInteractionEnabled = YES;
    still.image = [UIImage imageNamed:@"shoot_switch_still"];
    still.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:still];
    
    video = [[UIImageView alloc]initWithFrame:CGRectMake(35, 5, 20, 20)];
    video.userInteractionEnabled = YES;
    video.contentMode = UIViewContentModeScaleAspectFit;
    
    video.image = [UIImage imageNamed:@"shoot_switch_video_select"];
    
    [self addSubview:video];
    
}

-(void)tap:(id)ges
{
    [self toggle];
}

-(void)toggle
{
    POPBasicAnimation *ani = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    ani.duration = 0.5;
    CGRect toValue;
    videoSelect = !videoSelect;
    
    if(videoSelect){
        still.image = [UIImage imageNamed:@"shoot_switch_still"];
        video.image = [UIImage imageNamed:@"shoot_switch_video_select"];
        
        toValue = CGRectMake(self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
        
    }else{
        still.image = [UIImage imageNamed:@"shoot_switch_still_select"];
        video.image = [UIImage imageNamed:@"shoot_switch_video"];
        
        toValue = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
        
    }
    
    ani.toValue = [NSValue valueWithCGRect:toValue];
    
    [tone pop_addAnimation:ani forKey:@"rect"];
    [self.delegate switchVideo:videoSelect];
    
}

@end
