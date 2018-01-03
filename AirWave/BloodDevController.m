//
//  ViewController.m
//  LifotronicFamily
//
//  Created by simplettton on 2017/7/31.
//  Copyright © 2017年 Simplettton. All rights reserved.
//

#import "BloodDevController.h"
#import "TreatRecord.h"
#import "Pack.h"
#import "Unpack.h"
static const NSString *TYPE = @"8888";
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
#define SERVICE_UUID        @"1b7e8251-2877-41c3-b46e-cf057c562023"
#define TX_CHARACTERISTIC_UUID @"5e9bf2a8-f93f-4481-a67e-3b2f4a07891a"
#define RX_CHARACTERISTIC_UUID @"8ac32d3f-5cb9-4d44-bec2-ee689169f626"
#define channelOnCharacteristicView @"CharacteristicView"
typedef NS_ENUM(NSUInteger,State)
{
    STOP,PAUSE,RUNNING
};
@interface BloodDevController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL isConnected;
    dispatch_source_t _timer;
    NSInteger timeLine;
    NSInteger runTime;
    NSInteger duration;
}
@property (nonatomic, strong) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIView *timerBackground;
@property (nonatomic,strong)CBCharacteristic *sendCharacteristic;
@property (nonatomic,strong)CBCharacteristic *receiveCharacteristic;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *levelStepper;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) TreatRecord *treatRecord;
@property (assign,nonatomic) NSInteger state;
@property (assign,nonatomic) NSInteger timeValue;
@property (assign,nonatomic) NSInteger levelValue;
- (IBAction)timeChange:(id)sender;
- (IBAction)levelChange:(id)sender;
- (IBAction)returnHome:(id)sender;
@end

@implementation BloodDevController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //导航栏
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xffffff);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xffffff);
    
    self.timeValue = self.timeStepper.value;
    self.levelValue = self.levelStepper.value;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.title = @"血瘘治疗仪";
    self.services = [[NSMutableArray alloc]init];
    isConnected = NO;
    timeLine = self.timeStepper.value*60;
    [self babyDelegate];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
    if (self.picker == nil)
    {
        self.picker = [[UIImagePickerController alloc]init];
    }
    self.picker.delegate = self;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (!isConnected)
    {
         [SVProgressHUD showInfoWithStatus:@"准备连接设备"];
    }
    [self setupSwipe];
    

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (_timer)
    {
        [self stopTimer];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];


}
#pragma mark - babyDelegate
-(void)loadData
{
    if (baby)
    {
        baby.having(self.currPeripheral).and.channel(channelOnCharacteristicView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}

-(void)babyDelegate
{
    __weak typeof(self)weakSelf = self;
    [baby setBlockOnConnectedAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
//        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
//        isConnected = YES;
    }];

    [baby setBlockOnFailToConnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];

    [baby setBlockOnDisconnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
//        [baby.centralManager connectPeripheral:peripheral options:nil];
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开连接",peripheral.name]];
        [SVProgressHUD dismissWithDelay:0.9];
    }];
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, NSError *error) {

    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBService *service, NSError *error)
     {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID]])
        {
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TX_CHARACTERISTIC_UUID]])
                {
                    weakSelf.sendCharacteristic = characteristic;
                }
            }
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
            if ([characteristics.UUID isEqual:[CBUUID UUIDWithString:RX_CHARACTERISTIC_UUID]])
            {
                weakSelf.receiveCharacteristic = characteristics;

                if (![characteristics isNotifying])
                {
                     [weakSelf setNotifiy:characteristics];
                }
                //询问设备识别码
//                NSData *matchCommand = [Pack packetWithCmdid:0xFA addressEnabled:NO addr:nil dataEnabled:NO data:nil];
//                [weakSelf.currPeripheral writeValue:matchCommand
//                                  forCharacteristic:weakSelf.sendCharacteristic
//                                               type:CBCharacteristicWriteWithResponse];
                NSData *askCommand = [Pack packetWithCmdid:0x91 addressEnabled:NO addr:nil dataEnabled:NO data:nil];
                [weakSelf.currPeripheral writeValue:askCommand
                                  forCharacteristic:weakSelf.sendCharacteristic
                                               type:CBCharacteristicWriteWithResponse];
                
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
                [SVProgressHUD dismissWithDelay:0.9];
                isConnected = YES;
            }
    }];
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error)
     {
        NSLog(@"didUpdata");

    }];

    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnCharacteristicView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
#pragma mark - writeData
-(void)writeData:(NSData *)data
{
    [self.currPeripheral writeValue:data
                  forCharacteristic:self.sendCharacteristic
                               type:CBCharacteristicWriteWithResponse];
}
#pragma mark - receiveData
-(void)setNotifiy:(CBCharacteristic *)characteristic
{
    __weak typeof(self)weakSelf = self;
    [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    [baby notify:weakSelf.currPeripheral
  characteristic:characteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
               NSLog(@"----------------------------------------------");
               NSData *data = characteristic.value;
               [weakSelf analyzeReceivedData:data];
           }];
}
-(void)analyzeReceivedData:(NSData *)receivedData
{
//    __weak typeof(self)weakSelf = self;
    NSData *data = [Unpack unpackData:receivedData];
    Byte *bytes = (Byte *)[data bytes];
    for (int i = 0; i<[data length]; i++)
    {
        NSLog(@"bytes[%d] = %x",i,bytes[i]);
    }
    Byte cmdID = bytes[0];

    // 设备识别
//    if (cmdID == 0xFA)
//    {
//        if ((bytes[1]==0x1f) && (bytes[2]==0xdf))
//        {
//            NSData *askCommand = [Pack packetWithCmdid:0x91 addressEnabled:NO addr:nil dataEnabled:NO data:nil];
//            [weakSelf.currPeripheral writeValue:askCommand
//                              forCharacteristic:weakSelf.sendCharacteristic
//                                       type:CBCharacteristicWriteWithResponse];
//            isConnected = YES;
//            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",self.currPeripheral.name]];
//        }
//    }
    
    //实时数据
    if(cmdID==0x91)
    {
        NSInteger setMin = 0;
        NSInteger setSecond = 0;
        NSInteger min = 0;
        NSInteger second = 0;
        NSInteger setLevel = 0;
        
        if ([data length]>2)
        {
            //运行时间和秒
            setMin = bytes[2];

            setSecond = bytes[3];
            setLevel = bytes[4];
            min = bytes[5];
            second = bytes[6];
            self.timeValue = setMin;
            self.levelValue = setLevel;
        }
        if (bytes[1]!=0x20)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timeLabel.text = [NSString stringWithFormat:setMin<10?@"0%d":@"%d",(int)setMin];
                self.levelLabel.text = [NSString stringWithFormat:@"%d",(int)setLevel];
            });
            timeLine = setMin*60 + setSecond;
        }
        //仪器结束治疗
        if (bytes [1]==0x20)
        {
            [self stopTimer];
            self.state = STOP;
            self.treatRecord = [[TreatRecord alloc]init];
            self.treatRecord.treatWay = self.levelStepper.value;
            self.treatRecord.duration = (UInt32)duration;
            [self.treatRecord changeDurationToString];
            self.treatRecord.type = TYPE;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            self.treatRecord.name = [userDefault objectForKey:@"name"];
            self.treatRecord.sex = [userDefault objectForKey:@"sex"];
            self.treatRecord.age = [userDefault objectForKey:@"age"];
            self.treatRecord.phoneNumber = [userDefault objectForKey:@"phoneNumber"];
            self.treatRecord.address = [userDefault objectForKey:@"address"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timerLabel.text = [NSString stringWithFormat:self.timeValue<10?@"0%d:00":@"%d:00",(int)self.timeValue];
                self.timeLabel.text = [NSString stringWithFormat:self.timeValue<10?@"0%d":@"%d",(int)self.timeValue];
                self.levelLabel.text = [NSString stringWithFormat:@"%d",(int)self.levelValue];
                [self takePhotoAlert];
            });
        }
        //工作
        else if (bytes [1]==0x12)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *secondString = [NSString stringWithFormat:second<10?@"0%d":@"%d",(int)second];
                NSString *minString = [NSString stringWithFormat:min<10?@"0%d":@"%d",(int)min];
                self.timerLabel.text = [NSString stringWithFormat:@"%@:%@",minString,secondString];
            });

            runTime = min*60+second;
            if (self.state == PAUSE)
            {
                if(!_timer)
                {
//                    [self stopTimer];
                    NSInteger restartTime = min*60 + second;
                    [self startGCDTimerWithStartTime:restartTime];
                }
            }else if (self.state == STOP)
            {

                if (!_timer)
                {
                    [self startGCDTimerWithStartTime:timeLine];
                }
            }
            self.state = RUNNING;
        }
        //暂停
        else if (bytes [1]==0x13)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *secondString = [NSString stringWithFormat:second<10?@"0%d":@"%d",(int)second];
                NSString *minString = [NSString stringWithFormat:min<10?@"0%d":@"%d",(int)min];
                self.timerLabel.text = [NSString stringWithFormat:@"%@:%@",minString,secondString];
            });
            runTime = min*60+second;
            if(self.state != PAUSE)
            {
                [self stopTimer];
            }
            self.state = PAUSE;
        }
        //空闲
        else if (bytes[1]==0x11)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timeStepper.value = setMin;
                self.levelStepper.value = setLevel;
                timeLine = self.timeStepper.value*60;
                self.timerLabel.text = [NSString stringWithFormat:setMin<10?@"0%d:00":@"%d:00",(int)setMin];
            });
            self.state = STOP;
        }
    }
}
#pragma mark - buttonAction
- (IBAction)start:(id)sender
{
    if (isConnected)
    {
        if(self.state != RUNNING)
        {
            NSData * startCommand;
            if (self.state == PAUSE)
            {
                startCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0x02]];
                [self startGCDTimerWithStartTime:runTime];
            }else if (self.state == STOP)
            {
                Byte bytes[3] = {0x09,self.timeStepper.value,self.levelStepper.value};
                NSData *data = [NSData dataWithBytes:bytes length:3];
                startCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:data];
                [self startGCDTimerWithStartTime:timeLine];
            }
            [self writeData:startCommand];
        }
        
    }
}
- (IBAction)stop:(id)sender
{
    if (isConnected)
    {
        if (self.state != STOP)
        {
            [self stopTimer];
            NSData *stopCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0X03]];
            [self writeData:stopCommand];
        }
    }
}
- (IBAction)pause:(id)sender
{
    if (isConnected)
    {
        if (self.state ==RUNNING)
        {
            NSData *pauseCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0x04]];
            [self writeData:pauseCommand];
            [self stopTimer];
        }
    }
}
- (IBAction)levelChange:(id)sender
{
    self.levelLabel.text = [NSString stringWithFormat:@"%d",(int)self.levelStepper.value];
    
        //增加减少强度写入设备命令
        if (self.levelStepper.value > self.levelValue)
        {
            NSData *levelUpCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0X07]];
            [self writeData:levelUpCommand];
        }
        else if (self.levelStepper.value < self.levelValue)
        {
            NSData *levelDownCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0X08]];
            [self writeData:levelDownCommand];
        }
    
    self.levelValue = self.levelStepper.value;
}
- (IBAction)timeChange:(id)sender
{
    timeLine = self.timeStepper.value*60;
    NSInteger min = self.timeStepper.value;
    self.timerLabel.text = [NSString stringWithFormat:min<10?@"0%d:00":@"%d:00",(int)min];
    self.timeLabel.text = [NSString stringWithFormat:min<10?@"0%d":@"%d",(int)min];
    
        //增加减少时间写入设备命令
        if (self.timeStepper.value > self.timeValue)
        {
            NSData *timeUpCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0X05]];
            [self writeData:timeUpCommand];
        }
        else if (self.timeStepper.value < self.timeValue)
        {
            NSData *timeDownCommand = [Pack packetWithCmdid:0x90 addressEnabled:NO addr:nil dataEnabled:YES data:[self dataWithValue:0X06]];
            [self writeData:timeDownCommand];
        }
    self.timeValue = self.timeStepper.value;
}
#pragma mark timerAction

- (void) stopTimer
{
    if(_timer)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
- (void)startGCDTimerWithStartTime:(NSInteger)startTime
{
    __block NSInteger timeOut = startTime;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(),
        ^{
            if (timeOut > 0)
            {
                int min = timeOut / 60 % 60;
                int second = timeOut % 60;
                NSString *minString = [NSString stringWithFormat:min>9?@"%d":@"0%d",min];
                NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
                self.timerLabel.text = [NSString stringWithFormat:@"%@:%@",minString,secondString];
                duration = timeLine - timeOut;
                timeOut--;
            }
            else
            {
                dispatch_source_cancel(_timer);  
            }
        });
    });
    dispatch_resume(_timer);
}
#pragma mark - Take Photo
-(void)takePhotoAlert
{
    NSString *title = @"是否拍照记录治疗情况？";
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    //修改提示标题的颜色和大小
    NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
    [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
    [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
    [alert setValue:titleAtt forKey:@"attributedTitle"];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                 [self saveRecord];
                                                             });
                                                             
                                                             
                                                         }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action){
                                                              [self takePhoto];
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)takePhoto
{
    [self presentViewController:self.picker animated:YES completion:NULL];
};
#pragma mark - save
//选择照片完成后回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //开一个线程保存
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //保存图片
        self.treatRecord.hasImage = YES;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self saveImage:image];
        //保存记录
        [self saveRecord];
        
        //保存到本地相册
        if (self.picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        }
        //保存完将图片消除
        self.treatRecord.imagePath = nil;
    });
    [self.picker dismissViewControllerAnimated:YES completion:^{

    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [self saveRecord];
    });
    [self.picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)saveRecord
{

    //文件名
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (!documents)
    {
        NSLog(@"目录未找到");
    }
    NSString *documentPath = [documents stringByAppendingPathComponent:@"record.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentPath])
    {
        [fileManager createFileAtPath:documentPath contents:nil attributes:nil];
    }
    NSArray *recordArray = [[NSArray alloc]init];
    //取出以前保存的record数组
    if ([fileManager fileExistsAtPath:documentPath])
    {
        NSData * resultdata = [[NSData alloc] initWithContentsOfFile:documentPath];
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:resultdata];
        recordArray = [unArchiver decodeObjectForKey:@"recordArray"];
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:recordArray];
    //新增record
    [array addObject:self.treatRecord];
    recordArray = [array copy];
    //写入文件
    NSMutableData *data = [[NSMutableData alloc] init] ;
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data] ;
    [archiver encodeObject:recordArray forKey:@"recordArray"];
    [archiver finishEncoding];
    
    BOOL success = [data writeToFile:documentPath atomically:YES];
    if (!success)
    {
        NSLog(@"写入文件失败");
    }
}
-(void)saveImage:(UIImage *)image
{
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.treatRecord.idString]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imagePath])
    {
        [fileManager createFileAtPath:imagePath contents:nil attributes:nil];
    }
    self.treatRecord.imagePath = imagePath;
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

#pragma mark - segue

- (void)setupSwipe
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    [self.view addGestureRecognizer:swipe];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
}
- (void)swipeRight
{
    [self returnHome:nil];
}
- (IBAction)returnHome:(id)sender
{
    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
    if (baby)
    {
        if(self.receiveCharacteristic)
        {
            [baby cancelNotify:self.currPeripheral characteristic:self.receiveCharacteristic];
        }
        [baby cancelAllPeripheralsConnection];
    }
}
#pragma mark -privateMethod
-(NSData*) dataWithValue:(NSInteger)value
{
    NSData *data = [NSData dataWithBytes:&value length:1];
    return data;
}

@end
