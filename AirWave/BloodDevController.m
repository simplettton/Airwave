//
//  ViewController.m
//  LifotronicFamily
//
//  Created by simplettton on 2017/7/31.
//  Copyright © 2017年 Simplettton. All rights reserved.
//

#import "BloodDevController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID        @"1b7e8251-2877-41c3-b46e-cf057c562023"
#define CHARACTERISTIC_UUID @"5e9bf2a8-f93f-4481-a67e-3b2f4a07891a"

@interface BloodDevController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong)CBCentralManager *centralManager;
@property(nonatomic,strong)CBPeripheral *peripheral;
@property(nonatomic,strong)CBCharacteristic *characteristic;
@end


@implementation BloodDevController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *key = @"1234abcd";
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%s %s",[key UTF8String],data.bytes);
    [self setupSwipe];
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
}

/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBManagerStatePoweredOn)
    {
        NSLog(@"蓝牙可用");
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
    }
    if (central.state ==CBManagerStatePoweredOff)
    
    {
        NSLog(@"蓝牙未启动");
    }
}
/** 发现符合要求的外设，回调 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"找到了设备");
    self.peripheral = peripheral;
    NSLog(@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral.name, RSSI, peripheral.identifier, advertisementData);
    
    [central connectPeripheral:peripheral options:nil];
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    NSLog(@"连接成功");
    [self.centralManager stopScan];
    peripheral.delegate = self;
    //根据uuid来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark -CBPeripheralDelegate

/** 发现服务 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    
// 遍历出外设中所有的服务
//    for(CBService *service in peripheral.services)
//    {
//        NSLog(@"所有的服务 %@",service);
//    }
    CBService *service = [peripheral.services lastObject];
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
}

/** 发现特征 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"所有的特征值是：%@",characteristic);
    }
    self.characteristic = [service.characteristics lastObject];
    
    
    [peripheral readValueForCharacteristic:self.characteristic];
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    
}

///** 订阅状态的改变 */
//-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (error) {
//        NSLog(@"订阅失败");
//        NSLog(@"%@",error);
//    }
//    if (characteristic.isNotifying) {
//        NSLog(@"订阅成功");
//    } else {
//        NSLog(@"取消订阅");
//    }
//}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // 拿到外设发送过来的数据
//    NSData *data = characteristic.value;
//    NSLog(@"收到从蓝牙上发出的数据是：%@",data);
}
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value
{
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}
//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}
- (IBAction)start:(id)sender
{
    Byte startCommand = 0x01;
    NSData *startData = [NSData dataWithBytes:&startCommand length:sizeof(startCommand)];
    [self.peripheral writeValue:startData
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse];
}

- (IBAction)stop:(id)sender
{
    Byte closeCommand = 0x02;
    NSData *closeData = [NSData dataWithBytes:&closeCommand length:sizeof(closeCommand)];
    [self.peripheral writeValue:closeData
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse];
}

- (IBAction)pause:(id)sender
{
    Byte closeCommand = 0x02;
    NSData *closeData = [NSData dataWithBytes:&closeCommand length:sizeof(closeCommand)];
    [self.peripheral writeValue:closeData
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse];
}
//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma mark - swipe

- (void)setupSwipe
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    [self.view addGestureRecognizer:swipe];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
}
- (void)swipeRight
{
    [self performSegueWithIdentifier:@"BloodReturnHome" sender:nil];
}



@end
