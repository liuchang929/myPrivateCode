//
//  JEBluetoothManager.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/22.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import "JEBluetoothManager.h"
#define TIME            10          //数组消失检测的倍数
#define UPDATE_TIMER    1           //更新设备频率
#define SEND_MSG_TIMER  0.1         //发送消息频率

@interface JEBluetoothManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong)           CBService           *service;                       //当前服务
@property (nonatomic, strong)           CBCentralManager    *centralManager;                //蓝牙管理对象
@property (nonatomic, strong)           CBCharacteristic    *inputCharacteristic;           //连接的设备特征（通道）输入
@property (nonatomic, strong)           CBCharacteristic    *outPutcharacteristic;          //连接的设备特征（通道）输出

//@property (nonatomic, strong)           NSTimer             *scanStopTimer;                 //扫描自动连接限制计时器
@property (nonatomic, strong)           NSTimer             *updateTimer;                   //更新设备计时器
@property (nonatomic, strong)           NSTimer             *sendMsgTimer;                  //发送数据计时器

//DATA
@property (nonatomic, assign)           bluetoothToolsState bluetoothState;                 //蓝牙状态
@property (nonatomic, strong, nullable) NSMutableArray      *flashTIME;                     //暂存设备的出现次数
@property (nonatomic, assign)           BOOL                canSendMsg;                     //当前是否可以发送消息

@end

@implementation JEBluetoothManager

//self 使用 jeManager 代替，否则无法监听
static JEBluetoothManager *jeManager = nil;

+ (instancetype)shareBLESingleton{
    
    //每次app开启后只允许循环一次 为了线程安全 否则会有XPC connection invalid错误，此类被释放
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jeManager = [[JEBluetoothManager alloc] init];  //∵无法使用 self，因为还没创建出自己的对象
        
        jeManager.bluetoothState                = Unknown;                              //初始化蓝牙状态
        jeManager.scanMaxTime                   = 7.0f;                                 //初始化蓝牙扫描自动连接时间
        jeManager.scanRange                     = [NSNumber numberWithInt:-60];         //初始化蓝牙扫描范围
        jeManager.deviceBroadcastingNameKeyword = @"kCBAdvDataLocalName";               //初始化蓝牙设备名关键字
        jeManager.deviceBroadcastionDataKeyword = @"kCBAdvDataManufacturerData";        //初始化蓝牙设备信息关键字
        jeManager.serviceUUIDString             = @"FFF0";                              //初始化服务的 UUID
//        jeManager.peripheralName                = @[@"RPXMXP"];                         //初始化蓝牙扫描设备名
        jeManager.canSendMsg                    = YES;                                  //初始化发送消息权限
        
//        jeManager.centralManager = [[CBCentralManager alloc] initWithDelegate:jeManager queue:dispatch_get_main_queue() options:nil];   //初始化管理中心 queue可以设置蓝牙扫描的线程 传入nil则为在主线程中进行 options字典中用于进行一些管理中心的初始化属性设置
        [jeManager initCentralManager];
        //其中使用了dispatch_get_main_queue()主队列，所以使用异步执行，否则会造成死锁
        
    });
    
    return jeManager;
}

//初始化管理中心
- (void)initCentralManager {
    jeManager.centralManager = [[CBCentralManager alloc] initWithDelegate:jeManager queue:dispatch_get_main_queue() options:nil];   //初始化管理中心
}

//获取手机蓝牙当前状态
- (bluetoothToolsState)getBLEState {
    
    if (jeManager.bluetoothState != Connect) {
        [jeManager.centralManager scanForPeripheralsWithServices:nil options:nil];   //通过服务筛选外设，未连接的时候初始化通知中心，重新扫描设备
    }
    
    return jeManager.bluetoothState;
}

//将系统蓝牙状态更新至自定义的蓝牙状态中
- (void)updateBluetoothState:(bluetoothToolsState) bluetoothState {
    jeManager.bluetoothState = bluetoothState;
    
    if (jeManager.delegate && [jeManager.delegate respondsToSelector:@selector(updateBLEState:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统的蓝牙状态 = %lu", (unsigned long)jeManager.bluetoothState);
            [jeManager.delegate updateBLEState:jeManager.bluetoothState];
        });
    }
}

//搜索外设
- (void)scanDevice:(NSArray *)deviceName {
    jeManager.srPeripherals = [[NSMutableArray alloc] init];
    jeManager.srMacPeripherals = [[NSMutableArray alloc] init];
    jeManager.flashTIME = [[NSMutableArray alloc] init];
    
    jeManager.peripheralName = deviceName;
        
    if (!jeManager.centralManager) {
        jeManager.centralManager = [[CBCentralManager alloc] initWithDelegate:jeManager queue:dispatch_get_main_queue() options:nil];
    }
    
    if (jeManager.centralManager.state == CBCentralManagerStatePoweredOn) {
        NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey,nil];  //CBCentralManagerScanOptionAllowDuplicatesKey 需要不断获取最新的信号强度RSSI 默认值为NO，则不会重复扫描已经发现的设备，为YES则会重复扫描
        
        [jeManager.centralManager scanForPeripheralsWithServices:nil options:option];    //option 搜索的条件
        
        [jeManager updateBluetoothState:PoweredOn];
        
        //最长搜索时间
//        jeManager.scanStopTimer = [NSTimer scheduledTimerWithTimeInterval:self.scanMaxTime target:jeManager selector:@selector(autoConnectPeripheral) userInfo:nil repeats:YES];
        
        jeManager.updateTimer = [NSTimer timerWithTimeInterval:UPDATE_TIMER target:jeManager selector:@selector(updateTimerAction) userInfo:nil repeats:YES];
        jeManager.sendMsgTimer = [NSTimer timerWithTimeInterval:SEND_MSG_TIMER target:jeManager selector:@selector(sendMsgTimerAction) userInfo:nil repeats:YES];
        //添加到主循环
//        [[NSRunLoop mainRunLoop] addTimer:jeManager.scanStopTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:jeManager.sendMsgTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop mainRunLoop] addTimer:jeManager.updateTimer forMode:NSDefaultRunLoopMode];
    }
    else {
        [jeManager updateBluetoothState:(int)jeManager.centralManager.state];
    }
}

//连接设备
- (void)connectDeviceWithCBPeripheral:(CBPeripheral *)peripheral {
    [jeManager.centralManager connectPeripheral:peripheral options:nil];
    NSString *flashString = [peripheral.identifier UUIDString];
    NSLog(@"本次连接设备的 uuid 是 : %@", flashString);
    USER_SET_SaveLastDevice_String(flashString);
    
//    if (jeManager.scanStopTimer.isValid) {
//        [jeManager.scanStopTimer invalidate];
//        jeManager.scanStopTimer = nil;
//    }
}

//自动连接
//- (void)autoConnectPeripheral {
//    //当只有一台设备的时候
//    if (jeManager.srPeripherals.count == 1 && jeManager.srMacPeripherals.count == 1) {
//        CBPeripheral *peripheral = jeManager.srPeripherals[0];
//        [self connectDeviceWithCBPeripheral:peripheral];
//    }
//    //多台设备时，搜索一下有没有上一次连接过的设备
//    /*
//    if (jeManager.srPeripherals.count > 1) {
//        for (CBPeripheral *per in jeManager.srPeripherals) {
//            if ([[per.identifier UUIDString] isEqual:USER_GET_SaveLastDevice_String]) {
//                [self connectDeviceWithCBPeripheral:per];
//            }
//        }
//    }
//     */
//}

//停止扫描
- (void)stopScanDevice {
    
//    if (jeManager.scanStopTimer.isValid) {
//        [_scanStopTimer invalidate];
//        _scanStopTimer = nil;
//    }
    
    if (jeManager.centralManager) {
        [_centralManager stopScan];
    }
    
    if (jeManager.updateTimer.isValid) {
        [jeManager.updateTimer invalidate];
        jeManager.updateTimer = nil;
    }
    
    [jeManager.flashTIME removeAllObjects];
    [jeManager.srPeripherals removeAllObjects];
    [jeManager.srMacPeripherals removeAllObjects];
}

//重新扫描
- (void)reScanDevice {
    jeManager.bluetoothState = Unknown;
}

#pragma mark - TimerAction
- (void)updateTimerAction {
    //按时更新设备
    if (jeManager.delegate && [jeManager.delegate respondsToSelector:@selector(updateDevices:Macs:)]) {
        [jeManager.delegate updateDevices:jeManager.srPeripherals Macs:jeManager.srMacPeripherals];
    }
}

- (void)sendMsgTimerAction {
    jeManager.canSendMsg = YES;
}

#pragma mark - CBCentralManagerDelegate
//监听手机蓝牙状态，蓝牙状态改变时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [jeManager updateBluetoothState:(int)central.state];
    
    [self.delegate hintBLEStatus:jeManager.bluetoothState];
    
    if (jeManager.bluetoothState == DisConnect || jeManager.bluetoothState == Fail ||jeManager.bluetoothState == PoweredOn) {
        [self scanDevice:jeManager.peripheralName];
    }
    NSLog(@"蓝牙状态 : %lu", (unsigned long)self.bluetoothState);
}

/*
 *  发现外设时调用
 *
 *  peripheral:外设
 *  advertisementData:外设信息
 *  RSSI:信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    //过滤设定名字的设备
    
    //SR-GB 稳定器
    if ([advertisementData objectForKey:jeManager.deviceBroadcastingNameKeyword]) {
        for (int i = 0 ; i < jeManager.peripheralName.count; i++) {
            if ([[advertisementData objectForKey:jeManager.deviceBroadcastingNameKeyword] isEqualToString:jeManager.peripheralName[i]]) {
                //获取设备信息和广播信息 - 暂时不用
                /*
                if (jeManager.delegate && [jeManager.delegate respondsToSelector:@selector(advertisementPeripheral:Msg:)]) {
                    if ((jeManager.srPeripherals.count == jeManager.srMacPeripherals.count) && (jeManager.srPeripherals.count != 0)) {
                        [jeManager.delegate advertisementPeripheral:peripheral Msg:advertisementData];
                    }
                }
                 */
                //计算 mac 地址
                NSString *str = [[NSString alloc] init];
                if ([[advertisementData objectForKey:jeManager.deviceBroadcastionDataKeyword] isKindOfClass:[NSData class]]) {
                    NSData *intData = [advertisementData objectForKey:jeManager.deviceBroadcastionDataKeyword];
                    Byte *testByte = (Byte *)[intData bytes];
                    str  = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[0]],
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[1]],
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[2]],
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[3]],
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[4]],
                                      [[NSString alloc]initWithFormat:@"%02lx",(long)testByte[5]]
                                      ];
                }
                BOOL isSame = NO;
                //遍历数组 若没有重复的就添加进数组
                for (int i = 0; i < jeManager.srPeripherals.count; i++) {
                    if ([jeManager.srPeripherals[i] isEqual:peripheral]) {
                        //重复 次数归1
                        isSame = YES;
                        [jeManager.flashTIME replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];
                    }
                }
                if (!isSame) {
                    //新设备
                    [jeManager.srPeripherals addObject:peripheral];
                    [jeManager.srMacPeripherals addObject:[str uppercaseString]];
                    [jeManager.flashTIME addObject:[NSNumber numberWithInt:1]];
                }
            }
        }
    }
    
    //检查是否有一直未出现的设备 遍历给数组全员 time++ 当 time 次数达到一定数额，就从数组中移除该设备
    for (int i = 0; i < jeManager.srPeripherals.count; i++) {
        [jeManager.flashTIME replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[jeManager.flashTIME[i] intValue] + 1]];
        if ([jeManager.flashTIME[i] intValue] > (TIME * jeManager.srPeripherals.count)) {
            [jeManager.srPeripherals removeObjectAtIndex:i];
            [jeManager.srMacPeripherals removeObjectAtIndex:i];
            [jeManager.flashTIME removeObjectAtIndex:i];
        }
    }
}

//外设连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    jeManager.peripheral = peripheral;
    
    NSLog(@"连接上了名称为%@的外设",peripheral.name);
    
    [MBProgressHUD showTipMessageInWindow:[NSString stringWithFormat:NSLocalizedString(@"Connect device %@",nil),peripheral.name]];
    
    jeManager.peripheral.delegate = jeManager;
    
    [jeManager.peripheral discoverServices:nil]; //不再搜索外设服务
    
    [self stopScanDevice];
    
    [jeManager updateBluetoothState:Connect];    //连接成功，更改蓝牙状态

}

//外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    [jeManager updateBluetoothState:Fail];   //连接失败，更改蓝牙状态
}

//外设连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    [jeManager updateBluetoothState:DisConnect]; //连接断开，更改蓝牙状态
    [jeManager disconnectDevice];    //断开连接
}

//断开连接
- (void)disconnectDevice {
    if (jeManager.peripheral) {
        [jeManager.centralManager cancelPeripheralConnection:jeManager.peripheral];   //切断 APP 层的蓝牙连接，不一定能切断物理层的蓝牙连接，可通过setNotifyValue:forCharacteristic: 设置第一个参数 为NO来取消订阅（需要实际验证效果）
        
        //清空设备列表
        jeManager.peripheral = nil;
        [jeManager.srPeripherals removeAllObjects];
        [jeManager.srMacPeripherals removeAllObjects];
    }
}

#pragma mark - CBPeripheralDelegate
//发现服务时调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (error) {
        return;
    }
    
    //遍历外设的所有服务
    for (CBService *service in peripheral.services) {
        NSLog(@"外设服务: %@", service);
        //判断外设服务中的 UUID 是不是我所需的 UUID，如果是，则搜索特征
        if ([service.UUID.UUIDString isEqual:jeManager.serviceUUIDString]) {
            jeManager.service = service;
            //每个服务又包含一个或多个特征,搜索服务的特征    此处可放入异步主队列
            dispatch_async(dispatch_get_main_queue(), ^{
                [peripheral discoverCharacteristics:nil forService:jeManager.service];
            });
        }
    }
}

//发现特征时调用，有几个特征就调用几次
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"扫描特征出错:%@", [error localizedDescription]);
        return;
    }

    //获取Characteristic的值
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"服务server:%@ 的特征:%@, 读写属性:%lu", service.UUID.UUIDString, characteristic, (unsigned long)characteristic.properties);
        
        /*
         
         服务server:FFF0 的特征:<CBCharacteristic: 0x283e5c420, UUID = FFF1, properties = 0xC, value = <00000000 00000000 00000000 00000000 00000000>, notifying = NO>, 读写属性:12
         服务server:FFF0 的特征:<CBCharacteristic: 0x283e5c300, UUID = FFF2, properties = 0x12, value = <ff010408 9306771d 76>, notifying = NO>, 读写属性:18
         服务server:FFF0 的特征:<CBCharacteristic: 0x283e5c960, UUID = FFF3, properties = 0x12, value = <01020304 05060708 090a0b0c 0d0e0f10 11121314>, notifying = NO>, 读写属性:18
         
         */
        
        /*
         *  订阅特征，如果 UUID数据固定，一般使用 readValueForCharacteristic ，如果 UUID 数据频繁更换，一般使用 setNotifyValue:forCharacteristic:
         */
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        [peripheral readValueForCharacteristic:characteristic];
        
        //获取数据后，进入代理方法- peripheral: didUpdateValueForCharacteristic: error:
        
        //写
        if ([characteristic.UUID.UUIDString isEqual:kWriteUUID]){
            _outPutcharacteristic = characteristic;
        }
        //读/通知服务
        if ([characteristic.UUID.UUIDString isEqual:kReadUUID1]||[characteristic.UUID.UUIDString isEqual:kReadUUID2]){
            _inputCharacteristic = characteristic;
        }
    }
}

//接受数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    /*
    if (jeManager.delegate && [jeManager.delegate respondsToSelector:@selector(revicedMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [jeManager.delegate revicedMessage:characteristic.value];
     });
    }
     */

    if (jeManager.delegate && [jeManager.delegate respondsToSelector:@selector(commandDidRecieved:)]) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [jeManager.delegate commandDidRecieved:[self convertDataToHexStr:characteristic.value]];
            }
        });
    }
}

//设置通知后调用，监控蓝牙传回来的实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"错误");
        return;
    }
    
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        //获取数据后，进入代理方法
        //- peripheral:didUpdateValueForDescriptor:error:
    }
    else {
        NSLog(@"停止通知");
    }
}
#pragma mark - BluetoothProtocol
/**
 向设备获取固件版本信息
 */
- (void)BPGetDeviceVersion {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x1d;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x1d;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备获取蓝牙版本信息
 */
- (void)BPGetBLEVersion {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x40;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x40;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备获取蓝牙参数数据
 */
- (void)BPGetBLEParameter {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x28;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x28;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备反馈收到了蓝牙参数数据包
 */
- (void)BPGetBLEParameterBag {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x2b;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x2b;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进入固件更新模式
 */
- (void)BPEnterFirmwareUpdate {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x25;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x25;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备发送固件升级的数据包

 @param byteData 第一个数据包
 */
- (void)BPFirmwareUpdateFirstPacket:(Byte *)byteData {
    
    Byte bytes[19];
    bytes[0] = 0xff;
    bytes[1] = 0x35;
    bytes[2] = 16;
    bytes[3] = byteData[0];
    bytes[4] = byteData[1];
    bytes[5] = byteData[2];
    bytes[6] = byteData[3];
    bytes[7] = byteData[4];
    bytes[8] = byteData[5];
    bytes[9] = byteData[6];
    bytes[10] = byteData[7];
    bytes[11] = byteData[8];
    bytes[12] = byteData[9];
    bytes[13] = byteData[10];
    bytes[14] = byteData[11];
    bytes[15] = byteData[12];
    bytes[16] = byteData[13];
    bytes[17] = byteData[14];
    bytes[18] = byteData[15];
    NSData *msg = [NSData dataWithBytes:bytes length:19];
    
    //需要修改为控制发送频率的数据包
    [self sendMsg:msg];
}

/**
 向设备发送固件升级的数据包

 @param byteData 第二个数据包
 */
- (void)BPFirmwareUpdateSecondPacket:(Byte *)byteData {
    
    Byte bytes[19];
    bytes[0] = 0xff;
    bytes[1] = 0x36;
    bytes[2] = 16;
    bytes[3] = byteData[0];
    bytes[4] = byteData[1];
    bytes[5] = byteData[2];
    bytes[6] = byteData[3];
    bytes[7] = byteData[4];
    bytes[8] = byteData[5];
    bytes[9] = byteData[6];
    bytes[10] = byteData[7];
    bytes[11] = byteData[8];
    bytes[12] = byteData[9];
    bytes[13] = byteData[10];
    bytes[14] = byteData[11];
    bytes[15] = byteData[12];
    bytes[16] = byteData[13];
    bytes[17] = byteData[14];
    bytes[18] = byteData[15];
    NSData *msg = [NSData dataWithBytes:bytes length:19];
    
    [self sendMsg:msg];
}

/**
 告知设备退出固件更新模式
 */
- (void)BPQuitFirmwareUpdata {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x24;
    bytes1[2] = 0x00;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x24;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进入人脸跟踪模式
 */
- (void)BPEnterFaceTracking {
    
    Byte bytes1[6];
    bytes1[0] = 0xff;
    bytes1[1] = 0x11;
    bytes1[2] = 3;
    bytes1[3] = 0x01;
    bytes1[4] = 0x01;
    bytes1[5] = 0x01;
    NSData *data = [NSData dataWithBytes:bytes1 length:6];
    
    Byte bytes[8];
    bytes[0] = 0xff;
    bytes[1] = 0x11;
    bytes[2] = 3;
    bytes[3] = 0x01;
    bytes[4] = 0x01;
    bytes[5] = 0x01;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[6] = ck_ab[0];
    bytes[7] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:8];
    
    [self sendMsg:msg];
}

/**
 向设备发送人脸跟踪数据

 @param x 人脸跟踪框中点的横坐标
 @param y 人脸跟踪框中点的纵坐标
 */
- (void)BPFaceMsgX:(int)x Y:(int)y {
    //发送人脸数据
    Byte bytes1[7];
    bytes1[0] = 0xff;
    bytes1[1] = 0x13;
    bytes1[2] = 4;
    bytes1[3]  = (Byte)(y>>8);
    bytes1[4]  = (Byte)(y);
    bytes1[5]  = (Byte)(x>>8);
    bytes1[6]  = (Byte)(x);
    NSData *data = [NSData dataWithBytes:bytes1 length:7];
    
    Byte bytes[9];
    bytes[0] = 0xff;
    bytes[1] = 0x13;
    bytes[2] = 4;
    bytes[3]  = (Byte)(y>>8);
    bytes[4]  = (Byte)(y);
    bytes[5]  = (Byte)(x>>8);
    bytes[6]  = (Byte)(x);
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[7] = ck_ab[0];
    bytes[8] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:9];
    
    //控制人脸跟踪信息的发送频率
    [self sendRestrictiveMsg:msg];
}

/**
 告知设备人脸已丢失
 */
- (void)BPFaceMsgLoss {
    
    Byte bytes1[7];
    bytes1[0] = 0xff;
    bytes1[1] = 0x13;
    bytes1[2] = 4;
    bytes1[3]  = (Byte)(5000>>8);
    bytes1[4]  = (Byte)(5000);
    bytes1[5]  = (Byte)(5000>>8);
    bytes1[6]  = (Byte)(5000);
    NSData *data = [NSData dataWithBytes:bytes1 length:7];
    
    Byte bytes[9];
    bytes[0] = 0xff;
    bytes[1] = 0x13;
    bytes[2] = 4;
    bytes[3]  = (Byte)(5000>>8);
    bytes[4]  = (Byte)(5000);
    bytes[5]  = (Byte)(5000>>8);
    bytes[6]  = (Byte)(5000);
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[7] = ck_ab[0];
    bytes[8] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:9];
    
    [self sendMsg:msg];
}

/**
 告知设备退出人脸跟踪模式
 */
- (void)BPQuitFaceTracking {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x10;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x10;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进入全景模式

 @param angle 全景角度
 */
- (void)BPPanoPhoto:(int)angle {
    if (angle == 90) {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x09;
        bytes1[2] = 1;
        bytes1[3] = 0x01;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x09;
        bytes[2] = 1;
        bytes[3] = 0x01;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        NSLog(@"%@",msg);
        
        [self sendMsg:msg];
    }
    else if (angle == 180) {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x09;
        bytes1[2] = 1;
        bytes1[3] = 0x02;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x09;
        bytes[2] = 1;
        bytes[3] = 0x02;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        [self sendMsg:msg];
    }
    else if (angle == 360) {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x09;
        bytes1[2] = 1;
        bytes1[3] = 0x03;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x09;
        bytes[2] = 1;
        bytes[3] = 0x03;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        [self sendMsg:msg];
    }
    //3x3 全景
    else if (angle == 270) {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x09;
        bytes1[2] = 1;
        bytes1[3] = 0x11;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x09;
        bytes[2] = 1;
        bytes[3] = 0x11;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        [self sendMsg:msg];
    }
}

/**
 向设备发送退出全景指令
 */
- (void)BPQuitPano {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x08;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x08;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备查询设备充电时是否可以开关机的设定状态
 */
- (void)BPCheckChargingState {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x38;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x38;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备修改的设备充电时可否开关机的状态

 @param state 设定的状态
 */
- (void)BPChangeChargingState:(BOOL)state {
    if (state) {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x39;
        bytes1[2] = 1;
        bytes1[3] = 0x01;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x39;
        bytes[2] = 1;
        bytes[3] = 0x01;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        [self sendMsg:msg];
        USER_SET_SaveChargingSwitchState_BOOL(YES);
    }
    else {
        Byte bytes1[4];
        bytes1[0] = 0xff;
        bytes1[1] = 0x39;
        bytes1[2] = 1;
        bytes1[3] = 0x00;
        NSData *data = [NSData dataWithBytes:bytes1 length:4];
        
        Byte bytes[6];
        bytes[0] = 0xff;
        bytes[1] = 0x39;
        bytes[2] = 1;
        bytes[3] = 0x00;
        char ck_ab[2];
        ck_ab[0] = 0;
        ck_ab[1] = 0;
        char *recieved_param = (char *)[data bytes];
        char length = recieved_param[2] + 2;
        for(char i = 0; i<length; i++)
        {
            ck_ab[0] = ck_ab[0] + recieved_param[i+1];
            ck_ab[1] = ck_ab[1] + ck_ab[0];
        }
        bytes[4] = ck_ab[0];
        bytes[5] = ck_ab[1];
        NSData *msg = [NSData dataWithBytes:bytes length:6];
        
        [self sendMsg:msg];
        USER_SET_SaveChargingSwitchState_BOOL(NO);
    }
    NSLog(@"改变后设备充电状态是 : %d", USER_GET_SaveChargingSwitchState_BOOL);
}

/**
 向设备获取俯仰轴方向
 */
- (void)BPCheckPitchOrientationOpposite {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x3d;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x3d;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 切换俯仰控制方向
 */
- (void)BPSendPitchOrientationOpposite {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x3c;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x3c;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 手机进入校准模式，通知设备关闭电机
 */
- (void)BPEnterCalibrationMode {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x15;
    bytes1[2] = 0x00;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x15;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进行加速度校准
 */
- (void)BPAccelerationCalibration {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x16;
    bytes1[2] = 0x00;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x16;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进行陀螺仪校准
 */
- (void)BPGyroscopeCalibration {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x19;
    bytes1[2] = 0x00;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x19;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备退出校准模式
 */
- (void)BPQuitCalibrationMode {
    
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x14;
    bytes1[2] = 0x00;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x14;
    bytes[2] = 0x00;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备进入移动延时模式
 */
- (void)BPEnterMotionLapseMode {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x0d;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x0d;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备开始移动延时模式

 @param Speed 延时摄影速度
 */
- (void)BPStartMotionLapseModeSpeed:(NSInteger)speed {
    Byte bytes1[5];
    bytes1[0] = 0xff;
    bytes1[1] = 0x0b;
    bytes1[2] = 2;
    bytes1[3] = 0;
    bytes1[4] = speed;
    NSData *data = [NSData dataWithBytes:bytes1 length:5];
    
    Byte bytes[7];
    bytes[0] = 0xff;
    bytes[1] = 0x0b;
    bytes[2] = 2;
    bytes[3] = 0;
    bytes[4] = speed;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[5] = ck_ab[0];
    bytes[6] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:7];
    
    [self sendMsg:msg];
}

/**
 告知设备记录延时摄影位置点

 @param position 第几个位置点（1-255）
 @param time 停留时间（0:不停留；1-255:停留时间）
 */
- (void)BPRecordMotionLapsePosition:(NSInteger)position StandingTime:(NSInteger)time {
    Byte bytes1[5];
    bytes1[0] = 0xff;
    bytes1[1] = 0x0f;
    bytes1[2] = 2;
    bytes1[3] = position;
    bytes1[4] = time;
    NSData *data = [NSData dataWithBytes:bytes1 length:5];
    
    Byte bytes[7];
    bytes[0] = 0xff;
    bytes[1] = 0x0f;
    bytes[2] = 2;
    bytes[3] = position;
    bytes[4] = time;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[5] = ck_ab[0];
    bytes[6] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:7];
    
    [self sendMsg:msg];
}

/**
 告知设备删除延时摄影记录点

 @param position 第几个位置点（1-255）
 */
- (void)BPDeleteMotionLapsePosition:(NSInteger)position {
    Byte bytes1[4];
    bytes1[0] = 0xff;
    bytes1[1] = 0x1b;
    bytes1[2] = 1;
    bytes1[3] = position;
    NSData *data = [NSData dataWithBytes:bytes1 length:4];
    
    Byte bytes[6];
    bytes[0] = 0xff;
    bytes[1] = 0x1b;
    bytes[2] = 1;
    bytes[3] = position;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[4] = ck_ab[0];
    bytes[5] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:6];
    
    [self sendMsg:msg];
}

/**
 告知设备暂停移动延时模式
 */
- (void)BPStopMotionLapseMode {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x0e;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x0e;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 告知设备退出移动延时模式
 */
- (void)BPQuitMotionLapseMode {
    Byte bytes1[3];
    bytes1[0] = 0xff;
    bytes1[1] = 0x0c;
    bytes1[2] = 0;
    NSData *data = [NSData dataWithBytes:bytes1 length:3];
    
    Byte bytes[5];
    bytes[0] = 0xff;
    bytes[1] = 0x0c;
    bytes[2] = 0;
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3] = ck_ab[0];
    bytes[4] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:5];
    
    [self sendMsg:msg];
}

/**
 向设备发送自定义功能

 @param mode 自定义代码
 @param string 自定义字符串
 */
- (void)BPSendCustomFunctionStr:(NSString *)string {
    NSLog(@"自定义字符串 = %@", string);
    Byte bytes1[3+string.length];
    bytes1[0] = 0xff;
    bytes1[1] = 0x1c;
    bytes1[2] = string.length;
    NSData *currData = [self convertHexStrToData:[self hexStringFromString:string]];
    
    Byte *byteData = (Byte *)[currData bytes];
    
    for (int index = 0; index < string.length; index++) {
        bytes1[index+3] = byteData[index];
    }
    NSData *data = [NSData dataWithBytes:bytes1 length:3+string.length];

    Byte bytes[3+string.length+2];
    bytes[0] = 0xff;
    bytes[1] = 0x1c;
    bytes[2] = string.length;
    for (int index = 0; index < string.length; index++) {
        bytes[index+3] = byteData[index];
    }
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[3+string.length] = ck_ab[0];
    bytes[3+string.length+1] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:3+string.length+2];
    
    [self sendMsg:msg];
    
}

#pragma mark - SendMessage
//发送消息总方法
- (void)sendMsg:(NSData *)msg {
    if (msg) {
        if (jeManager.bluetoothState == Connect && _outPutcharacteristic != nil){
            NSString *dataMsg = [[self convertDataToHexStr:msg] substringWithRange:NSMakeRange(2, 2)];
            NSLog(@"发送的关键命令 : %@", dataMsg);
            [jeManager.peripheral writeValue:msg forCharacteristic:_outPutcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"发送消息 : %@", msg);
        }
    }
}

//发送限制频率消息
- (void)sendRestrictiveMsg:(NSData *)msg {
    if (msg) {
        if (jeManager.bluetoothState == Connect && _outPutcharacteristic != nil) {
            if (_canSendMsg) {
                [self sendMsg:msg];
                jeManager.canSendMsg = NO;
                NSLog(@"发送限制频率消息 : %@", msg);
            }
        }
    }
}

#pragma mark - Tools
//data转字符串
- (NSString *)convertDataToHexStr:(NSData *)data{
    
    if (!data || [data length] == 0) {
        
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

//16进制字符串转data
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];// 接收到的数据：<ff0a000a 14>
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

//普通字符串转成十六进制字符串
- (NSString *)hexStringFromString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for(int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i]&0xff];///16进制数
        
        if([newHexStr length] == 1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
    }
    return hexStr;
}

//计算 RSSI 的平均值
- (NSNumber *)calculationRSSIAverage:(NSArray *)rssiArray {
    int all = 0;
    int count = 0;
    
    for (int i = 0; i < rssiArray.count; i++) {
        
        all = [rssiArray[i] intValue] + all;
        count = count + 1;
    }
    
    NSLog(@"RSSI 的平均值 = %d, rssiArray.count = %lu", all/count, (unsigned long)rssiArray.count);
    
    return [NSNumber numberWithInt:(all/count)];
}

@end
