//
//  SRLocalData.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/27.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "SRLocalData.h"
//#import "SRContact.h"
#import "SSKeychain.h"



NSString * const KEY_SERVER = @"com.sirui.SR-Cabinet";

@implementation SRLocalData
+(BOOL)saveDataByDid:(NSString *)did{
   
    
    //判断本地是否存在，指定 serviceName 和 account，不存在则保存
    if (![SSKeychain passwordForService:KEY_SERVER account:did]) {//查看本地是否存储指定 serviceName 和 account 的密码
        
        
      BOOL result=  [SSKeychain setPassword:did forService:KEY_SERVER account:did];
        
        //打印密码信息
        NSString *retrieveuuid = [SSKeychain passwordForService:KEY_SERVER account:did];
      //  NSLog(@"SSKeychain存储显示: 未安装过:%@", retrieveuuid);
        
        return result;
    }
//    }else{
//        
//        //曾经安装过 则直接能打印出密码信息(即使删除了程序 再次安装也会打印密码信息) 区别于 NSUSerDefault
//        NSString *retrieveuuid = [SSKeychain passwordForService:KEY_SERVER account:didAccount];
//        NSLog(@"SSKeychain存储显示 :已安装过:%@", retrieveuuid);
//        
//        
//        
//    }
    

    
    return NO;
       
}



+(BOOL)deleteDataByDid:(NSString *)didAccount{
    
    
    //NSString * didAccount = [NSString stringWithFormat:@"account_%@",did];
    
    
    
    
    
    // NSString *passWord = @"123456";
    if ([SSKeychain passwordForService:KEY_SERVER account:didAccount]) {//查看本地是否存储指定 serviceName 和 account 的密码
        
        
        //[SSKeychain setPassword:did forService:KEY_SERVER account:didAccount];
      BOOL result =  [SSKeychain deletePasswordForService:KEY_SERVER account:didAccount];
        //打印密码信息
        NSString *retrieveuuid = [SSKeychain passwordForService:KEY_SERVER account:didAccount];
        //NSLog(@"SSKeychain存储显示: 未安装过:%@", retrieveuuid);
        return result;
         
         }
         
    return NO;

    //return NO;有两种情况，一种是删除失败，一种是找不到有这个key删除不了
    
}



+(BOOL)IsExistdataByDid:(NSString *)did{
    
    NSString *retrievedid= [SSKeychain passwordForService:KEY_SERVER account:did];
    
    if (retrievedid.length>1) {
        return YES;
    }
    
    
    return NO;
    
    
}





/**
 <#Description#>

 @return <#return value description#>
 */
+(NSMutableArray *)readAllData{
    
    NSArray  *arr = [SSKeychain allAccounts];
    NSMutableArray  *allData = [NSMutableArray array];
    for (NSDictionary *dic  in arr) {
        if(![[dic valueForKey:@"acct"] isEqualToString:@"leo_account"])
        {
            [allData addObject:[dic valueForKey:@"acct"]];
        }
    }
    
    
    //NSLog(@"AllData=====%@",allData);
    return allData;
    
}



@end
