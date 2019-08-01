//
//  KeyIMEIArrEntity.h
//  SmartTripod
//
//  Created by sirui on 16/11/19.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyIMEIArrEntity : NSObject

@property (nonatomic,strong)NSArray *nameArr;
@property (nonatomic,strong)NSMutableArray *onlineArr;
@property (nonatomic,strong)NSMutableArray *recordArr;
@property (nonatomic,strong)NSMutableArray *alarmArr;
@property (nonatomic,strong)NSMutableArray *emptyArr;
+ (KeyIMEIArrEntity *)sharedInstance;

-(void)saveNameArr:(NSMutableArray *)nameMutableArr;

- (void)saveEmptyArr:(NSMutableArray *)emptyMutableArr;

-(void)clearNamerArr;
-(void)clearEmptyArr;
-(void)removeNameAtIndex:(NSUInteger)index;
@end
