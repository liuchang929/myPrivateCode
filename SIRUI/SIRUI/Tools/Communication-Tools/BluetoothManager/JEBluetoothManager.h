//
//  JEBluetoothManager.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/22.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

//自定义蓝牙状态 0-5跟系统蓝牙状态相同
typedef enum : NSUInteger {
    Unknown = 0,
    Resetting,
    Unsupported,
    Unauthorized,
    PoweredOff,
    PoweredOn,
    Fail,
    Connect,
    DisConnect
}bluetoothToolsState;

//支持的蓝牙设备名
typedef enum : NSInteger {
    RPXMXP,
}bluetoothDeviceName;

@protocol JEBluetoothManagerDelegate <NSObject>

@optional
- (void)updateDevices:(NSArray *)devicesArray Macs:(NSArray *)macArray;     //更新外设
- (void)updateBLEState:(bluetoothToolsState)bluetoothState;                 //更新蓝牙状态
- (void)revicedMessage:(NSData *)msg;                                       //接受到数据回调
- (void)commandDidRecieved:(NSString *)msg;                                 //设备发送信道内容
- (void)advertisementPeripheral:(CBPeripheral *)peripheral Msg:(NSDictionary<NSString *, id> *)msgDic;   //设备广播内容
- (void)hintBLEStatus:(bluetoothToolsState)bleStatus;                       //蓝牙当前状态提示

@end

@interface JEBluetoothManager : NSObject

@property (nonatomic, weak)             id<JEBluetoothManagerDelegate> delegate;
@property (nonatomic, strong)           CBService           *service;                       //当前服务
@property (nonatomic, strong)           CBService           *normalService;                 //普通服务
@property (nonatomic, strong)           CBService           *otaService;                    //ota服务
@property (nonatomic, strong, nullable) CBPeripheral        *peripheral;                    //连接的外设信息
@property (nonatomic, assign)           bluetoothDeviceName bleDeviceName;                  //支持的蓝牙设备名
@property (nonatomic, strong, nullable) NSMutableArray      *srPeripherals;                 //外设名数组
@property (nonatomic, strong, nullable) NSMutableArray      *srMacPeripherals;              //外设mac地址数组
@property (nonatomic, strong)           NSString            *serviceUUIDString;             //外设服务的UUID Default = FFF0
@property (nonatomic, strong)           NSString            *otaUUIDString;                 //ota服务的UUID Default = 00010203-0405-0607-0809-0A0B0C0D1911
@property (nonatomic, strong)           NSArray             *peripheralName;                //蓝牙扫描筛选设备名 Default = RPXMXP
@property (nonatomic, assign)           NSNumber            *scanRange;                     //蓝牙扫描范围 Default = -60
@property (nonatomic, assign)           float               scanMaxTime;                    //蓝牙扫描自动连接最长等待时间 Default = 10.0f
@property (nonatomic, strong)           NSString            *deviceBroadcastingNameKeyword; //设备名广播关键词 Default = kCBAdvDataLocalName
@property (nonatomic, strong)           NSString            *deviceBroadcastionDataKeyword; //设备数据广播关键词 Default = kCBAdvDataManufacturerData

//@property (nonatomic, strong)           CBCharacteristic    *characteristic;

//单例
+ (instancetype)shareBLESingleton;

//初始化管理中心 
- (void)initCentralManager;

//获取手机蓝牙当前状态
- (bluetoothToolsState)getBLEState;

//搜索指定名字的蓝牙设备
- (void)scanDevice:(NSArray *)deviceName;

//断开连接
- (void)disconnectDevice;

//连接设备
- (void)connectDeviceWithCBPeripheral:(CBPeripheral *)peripheral;

//停止扫描
- (void)stopScanDevice;

//重新扫描
- (void)reScanDevice;

//发送消息
- (void)sendMsg:(NSData *)msg;

//控制发送频率的消息
- (void)sendRestrictiveMsg:(NSData *)msg;

//发送 OTA 消息
- (void)sendOTAMsg:(NSData *)msg;

/*
 *  蓝牙协议指令
 */
//向设备获取固件版本信息
- (void)BPGetDeviceVersion;
//向设备获取蓝牙版本信息
- (void)BPGetBLEVersion;
//获取蓝牙参数数据
- (void)BPGetBLEParameter;
//收到蓝牙参数数据包
- (void)BPGetBLEParameterBag;
//进入固件更新模式
- (void)BPEnterFirmwareUpdate;
//固件升级第一个数据包
- (void)BPFirmwareUpdateFirstPacket:(Byte *)byteData;
//固件升级第二个数据包
- (void)BPFirmwareUpdateSecondPacket:(Byte *)byteData;
//退出固件更新模式
- (void)BPQuitFirmwareUpdata;
//进入人脸跟踪
- (void)BPEnterFaceTracking;
//人脸丢失
- (void)BPFaceMsgLoss;
//发送人脸数据 x:x值变化 y:y值变化
- (void)BPFaceMsgX:(int)x Y:(int)y;
//退出人脸跟踪
- (void)BPQuitFaceTracking;
//全景拍照 angle:角度
- (void)BPPanoPhoto:(int)angle;
//向设备发送退出全景指令
- (void)BPQuitPano;
//查询充电开关机状态
- (void)BPCheckChargingState;
//修改充电开关机状态
- (void)BPChangeChargingState:(BOOL)state;
//进入校准模式，通知云台关闭电机
- (void)BPEnterCalibrationMode;
//加速度校准
- (void)BPAccelerationCalibration;
//陀螺仪校准
- (void)BPGyroscopeCalibration;
//退出校准模式
- (void)BPQuitCalibrationMode;
//告知设备进入移动延时模式
- (void)BPEnterMotionLapseMode;
//告知设备开始移动延时模式
- (void)BPStartMotionLapseModeSpeed:(NSInteger)speed;
//告知设备记录延时摄影位置点
- (void)BPRecordMotionLapsePosition:(NSInteger)position StandingTime:(NSInteger)time;
//告知设备删除延时摄影记录点
- (void)BPDeleteMotionLapsePosition:(NSInteger)position;
//告知设备 暂停||继续 移动延时模式
- (void)BPStopMotionLapseMode;
//告知设备退出移动延时模式
- (void)BPQuitMotionLapseMode;
//向设备发送自定义功能
- (void)BPSendCustomFunctionStr:(NSString *)string;
//向设备获取俯仰轴方向
- (void)BPCheckPitchOrientationOpposite;
//切换俯仰控制方向
- (void)BPSendPitchOrientationOpposite;
/*
 OTA蓝牙固件
 */
//开始蓝牙升级
- (void)BPOtaSendUpdateStart;
- (void)BPOtasendUpdateEnd;

//暂存
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error;

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
