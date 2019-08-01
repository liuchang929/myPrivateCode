//
//  JEWebManager.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/31.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEWebManager.h"
#import "ServiceOperation.h"
#import "ServiceRequestManager.h"
#import "XMLDictionary.h"

@implementation JEWebManager

+ (void)loadDataCenter:(NSMutableArray *)params methodName:(NSString *)methodName result:(LoadDataCenterResult)dataResult{
    
    ServiceArgs *args = [[ServiceArgs alloc] init];
    
    args.methodName   = methodName;//要调用的webservice方法
    
    args.soapParams   = params;//传递方法参数
    
    ServiceRequestManager *manager = [ServiceRequestManager requestWithArgs:args];
    
    __weak ServiceRequestManager *_manager = manager;
    
    [manager setFinishBlock:^() {
        //请求成功
        NSDictionary *dict = [NSDictionary dictionaryWithXMLString:_manager.responseString];
        
        dataResult(dict, nil);
    }];
    [manager setFailedBlock:^() {
        //请求失败
        dataResult(nil, _manager.error.description);
    }];
    [manager startAsynchronous];
}

@end
