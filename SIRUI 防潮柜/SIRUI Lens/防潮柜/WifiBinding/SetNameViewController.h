//
//  SetNameViewController.h
//  Cabinet
//
//  Created by Sorgle on 16/8/29.
//  Copyright © 2016年 Sorgle. All rights reserved.
//


#import "BaseViewController.h"


//@class ScanSuccessJumpVC, SRContact;
//
//@protocol ScanSuccessJumpVCDelegate <NSObject>
//
////@optional
//
//- (void)addViewController:(ScanSuccessJumpVC *)addVc didAddContact:(SRContact *)contact;
//@end


//typedef void (^NameBlocks)(SRContact* contact);
@interface SetNameViewController : BaseViewController
//@property (nonatomic, weak) id<ScanSuccessJumpVCDelegate> delegate;




//@property (nonatomic,copy)NameBlocks parser;
@property (nonatomic, copy) NSString *didStr;

//-(void)backName:(NameBlocks)blocks;
///** 接收扫描的二维码信息 */
@property (nonatomic, copy) NSString *jump_URL;
///** 接收扫描的条形码信息 */


@property (nonatomic, copy) NSString *jump_bar_code;

@end
