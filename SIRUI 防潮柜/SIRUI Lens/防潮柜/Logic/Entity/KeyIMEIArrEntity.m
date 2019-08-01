//
//  KeyIMEIArrEntity.m
//  SmartTripod
//
//  Created by sirui on 16/11/19.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "KeyIMEIArrEntity.h"
#import "SynthesizeSingleton.h"


NSString * const kDeviceNameArr = @"device_nameArr";
NSString * const kDeviceOnlineArr = @"device_onlineArr";
NSString * const kDeviceRecordArr = @"device_recordArr";


NSString * const kDeviceNameArrKey = @"device_alarmArrKey";
NSString * const kDeviceEmptyArrKey = @"device_emptyArrKey";
@implementation KeyIMEIArrEntity
SYNTHESIZE_SINGLETON_ARC(KeyIMEIArrEntity);

- (instancetype)init {
    self = [super init];
    if (self) {
        
        
        
        
    }
    return self;
}



- (NSArray *)nameArr
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _nameArr =  [userDefaults objectForKey:kDeviceNameArrKey];
    
    if (_nameArr == nil) {
        
        _nameArr = [NSMutableArray array];
    }
    return _nameArr;
}


- (void)saveNameArr:(NSMutableArray *)nameMutableArr{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSArray * temp =[nameMutableArr copy];
    if (nameMutableArr.count > 0) {
        [userDefaults setObject:temp forKey:kDeviceNameArrKey];
    }
    else {
        [userDefaults removeObjectForKey:kDeviceNameArrKey];
        
    }
    
}





- (NSArray *)emptyArr
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _emptyArr =  [userDefaults objectForKey:kDeviceEmptyArrKey];
    
    if (_emptyArr == nil) {
        
        _emptyArr = [NSMutableArray array];
    }
    return _emptyArr;
}


- (void)saveEmptyArr:(NSMutableArray *)emptyMutableArr{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSArray * temp =[emptyMutableArr copy];
    if (emptyMutableArr.count > 0) {
        [userDefaults setObject:temp forKey:kDeviceEmptyArrKey];
    }
    else {
        [userDefaults removeObjectForKey:kDeviceEmptyArrKey];
        
    }
    
}





-(void)clearNamerArr{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kDeviceNameArrKey];
    _nameArr = nil;
}

-(void)clearEmptyArr{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kDeviceEmptyArrKey];
    _emptyArr = nil;
    
    
}



-(void)removeNameAtIndex:(NSUInteger)index{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * arr =  [userDefaults objectForKey:kDeviceNameArrKey];
    
    
    NSMutableArray *temp =[NSMutableArray arrayWithArray:arr];
    if (temp.count>index) {
        [temp removeObjectAtIndex:index];
        [self saveNameArr:temp];
     }
   
    

    
    
    
    
}




- (NSMutableArray *)onlineArr
{
    if (_onlineArr == nil) {
        
        _onlineArr = [NSMutableArray array];
        //[self saveArr:self.nameArr forKey:kDeviceNameArr];
    }
    return _onlineArr;
}



- (NSMutableArray *)recordArr
{
    if (_recordArr == nil) {
        
        _recordArr = [NSMutableArray array];
    }
    return _recordArr;
}





//- (void)setNameArr:(NSMutableArray *)nameArr{
//    self.nameArr = nameArr;
//    
//    [self saveArr:nameArr forKey:kAlarmRecordArr];
//    
//}






#pragma mark - Setters
//这个方法不是你直接调用的，只是用了作为内部方法写在其他方法里面调用的方法
- (void)saveArr:(NSMutableArray *)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (value.count > 0) {
        [userDefaults setObject:value forKey:key];
    }
    else {
        [userDefaults removeObjectForKey:key];
    }
}


@end
