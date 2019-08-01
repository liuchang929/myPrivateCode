//
//  SRLocalData.h
//  SR-Cabinet
//
//  Created by sirui on 2017/3/27.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRLocalData : NSObject
/**
 保存一个did,返回yes代表成功保存

 @param did 设备id
 */
+(BOOL)saveDataByDid:(NSString *)did;



/**
 删除一个did
 
 @param did 设备id
 */
+(BOOL)deleteDataByDid:(NSString *)didAccount;


/**
 是否存在did
 
 @param did 设备id
 
 */
+(BOOL)IsExistdataByDid:(NSString *)did;




/**
 读取所有数据
 */
+(NSMutableArray *)readAllData;






@end
