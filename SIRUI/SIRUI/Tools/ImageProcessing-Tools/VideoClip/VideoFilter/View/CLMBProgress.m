//
//  CLMBProgress.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/15.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLMBProgress.h"

@implementation CLMBProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.progressHUD = [[MBProgressHUD alloc] initWithView:self];
        self.progressHUD.removeFromSuperViewOnHide = YES;
        self.progressHUD.userInteractionEnabled = NO;
        [self addSubview:self.progressHUD];
        [self.progressHUD show:YES];
    }
    return self;
}

@end
