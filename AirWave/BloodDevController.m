//
//  ViewController.m
//  LifotronicFamily
//
//  Created by simplettton on 2017/7/31.
//  Copyright © 2017年 Simplettton. All rights reserved.
//

#import "BloodDevController.h"
#import "TreatRecord.h"
//#import "RecordTableViewController.h"
static NSString *TYPE = @"8888";
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
    NSInteger duration;
}
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic,strong)CBCharacteristic *sendCharacteristic;
@property (nonatomic,strong)CBCharacteristic *receiveCharacteristic;
- (IBAction)timeChange:(id)sender;
- (IBAction)levelChange:(id)sender;
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
- (IBAction)showRecord:(id)sender;
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
    NSLog(@"peripheral= %@",self.currPeripheral);
    [self setupSwipe];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];

     [super viewDidAppear:YES];

    [baby cancelAllPeripheralsConnection];
}
//babyDelegate
-(void)babyDelegate
{
    __weak typeof(self)weakSelf = self;
    [baby setBlockOnConnectedAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        isConnected = YES;
    }];

    [baby setBlockOnFailToConnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];

    [baby setBlockOnDisconnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
//        [baby.centralManager connectPeripheral:peripheral options:nil];
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开连接",peripheral.name]];
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
                else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RX_CHARACTERISTIC_UUID]])
                {
                    weakSelf.receiveCharacteristic = characteristic;
                    [weakSelf setNotifiy:characteristic];
                }
            }
        }
    }];


    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);

    }];
   
    
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"didUpdata");
        
    }];

    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};

    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnCharacteristicView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
-(void)loadData
{
    if (baby)
    {
            baby.having(self.currPeripheral).and.channel(channelOnCharacteristicView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}
- (IBAction)start:(id)sender
{
    if (isConnected)
    {
        if(self.state != RUNNING)
        {
            uint8_t *ls = malloc(sizeof(*ls)*100);
            ls[0] = 0x01;
            ls[1] = self.timeStepper.value;
            ls[2] = self.levelStepper.value;
            NSData * startData = [NSData dataWithBytes:ls length:3];
            [self.currPeripheral writeValue:startData
                          forCharacteristic:self.sendCharacteristic
                                       type:CBCharacteristicWriteWithResponse];
            if (self.state == PAUSE)
            {
                [self resumeTimer];
            }else if (self.state == STOP)
            {
                [self startGCDTimer];
            }
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
            Byte closeCommand = 0x02;
            NSData *closeData = [NSData dataWithBytes:&closeCommand length:sizeof(closeCommand)];
            [self.currPeripheral writeValue:closeData
                          forCharacteristic:self.sendCharacteristic
                                       type:CBCharacteristicWriteWithResponse];
        }
    }
    if (self.timeStepper.value <10 )
    {
        self.timerLabel.text = [NSString stringWithFormat:@"0%d:00",(int)self.timeStepper.value];
    }
    else
    {
        self.timerLabel.text = [NSString stringWithFormat:@"%d:00",(int)self.timeStepper.value];
    }
}

- (IBAction)pause:(id)sender
{
    if (isConnected)
    {
        if (self.state ==RUNNING)
        {
            Byte closeCommand = 0x01;
            NSData *closeData = [NSData dataWithBytes:&closeCommand length:sizeof(closeCommand)];
            [self.currPeripheral writeValue:closeData
                          forCharacteristic:self.sendCharacteristic
                                       type:CBCharacteristicWriteWithResponse];
            [self pauseTimer];
        }
    }
}
- (void)resumeTimer
{
    if(_timer)
    {
        dispatch_resume(_timer);
    }
    self.state = RUNNING;
}
- (void) pauseTimer
{
    if(_timer)
    {
        dispatch_suspend(_timer);
    }
    self.state = PAUSE;
}
- (void) stopTimer
{
    if(_timer)
    {
        if (self.state == PAUSE)
        {
            dispatch_resume(_timer);
        }
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    self.state = STOP;
}
- (void)startGCDTimer
{
    __block NSInteger timeOut = timeLine;
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
    self.state = RUNNING;
}

-(void)setNotifiy:(CBCharacteristic *)characteristic
{
    __weak typeof(self)weakSelf = self;
    [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    [baby notify:weakSelf.currPeripheral
  characteristic:characteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//               NSLog(@"new value %@",characteristics.value);
               NSData *data = characteristic.value;
               Byte *bytes = (Byte *)[data bytes];
               if (bytes[0] == 0x34)
               {
                   if (self.state == PAUSE)
                   {
                       [self resumeTimer];
                   }else if (self.state == STOP)
                   {
                       [self startGCDTimer];
                   }
               }
               else if(bytes[0] == 0x56)
               {
                   if(self.state != PAUSE)
                   {
                       [self pauseTimer];
                   }
               }
               else if(bytes [0] == 0x78)
               {
                   if (self.state != STOP)
                   {
                       [self stopTimer];
                   }
                   [self stop:nil];
                   self.treatRecord = [[TreatRecord alloc]init];
                   self.treatRecord.treatWay = self.levelStepper.value;
                   self.treatRecord.duration = (UInt32)duration;
                   [self.treatRecord changeDurationToString];
                   self.treatRecord.type = TYPE;
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self takePhotoAlert];
                   });
               }
               
           }];
}
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

- (IBAction)levelChange:(id)sender
{
    self.levelLabel.text = [NSString stringWithFormat:@"%d",(int)self.levelStepper.value];
    
}
- (IBAction)timeChange:(id)sender
{
    self.timeLabel.text = [NSString stringWithFormat:@"%d",(int)self.timeStepper.value];
    timeLine = self.timeStepper.value*60;
    if (self.timeStepper.value <10 )
    {
        self.timerLabel.text = [NSString stringWithFormat:@"0%d:00",(int)self.timeStepper.value];
    }
    else
    {
        self.timerLabel.text = [NSString stringWithFormat:@"%d:00",(int)self.timeStepper.value];
    }
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BloodReturnHome"])
    {
        [baby cancelAllPeripheralsConnection];
    }
}
- (IBAction)BloodDevReturnHome:(id)sender
{
    [self swipeRight];
}

- (IBAction)returnHome:(id)sender
{
    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
}
@end
